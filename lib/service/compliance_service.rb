require 'ffi-rzmq'
require 'socket'
require_relative '../util'
require_relative 'platform/base_service'
require_relative 'platform/subscriber_service'
require_relative 'platform/publisher_service'

module Service
  class ComplianceService < Platform::BaseService
    
    def initialize(registry)
      super(registry)
      @registry = registry
      @log = Util::get_log('compliance')
      filter = ['1 ', '2 ', '3 ', '5 ']
      @message_service = Platform::SubscriberService.new(method(:process_message), filter, @log)
      @publisher = Platform::PublisherService.new(@log)
    end
    
    def start(endpoint)
      @publisher.start(endpoint)
      
      message_endpoint = @registry.lookup('ais/message')
      @message_service.start(message_endpoint) if message_endpoint

      register_self('ais/compliance', endpoint)
      @log.info("Service started")
    end
    
    def wait
      @message_service.wait and @publisher.wait
    end
    
    def stop
      @message_service.stop
      @publisher.stop
    end
    
    def process_message(data)
    end
    
    def publish_message(mmsi)
      @log.debug("Publishing non-compliance of vessel #{mmsi}")
      @publisher.publish("NON-COMPLIANT #{mmsi}")
    end
  end
end