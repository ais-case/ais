module Service
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
        rescue
          puts $!
          raise
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
end