require_relative '../domain/vessel'
require_relative '../domain/lat_lon'
require_relative '../domain/ais/message_factory'
require_relative 'platform/base_service'
require_relative 'platform/reply_service'
require_relative 'platform/subscriber_service'
require_relative '../util'

module Service
  class VesselService < Platform::BaseService
    def initialize(registry)
      super(registry)
      @log = Util::get_log('vessel')
      @vessels = {}
      @vessels_mutex = Mutex.new
      @reply_service = Platform::ReplyService.new(method(:process_request), @log)
      filter = ['1 ', '2 ', '3 ', '5 ', '18 ', '19 ', '24 ']
      @message_service = Platform::SubscriberService.new(method(:process_message), filter, @log)
    end
    
    def start(endpoint)
      @log.debug("Starting service")
      super(endpoint)
      
      message_endpoint = @registry.lookup('ais/message')
      @message_service.start(message_endpoint) if message_endpoint
      @reply_service.start(endpoint)
      
      register_self('ais/vessel', endpoint)
      @log.info("Service started")
    end
    
    def wait
      @reply_service.wait
    end

    def stop
      @reply_service.stop
      @message_service.stop
      super
    end

    def process_message(data)
      @log.debug("Message incoming: #{data}")
      payload = data.split(' ')[1]
      message = Domain::AIS::MessageFactory.fromPayload(payload)
      if message.nil?
        @log.debug("Message rejected: #{data}")
      else  
        vessel = Domain::Vessel.new(message.mmsi, message.vessel_class)
        if message.respond_to?(:lat) and message.respond_to?(:lon)
          vessel.position = Domain::LatLon.new(message.lat, message.lon)
        end
        if message.respond_to?(:speed)
          vessel.speed = message.speed
        end
        if message.respond_to?(:heading)
          vessel.heading = message.heading
        end
        if message.respond_to?(:vessel_type)
          vessel.type = message.vessel_type
        end
          
        receiveVessel(vessel)
      end
    end
    
    def receiveVessel(vessel)
      @log.debug("Adding vessel with MMSI #{vessel.mmsi}")
      @vessels_mutex.synchronize do
        if @vessels.has_key?(vessel.mmsi)
          @log.debug("Updating vessel #{vessel.class.name}")
          @vessels[vessel.mmsi].update_from(vessel)
        else
          @log.debug("Adding vessel #{vessel.class.name}")
          @vessels[vessel.mmsi] = vessel
        end
      end
    end
    
    def process_request(request)
      index = request.index(' ')
      if index
        cmd = request[0..(index - 1)]
        args = request[(index + 1)..-1]
      else
        cmd = request
        args = nil
      end

      if cmd == 'LIST'
        process_list_request(args)
      elsif cmd == 'INFO'
        process_info_request(args)
      end
    end
    
    def process_list_request(args)
      @vessels_mutex.synchronize do
        if args
          @log.debug("Processing request for filtered set of vessels")
          latlons = Marshal.load(args)
          @log.debug("Latlons: #{latlons}")
          lats = [latlons[0].lat, latlons[1].lat]
          lons = [latlons[0].lon, latlons[1].lon]
          vessels = @vessels.values.select do |vessel|
            @log.debug("Vessel: #{vessel.position}")
            vessel.position.lat.between?(lats.min, lats.max) and
            vessel.position.lon.between?(lons.min, lons.max)
          end
        else
          @log.debug("Processing request for all vessels")          
          vessels = @vessels.values          
        end
        @log.debug("#{vessels.length} vessels returned")
        Marshal.dump(vessels)
      end      
    end
    
    def process_info_request(args)
      if args
        mmsi = args.to_i
        @log.debug("Processing info request for vessel #{mmsi}")
        
        @vessels_mutex.synchronize do
          vessels = @vessels.values.select { |v| v.mmsi == mmsi }
          
          if vessels.length == 1
            Marshal.dump(vessels[0])
          else
            @log.error("No vessel found with mmsi #{mmsi}")
          end
        end
      else
        @log.error("Info request without mmsi")
      end      
    end
  end
end