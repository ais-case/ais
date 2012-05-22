require 'ffi-rzmq'

module Service
  class ReplyService
    def initialize(handler)
      @handler = handler
      @thread = nil
      @done_queue = Queue.new
    end
    
    def start(endpoint)
      @done_queue.clear
      
      @thread = Thread.new(@done_queue) do |queue|
        context = ZMQ::Context.new
        socket = context.socket(ZMQ::REP)        
        begin            
          socket.bind(endpoint)
          queue.push(true)
          loop do 
            data = ''
            socket.recv_string(data)
            socket.send_string(@handler.call(data))
          end
        rescue
          queue.push(false)
          puts $!
          raise
        ensure
          socket.close
        end
      end
  
      begin
        timeout(2) do
          raise "Thread returned false" unless @done_queue.pop
        end    
      rescue
        raise RuntimeError, "Couldn't start service listener"
      end
    end
    
    def stop
      @thread.kill if @thread
      @thread = nil
    end
  end  
end