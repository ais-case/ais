require_relative '../domain/vessel'
require_relative '../domain/lat_lon'
require_relative '../domain/ais/message_factory'
require_relative 'platform/base_service'
require_relative 'platform/reply_service'
require_relative 'platform/subscriber_service'

module Service
  class VesselService < Platform::BaseService
    def initialize(registry)
      super(registry)
      @vessels = {}
      @vessels_mutex = Mutex.new
      @reply_service = Platform::ReplyService.new(method(:process_request))
      @message_service = Platform::SubscriberService.new(method(:process_message), ['1 '])
    end
    
    def start(endpoint)
      super(endpoint)
      
      message_endpoint = @registry.lookup('ais/message')
      @message_service.start(message_endpoint) if message_endpoint
      @reply_service.start(endpoint)
      
      register_self('ais/vessel', endpoint)
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
      payload = data.split(' ')[1]
      message = Domain::AIS::MessageFactory.fromPayload(payload)
      vessel = Domain::Vessel.new(message.mmsi, message.vessel_class)
      vessel.position = Domain::LatLon.new(message.lat, message.lon)
      receiveVessel(vessel)
    end
    
     def receiveVessel(vessel)
      @vessels_mutex.synchronize do
        @vessels[vessel.mmsi] = vessel
      end
    end
    
    def process_request(request='')
      @vessels_mutex.synchronize do
        if request.length == 0
            Marshal.dump(@vessels.values)
        else  
          latlons = Marshal.load(request)
          lats = [latlons[0].lat, latlons[1].lat]
          lons = [latlons[0].lon, latlons[1].lon]
          filtered = @vessels.values.select do |vessel|
            vessel.position.lat.between?(lats.min, lats.max) and
            vessel.position.lon.between?(lons.min, lons.max)
          end
          Marshal.dump(filtered)     
        end
      end
    end
  end
end