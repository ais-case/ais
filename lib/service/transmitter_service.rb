require 'socket'
require_relative '../util'
require_relative '../domain/vessel'
require_relative '../domain/vessel_type'
require_relative '../domain/lat_lon'
require_relative '../domain/ais/checksums'
require_relative '../domain/ais/datatypes'
require_relative '../domain/ais/six_bit_encoding'
require_relative '../domain/ais/message_factory'
require_relative 'platform/base_service'
require_relative 'platform/reply_service'
require_relative 'platform/subscriber_service'
require_relative 'platform/publisher_service'

module Service
  class TransmitterService < Platform::BaseService
    def initialize(registry)
      super(registry)
      @log = Util::get_log('transmitter')
      @reply_service = Platform::ReplyService.new(method(:process_request), @log)
      @source = Platform::SubscriberService.new(method(:process_raw_message), [''], @log)
      @publisher = Platform::PublisherService.new(@log)
    end
    
    def start(endpoint)
      @log.debug("Starting service")
      @reply_service.start(endpoint)
      
      @publisher.start('tcp://*:20000')
      @registry.register('ais/transmitter-pub', 'tcp://localhost:20000')

      if ENV.has_key?('RAILS_ENV') and ENV['RAILS_ENV'] == 'test'
        ais_source = nil 
      else
        ais_source = 'tcp://82.210.120.176:21000' 
      end

      if not ais_source.nil?      
        @log.debug("Added AIS source #{ais_source}")
        @source.start(ais_source)
      end
      
      register_self('ais/transmitter', endpoint)
      @log.info("Service started")
    end
    
    def wait
      @reply_service.wait
      @publisher.wait
    end
    
    def stop
      @reply_service.stop
      @publisher.stop
      @source.stop
      @log.info("Service stopped")
    end
        
    def process_raw_message(data)
      return if data[0] == '#'
      i = data.index('!')
      return unless i
      if i > 0
        timestamp = data[0..i-1].strip
      else 
        timestamp = "%0.9f" % Time.new.to_f
      end
      fragment = data[i..-1].strip
      broadcast_message(timestamp, fragment)
    end
    
    def broadcast_message(timestamp, message)
      @publisher.publish("%s %s" % [timestamp, message])
    end
    
    def process_request(data)
      # Make sure Ruby knows about the unmarshalled classes
      Domain::Vessel.class
      Domain::LatLon.class
      
      type_end = data.index(' ')
      type = data[0..(type_end - 1)]
      args = Marshal.load(data[(type_end + 1)..-1])
      vessel = args[0]
      timestamp = args[1]
      
      fragments = []
      message_factory = Domain::AIS::MessageFactory.new
      if type == 'POSITION'
        message = message_factory.create_position_report(vessel)
      elsif type == 'STATIC'
        message = message_factory.create_static_info(vessel)
      else
        @log.error("Invalid request type: #{type}")
        return ''        
      end
      
      # Create the fragments
      encoded = nil
      @registry.bind('ais/payload-encoder') do |encoder|
        encoded = encoder.encode(message.payload)  
      end
      
      chunk_no = 1
      chunks = encoded.scan(/.{1,56}/)
      chunks.each do |chunk|
        fragment = "!AIVDM,#{chunks.length},#{chunk_no},,A,#{chunk},0"
        packet = Domain::AIS::Checksums::add(fragment) << "\n"
        prefix = "%0.9f" % timestamp
        process_raw_message(prefix + packet)
        chunk_no += 1  
      end 
      
      # Empty response
      ''
    end  
  end
end