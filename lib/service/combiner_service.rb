require 'ffi-rzmq'
require 'socket'
require_relative '../util'
require_relative 'platform/base_service'
require_relative 'platform/subscriber_service'
require_relative 'platform/publisher_service'

module Service
  class CombinerService < Platform::BaseService
    
    def initialize(registry)
      super(registry)
      @registry = registry
      @log = Util::get_log('combiner')
      @payload = ''
      @receiver = Platform::SubscriberService.new(method(:process_message), [''], @log)
      @publisher = Platform::PublisherService.new(@log)
    end
    
    def start(endpoint)
      @publisher.start(endpoint)      
      
      receiver_endpoint = @registry.lookup('ais/receiver')
      @receiver.start(receiver_endpoint) if receiver_endpoint

      register_self('ais/combiner', endpoint)
      @log.info("Service started")
    end
    
    def wait
      @receiver.wait and @publisher.wait
    end
    
    def stop
      @receiver.stop
      @publisher.stop
    end
    
    def process_message(data)
      # Remove message header
      sentence = data.split(' ')[1]
      
      # Concatenate payloads until last fragment is received
      preamble, fragment_count, fragment_number, id, channel, payload, suffix = sentence.split(',')
      @payload << payload
      if fragment_count == fragment_number
        publish_message(@payload.dup)
        @payload = ''
      end
    end
    
    def publish_message(payload)
      @log.debug("Publishing PAYLOAD #{payload}")
      @publisher.publish("PAYLOAD #{payload}")
    end
  end
end