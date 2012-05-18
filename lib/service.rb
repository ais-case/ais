require 'ffi-rzmq'
require 'thread'

module Service
  class ServiceProxy
    def initialize(socket)
      @socket = socket
    end
  end
  
  class TransmitterProxy < ServiceProxy
    def send_position_report_for(vessel)
      message = Marshal.dump(vessel)
      @socket.send_string(message)
    end
  end
  
  class VesselServiceProxy < ServiceProxy
    def vessels
      @socket.send_string("")
      @socket.recv_string(message = "")
      return Marshal.load(message)
    end
  end
  
  class BaseService
    def initialize
      @request_thread = nil
    end
    
    def start(endpoint)
      ready_queue = Queue.new

      @request_thread = Thread.new do
        context = ZMQ::Context.new
        socket = context.socket(ZMQ::REP)        
        begin            
          socket.bind(endpoint)
          ready_queue.push(:ready) 
          loop do 
            data = ''
            socket.recv_string(data)
            socket.send_string(processRequest(data))
          end
        ensure 
          socket.close
        end
      end
      
      # Wait until thread is ready for action
      ready_queue.pop
    end

    def stop
      @request_thread.kill if @request_thread
      @request_thread = nil
    end
  end
  
  class TransmitterService < BaseService
    def processRequest(data)
      # TODO compile information in AIS message and deliver it
      # Nothing needs to be returned, empty response
      ""
    end  
  end
  
  class VesselService < BaseService
    def initialize
      @vessels = []
      @vessels_mutex = Mutex.new
    end
        
    def receiveVessel(vessel)
      @vessels_mutex.synchronize do
        @vessels << vessel
      end
    end
    
    def processRequest(request)
      @vessels_mutex.synchronize do
        Marshal.dump(@vessels)
      end
    end
  end
  
  class ServiceManager
    attr_writer :bindings
    
    BINDINGS = [{:endpoint => 'tcp://*:21000', :service => TransmitterService},
                {:endpoint => 'tcp://*:21001', :service => VesselService}]
    
    def initialize
      @services = []
    end
    
    def get_bindings
      @bindings ||= BINDINGS 
    end
    
    def start
      get_bindings.each do |binding|
        service = binding[:service].new
        service.start(binding[:endpoint])
        @services << service
      end
    end
    
    def stop
      @services.each do |service|    
        service.stop
      end
      @services.clear
    end
  end

  class ServiceRegistry
    ENDPOINTS = { 
      'ais/transmitter' => { :endpoint => 'tcp://localhost:21000', :class => TransmitterProxy},
      'ais/vessels'     => { :endpoint => 'tcp://localhost:21001', :class => VesselServiceProxy}
    }
  
    def initialize(context=ZMQ::Context.new)
      @context = context
    end
  
    def bind(name)
      ep = ENDPOINTS[name][:endpoint]
      socket = @context.socket ZMQ::REQ
  
      rc = socket.connect ep
  
      if ZMQ::Util.resultcode_ok?(rc)
        proxy = ENDPOINTS[name][:class].new socket 
        begin
          yield proxy
        ensure
          socket.close
        end
      else
        raise RuntimeError, "Couldn't connect to #{ep}"
      end
    end
  end  
end
