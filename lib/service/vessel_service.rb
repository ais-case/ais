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
      @message_service = Platform::SubscriberService.new(method(:process_message), ['1 ', '2 ', '3 '], @log)
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
        vessel.position = Domain::LatLon.new(message.lat, message.lon)
        receiveVessel(vessel)
      end
    end
    
    def receiveVessel(vessel)
      @log.debug("Adding vessel with MMSI #{vessel.mmsi}")
      @vessels_mutex.synchronize do
        @vessels[vessel.mmsi] = vessel
      end
    end
    
    def process_request(request='')      
      @vessels_mutex.synchronize do
        if request.length == 0
          @log.debug("Processing request for all vessels")
          vessels = @vessels.values
        else
          @log.debug("Processing request for filtered set of vessels")
          latlons = Marshal.load(request)
          @log.debug("Latlons: #{latlons}")
          lats = [latlons[0].lat, latlons[1].lat]
          lons = [latlons[0].lon, latlons[1].lon]
          vessels = @vessels.values.select do |vessel|
            @log.debug("Vessel: #{vessel.position}")
            vessel.position.lat.between?(lats.min, lats.max) and
            vessel.position.lon.between?(lons.min, lons.max)
          end
        end
        @log.debug("#{vessels.length} vessels returned")
        Marshal.dump(vessels)     
      end
    end
  end
end