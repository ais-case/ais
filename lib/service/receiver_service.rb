require 'ffi-rzmq'
require 'socket'
require_relative 'platform/base_service'
require_relative 'platform/subscriber_service'
require_relative 'platform/publisher_service'
require_relative '../util'
require_relative '../domain/ais/checksums'

module Service
  class ReceiverService < Platform::BaseService
    
    def initialize(registry)
      super(registry)
      @registry = registry
      @log = Util::get_log('receiver')
      @payload = ''
      @transmitter = Platform::SubscriberService.new(method(:process_message), [''], @log)
      @publisher = Platform::PublisherService.new(@log)
    end
    
    def start(endpoint)
      @publisher.start(endpoint)

      transmitter_endpoint = @registry.lookup('ais/transmitter-pub')
      @transmitter.start(transmitter_endpoint) if transmitter_endpoint
            
      register_self('ais/receiver', endpoint)
      @log.info("Service started")
    end
    
    def wait
      @transmitter.wait
      @publisher.wait
    end
    
    def stop
      @transmitter.stop
      @publisher.stop      
    end
    
    def process_message(data)
      timestamp, fragment = data.split(' ')
      publish_message(timestamp, fragment) if Domain::AIS::Checksums::verify(fragment)      
    end
    
    def publish_message(timestamp, sentence)
      @log.debug("Publishing #{sentence} with timestamp #{timestamp}")
      @publisher.publish("%s %s" % [timestamp, sentence])
    end
  end
end