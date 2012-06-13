require 'ffi-rzmq'
require 'socket'
require_relative '../util'
require_relative '../domain/ais/message_factory'
require_relative '../domain/navigation_status'
require_relative 'platform/base_service'
require_relative 'platform/subscriber_service'
require_relative 'platform/publisher_service'

module Service
  class ComplianceService < Platform::BaseService
    attr_reader :dynamic_messages
    attr_writer :expected, :dynamic_received
    
    def initialize(registry)
      super(registry)
      @registry = registry
      @log = Util::get_log('compliance')
      filter = ['1 ', '2 ', '3 ', '5 ']
      @message_service = Platform::SubscriberService.new(method(:process_message), filter, @log)
      @publisher = Platform::PublisherService.new(@log)
      @checker_thread = nil
      @dynchecker_thread = nil
      @expected = Queue.new
      @dynamic_received = Queue.new
      @dynamic_messages = {}
      @dynamic_buffered = {}
      @last_recv = {}
      @next_ts = {}
    end
    
    def start(endpoint)
      @publisher.start(endpoint)
      
      message_endpoint = @registry.lookup('ais/message')
      @message_service.start(message_endpoint) if message_endpoint

      @checker_thread = Thread.new do
        begin
          loop do
            check_compliance(method(:publish_message), @expected, @last_recv)
          end
        rescue => e
          @log.fatal("Checker thread exception: #{e.message}")
          e.backtrace.each { |line| @log.fatal(line) }
          puts e.message
          raise
        end
      end

      @dynchecker_thread = Thread.new do
        begin
          loop do
            check_dynamic_compliance(method(:publish_message), @dynamic_received, @dynamic_messages)
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
      @dynchecker_thread.kill if @dynchecker_thread
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
      
      @log.debug("Message #{payload} with timestamp #{timestamp} and mmsi #{mmsi}")

      if type == 1 or type == 2 or type == 3
        if not @dynamic_messages.has_key?(mmsi)
          @dynamic_messages[mmsi] = Queue.new
        end
        @dynamic_messages[mmsi].push([timestamp, message])
        @dynamic_received.push(mmsi)
      end

      if not @last_recv.has_key?(mmsi)
        @log.debug("New vessel with mmsi #{mmsi}")
        @last_recv[mmsi] = Queue.new
      end

      if type == 5
        @log.debug("Registered reception of message type 5 from #{mmsi}")
        @last_recv[mmsi].push(timestamp)
      end
      
      @expected.push([timestamp, timestamp + 360, mmsi])
    end
    
    def check_compliance(publish_method, expected, last_recv)
      timestamp, exp_timestamp, mmsi = expected.pop

      @log.debug("Expected: #{mmsi} on #{exp_timestamp}, timestamp #{timestamp}, it's now #{Time.new.to_f}")
      diff = exp_timestamp - Time.new.to_f
      if diff > 0
        sleep(diff)
      end
      
      compliant = nil
      if @next_ts.has_key?(mmsi) and (@next_ts[mmsi] - 0.001) < exp_timestamp
        compliant = true
      else
        begin
          while compliant.nil?
            next_ts = last_recv[mmsi].pop(true)
            if next_ts > timestamp
              # Check if message is within expected window, with
              # grace period of 0.001s
              compliant = (next_ts - 0.001) < exp_timestamp 
            end
            @next_ts[mmsi] = next_ts
          end
        rescue ThreadError
          compliant = false
        end
      end
            
      @log.debug("Vessel #{mmsi} compliant: #{compliant}")
      
      if not compliant
        publish_method.call(mmsi)
      end
    end

    def check_dynamic_compliance(publish_method, received, receptions)
      mmsi = received.pop
      @log.debug("Processing messages for vessel #{mmsi}")
      
      if @dynamic_buffered.has_key?(mmsi)
        prev_reception = @dynamic_buffered[mmsi]
      else
        # Should never throw an exception, if received could be popped 
        # there should always be a message in the queue. Using non-blocking
        # pop anyway to fail early if this is not the case.
        prev_reception = receptions[mmsi].pop(true)
      end
      
      compliant = true
      begin
        loop do
          reception = receptions[mmsi].pop(true)
          timestamp, message = reception
          prev_timestamp, prev_message = prev_reception
          
          if message.speed and prev_message.speed
            min_speed = [message.speed, prev_message.speed].min
          else
            min_speed = 0.0  
          end
          
          course_changed = false
          if message.heading and prev_message.heading
            heading_change = (message.heading - prev_message.heading).abs
            course_changed = (heading_change > 5)
          end
          
          @log.debug("Headings: #{message.heading} and #{prev_message.heading}")
          @log.debug("Course changed: #{course_changed}")

          anchored = message.navigation_status == Domain::NavigationStatus::from_str('Anchored')
          moored = message.navigation_status == Domain::NavigationStatus::from_str('Moored') 

          @log.debug("Navigation status, moored: #{moored}, anchored #{anchored}")

          if anchored or moored
            if min_speed > 3.0
              interval = 10.0
            else 
              interval = 180.0
            end            
          elsif course_changed
            if min_speed > 23.0
              interval = 2.0
            elsif min_speed > 14.0
              interval = 2.0
            else 
              interval = 3.5
            end
          else
            if min_speed > 23.0
              interval = 2.0
            elsif min_speed > 14.0
              interval = 6.0
            else 
              interval = 10.0
            end            
          end

          @log.debug("Expected interval #{interval}")
          
          if timestamp - prev_timestamp > interval
            compliant = false
          end
          prev_reception = reception
        end
      rescue ThreadError
        @dynamic_buffered[mmsi] = prev_reception
      end

      @log.debug("Vessel #{mmsi} compliant: #{compliant}")

      if not compliant
        publish_method.call(mmsi)
      end
    end
    
    def publish_message(mmsi)
      @log.debug("Publishing non-compliance of vessel #{mmsi}")
      @publisher.publish("NON-COMPLIANT #{mmsi}")
    end
  end
end
