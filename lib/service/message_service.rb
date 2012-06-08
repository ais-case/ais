require 'ffi-rzmq'
require 'socket'
require_relative '../util'
require_relative '../domain/ais/checksums'
require_relative '../domain/ais/six_bit_encoding'
require_relative 'platform/base_service'

module Service
  class MessageService < Platform::BaseService
    
    def initialize(registry)
      super(registry)
      @registry = registry
      @log = Util::get_log('message')
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
      
      register_self('ais/message', endpoint)
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
      valid_message = false
      @registry.bind('ais/checksum') do |service|
        valid_message = service.verify(data)
      end      
      return unless valid_message
      
      preamble, fragment_count, fragment_number, id, channel, payload, suffix = data.split(',')
      
      @payload << payload
      
      if fragment_count == fragment_number
        type = nil
        @registry.bind('ais/payload-decoder') do |service|
          type = service.decode(@payload[0]).to_i(2)
        end
        publish_message(type, @payload.dup)
        @payload = ''
      end
    end
    
    def publish_message(type, payload)
      @log.debug("Publishing #{payload} under type #{type}")
      rc = @pub_socket.send_string("#{type.to_s} #{payload}")
    end
  end
end