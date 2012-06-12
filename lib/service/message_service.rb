require 'ffi-rzmq'
require 'socket'
require_relative '../util'
require_relative 'platform/base_service'
require_relative 'platform/subscriber_service'
require_relative 'platform/publisher_service'

module Service
  class MessageService < Platform::BaseService
    
    def initialize(registry)
      super(registry)
      @registry = registry
      @log = Util::get_log('message')
      @payload = ''
      
      @combiner = Platform::SubscriberService.new(method(:process_message), [''], @log)
      @publisher = Platform::PublisherService.new(@log)
    end
    
    def start(endpoint)
      @publisher.start(endpoint)
      
      combiner_endpoint = @registry.lookup('ais/combiner')
      @combiner.start(combiner_endpoint) if combiner_endpoint

      register_self('ais/message', endpoint)
      @log.info("Service started")
    end
    
    def wait
      @combiner.wait and @publisher.wait
    end
    
    def stop
      @combiner.stop
      @publisher.stop
    end
    
    def process_message(data)
      timestamp, payload = data.split(' ')
      
      # Determine message type by examining first byte of payload
      type = nil
      @registry.bind('ais/payload-decoder') do |service|
        type = service.decode(payload[0]).to_i(2)
      end
      publish_message(type, timestamp, payload)
    end
    
    def publish_message(type, timestamp, payload)
      @log.debug("Publishing #{payload} with timestamp #{timestamp} under type #{type}")
      @publisher.publish("%d %s %s" % [type, timestamp, payload])
    end
  end
end