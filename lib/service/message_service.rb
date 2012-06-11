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
      
      @publish_queue = Queue.new
      @publish_thread = nil
    end
    
    def start(endpoint)
      
      @publish_thread = Thread.new(@log) do |log|
        context = ZMQ::Context.new
        socket = context.socket(ZMQ::PUB)
        begin
          log.debug("Running publish thread")
          rc = socket.bind(endpoint)
          raise "Couldn't bind to socket" unless ZMQ::Util.resultcode_ok?(rc)
          loop do
            socket.send_string(@publish_queue.pop)
            log.debug("Message published")
          end
        rescue => e
          @log.fatal("Subscriber service thread exception: #{e.message}")
          e.backtrace.each { |line| @log.fatal(line) }
          puts e.message
          queue.push(false)
          raise
        ensure
          socket.close
        end
      end
      
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
      @publish_thread.kill if @publish_thread     
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
      @publish_queue.push("#{type.to_s} #{payload}")
    end
  end
end