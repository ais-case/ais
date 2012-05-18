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
end
