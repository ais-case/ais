require 'ffi-rzmq'
require 'socket'
require_relative '../util'
require_relative '../domain/ais/checksums'
require_relative '../domain/ais/six_bit_encoding'
require_relative 'platform/base_service'
require_relative 'platform/subscriber_service'

module Service
  class MessageService < Platform::BaseService
    
    def initialize(registry)
      super(registry)
      @registry = registry
      @log = Util::get_log('message')
      @payload = ''
      
      filter = ['PAYLOAD ']
      @combiner = Platform::SubscriberService.new(method(:process_message), filter, @log)
    end
    
    def start(endpoint)
      context = ZMQ::Context.new
      @pub_socket = context.socket(ZMQ::PUB)
      rc = @pub_socket.bind(endpoint)
      raise "Couldn't bind to socket" unless ZMQ::Util.resultcode_ok?(rc)
      
      combiner_endpoint = @registry.lookup('ais/combiner')
      @combiner.start(combiner_endpoint) if combiner_endpoint

      register_self('ais/message', endpoint)
      @log.info("Service started")
    end
    
    def wait
      @combiner.wait
    end
    
    def stop
      @combiner.stop
      @pub_socket.close      
    end
    
    def process_message(data)
      # Remove header
      payload = data.split(' ')[1] 
      
      # Determine message type by examining first byte of payload
      type = nil
      @registry.bind('ais/payload-decoder') do |service|
        type = service.decode(payload[0]).to_i(2)
      end
      publish_message(type, payload)
    end
    
    def publish_message(type, payload)
      @log.debug("Publishing #{payload} under type #{type}")
      rc = @pub_socket.send_string("#{type.to_s} #{payload}")
    end
  end
end