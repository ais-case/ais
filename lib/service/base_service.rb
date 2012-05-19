require 'ffi-rzmq'

module Service
  class BaseService
    def initialize
      @request_thread = nil
    end
    
    def start(endpoint)
      @request_thread = Thread.new do
        context = ZMQ::Context.new
        socket = context.socket(ZMQ::REP)        
        begin            
          socket.bind(endpoint)
          loop do 
            data = ''
            socket.recv_string(data)
            socket.send_string(processRequest(data))
          end
        rescue
          puts $!
          raise
        ensure 
          socket.close
        end
      end

      sleep(2)
      if not @request_thread.alive? 
        raise RuntimeError, "Couldn't start service listener"
      end 
    end

    def stop
      @request_thread.kill if @request_thread
      @request_thread = nil
    end
  end
end