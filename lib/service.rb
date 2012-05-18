require 'ffi-rzmq'

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
  
  class VesselService
    def initialize
      @vessels = []
      @request_thread = nil
    end
    
    def start(endpoint)
        context = ZMQ::Context.new
        socket = context.socket(ZMQ::REP)
        socket.bind(endpoint)
        
        begin
          @request_thread = Thread.new do
            loop do
              puts "Ready for requests"
              socket.recv_string()
            end
          end
        ensure 
          socket.close
          @request_thread = nil
        end
    end
    
    def stop
      @request_thread.kill if @request_thread
      @request_thread = nil
    end
    
    def receiveVessel(vessel)
      @vessels << vessel
    end
    
    def processRequest(request)
      Marshal.dump(@vessels)
    end
  end
  
  class ServiceRegistry
    ENDPOINTS = { 
      'ais/transmitter' => { :endpoint => 'tcp://localhost:20010', :class => TransmitterProxy},
      'ais/vessels'     => { :endpoint => 'tcp://localhost:20011', :class => VesselServiceProxy}
    }
  
    def initialize(context=ZMQ::Context.new)
      @context = context
    end
  
    def bind(name)
      ep = ENDPOINTS[name][:endpoint]
      socket = @context.socket ZMQ::REQ
  
      rc = socket.connect ep
  
      if ZMQ::Util.resultcode_ok? rc
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
