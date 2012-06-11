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
      @publish_thread.kill if @publish_thread
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
      @publish_queue.push("PAYLOAD #{payload}")
    end
  end
end