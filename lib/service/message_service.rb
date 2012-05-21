module Service
  class MessageService
    def start(endpoint)
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
    
    def stop
      @subscriber_thread.kill if @subscriber_thread
      @subscriber_thread = nil
    end
    
    def processRawMessage(data)
      preamble, fragment_count, fragment, id, channel, payload, checksum = data.split(',')      
      type = Domain::AIS::SixBitEncoding.decode(payload[0]).to_i(2)
      publish_message(type, payload)
    end
  end
end