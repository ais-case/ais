require 'ffi-rzmq'
require 'socket'
require_relative '../util'
require_relative '../domain/ais/message_factory'
require_relative 'platform/base_service'
require_relative 'platform/subscriber_service'
require_relative 'platform/publisher_service'

module Service
  class ComplianceService < Platform::BaseService
    attr_writer :expected
    
    def initialize(registry)
      super(registry)
      @registry = registry
      @log = Util::get_log('compliance')
      filter = ['1 ', '2 ', '3 ', '5 ']
      @message_service = Platform::SubscriberService.new(method(:process_message), filter, @log)
      @publisher = Platform::PublisherService.new(@log)
      @checker_thread = nil
      @expected = Queue.new
      @last_recv = {}
      @last_recv_mutex = Mutex.new
    end
    
    def start(endpoint)
      @publisher.start(endpoint)
      
      message_endpoint = @registry.lookup('ais/message')
      @message_service.start(message_endpoint) if message_endpoint

      @checker_thread = Thread.new do
        begin
          loop do
            check_compliance(method(:publish_message), @expected, @last_recv, @last_recv_mutex)
          end
        rescue => e
          @log.fatal("Checker thread exception: #{e.message}")
          e.backtrace.each { |line| @log.fatal(line) }
          puts e.message
          raise
        end
      end

      register_self('ais/compliance', endpoint)
      @log.info("Service started")
    end
    
    def wait
      @message_service.wait and @publisher.wait
    end
    
    def stop
      @checker_thread.kill if @checker_thread
      @message_service.stop
      @publisher.stop
    end
    
    def process_message(data)
      
      @log.debug("Received #{data}")
      
      # Parse fields
      fields = data.split(' ')
      if fields.length != 3
        @log.warn("Incorrect number of fields in incoming message")
        return
      end
      
      type, timestamp, payload = fields[0].to_i, fields[1].to_f, fields[2]
      
      # Decode payload
      decoded = nil
      @registry.bind('ais/payload-decoder') do |decoder|
        decoded = decoder.decode(payload)
      end
      
      # Parse message from payload
      message = Domain::AIS::MessageFactory.fromPayload(decoded)
      mmsi = nil
      if message.nil?
        @log.warn("Message rejected: #{data}")
        return
      else  
        mmsi = message.mmsi
      end
      
      @log.debug("Message with timestamp #{timestamp} and mmsi #{mmsi}")
      
      if type == 5
        @last_recv_mutex.synchronize do
          if not @last_recv.has_key?(mmsi) 
            @last_recv[mmsi] = Queue.new  
          end
          @last_recv[mmsi].push(timestamp)
        end
        
        @expected.push([timestamp, timestamp + 360, mmsi])
      end
    end
    
    def check_compliance(publish_method, expected, last_recv, last_recv_mutex)
      timestamp, exp_timestamp, mmsi = expected.pop
      
      @log.debug("Expected: #{mmsi} on #{exp_timestamp}, timestamp #{timestamp}, it's now #{Time.new.to_f}")
      diff = exp_timestamp - Time.new.to_f
      if diff > 0
        sleep(diff)
      end
      
      compliant = nil
      begin
        while compliant.nil?
          next_ts = last_recv[mmsi].pop(true)
          @log.debug("Next message in queue has ts #{next_ts}")
          if next_ts > timestamp
            compliant = next_ts < exp_timestamp 
          end  
        end
      rescue ThreadError
        compliant = false
      end
              
      if not compliant
        publish_method.call("NON-COMPLIANT #{mmsi}")
      end
    end
    
    def publish_message(mmsi)
      @log.debug("Publishing non-compliance of vessel #{mmsi}")
      @publisher.publish("NON-COMPLIANT #{mmsi}")
    end
  end
end