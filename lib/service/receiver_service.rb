require 'ffi-rzmq'
require 'socket'
require_relative 'platform/base_service'
require_relative '../util'
require_relative '../domain/ais/checksums'

module Service
  class ReceiverService < Platform::BaseService
    
    def initialize(registry)
      super(registry)
      @registry = registry
      @log = Util::get_log('receiver')
      @payload = ''
    end
    
    def start(endpoint)
      context = ZMQ::Context.new
      @pub_socket = context.socket(ZMQ::PUB)
      rc = @pub_socket.bind(endpoint)
      raise "Couldn't bind to socket" unless ZMQ::Util.resultcode_ok?(rc)
      
      @subscriber_thread = Thread.new(TCPSocket.new('localhost', 20000)) do |socket|
        begin
          loop do
            data = socket.gets
            break if data == nil
            @log.debug("Received raw message: #{data}")
            process_message(data)
          end
       rescue
          puts $!
          raise
        ensure
          socket.close
        end
      end      
      
      register_self('ais/receiver', endpoint)
      @log.info("Service started")
    end
    
    def wait
      @subscriber_thread.join
    end
    
    def stop
      @pub_socket.close
      
      @subscriber_thread.kill if @subscriber_thread
      @subscriber_thread = nil
    end
    
    def process_message(data)
      publish_message(data) if Domain::AIS::Checksums::verify(data)      
    end
    
    def publish_message(sentence)
      @log.debug("Publishing SENTENCE #{sentence}")
      rc = @pub_socket.send_string("SENTENCE #{sentence}")
    end
  end
end