require 'ffi-rzmq'

module Service
  class MessageService < Platform::BaseService
    def start(endpoint)
      context = ZMQ::Context.new
      @pub_socket = context.socket(ZMQ::PUB)
      rc = @pub_socket.bind(endpoint)
      raise "Couldn't bind to socket" unless ZMQ::Util.resultcode_ok?(rc)
      
      @subscriber_thread = Thread.new(TCPSocket.new('localhost', 20000)) do |socket|
        begin
          loop do
            process_message(socket.gets)
          end
       rescue
          puts $!
          raise
        ensure
          socket.close
        end
      end      
    end
    
    def stop
      @pub_socket.close
      
      @subscriber_thread.kill if @subscriber_thread
      @subscriber_thread = nil
    end
    
    def process_message(data)
      preamble, fragment_count, fragment, id, channel, payload, checksum = data.split(',')      
      type = Domain::AIS::SixBitEncoding.decode(payload[0]).to_i(2)
      publish_message(type, payload)
    end
    
    def publish_message(type, payload)
      rc = @pub_socket.send_string("#{type.to_s} #{payload}")
    end
  end
end