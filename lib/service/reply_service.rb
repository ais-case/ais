require 'ffi-rzmq'

module Service
  class ReplyService
    def initialize(handler)
      @handler = handler
      @thread = nil
    end
    
    def start(endpoint)
      @thread = Thread.new do
        context = ZMQ::Context.new
        socket = context.socket(ZMQ::REP)        
        begin            
          socket.bind(endpoint)
          loop do 
            data = ''
            socket.recv_string(data)
            socket.send_string(@handler.call(data))
          end
        rescue
          puts $!
          raise
        ensure 
          socket.close
        end
      end
  
      sleep(2)
      if not @thread.alive? 
        raise RuntimeError, "Couldn't start service listener"
      end 
    end
    
    def stop
      @thread.kill if @thread
      @thread = nil
    end
  end  
end