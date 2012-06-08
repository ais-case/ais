require 'ffi-rzmq'
require 'socket'
require_relative '../util'
require_relative 'platform/base_service'
require_relative 'platform/subscriber_service'

module Service
  class CombinerService < Platform::BaseService
    
    def initialize(registry)
      super(registry)
      @registry = registry
      @log = Util::get_log('combiner')
      @payload = ''
      filter = ['SENTENCE ']
      @receiver = Platform::SubscriberService.new(method(:process_message), filter, @log)
    end
    
    def start(endpoint)
      context = ZMQ::Context.new
      @pub_socket = context.socket(ZMQ::PUB)
      rc = @pub_socket.bind(endpoint)
      raise "Couldn't bind to socket" unless ZMQ::Util.resultcode_ok?(rc)
      
      receiver_endpoint = @registry.lookup('ais/receiver')
      @receiver.start(receiver_endpoint) if receiver_endpoint

      register_self('ais/combiner', endpoint)
      @log.info("Service started")
    end
    
    def wait
      @receiver.wait
    end
    
    def stop
      @receiver.stop
      @pub_socket.close
    end
    
    def process_message(data)
      preamble, fragment_count, fragment_number, id, channel, payload, suffix = data.split(',')
      @payload << payload
      if fragment_count == fragment_number
        publish_message(@payload.dup)
        @payload = ''
      end
    end
    
    def publish_message(payload)
      @log.debug("Publishing PAYLOAD #{payload}")
      rc = @pub_socket.send_string("PAYLOAD #{payload}")
    end
  end
end