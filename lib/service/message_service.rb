module Service
  class MessageService < BaseService
    def start(endpoint)
      super(endpoint)
      
      @subscriber_thread = Thread.new do
        socket = TCPSocket.new('localhost', 20000)
        begin          
          loop do
            processRawMessage(socket.gets)
          end
       rescue
          puts $!
          raise
        ensure
          socket.close
        end
      end
      
      # Extra time needed for this socket to connect
      sleep(2)
    end
    
    def processRawMessage(data)
    
    end
  end
end