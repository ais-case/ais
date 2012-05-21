module Service
  class VesselService < BaseService
    def initialize(registry)
      super(registry)
      @vessels = []
      @vessels_mutex = Mutex.new
      @reply_service = ReplyService.new(method(:process_request))
      @message_service = SubscriberService.new(method(:process_message), ['1 '])
    end
    
    def start(endpoint)
      super(endpoint)
      
      @message_service.start('tcp://localhost:24000')
      @reply_service.start(endpoint)
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
      @vessels << vessel
    end
    
     def receiveVessel(vessel)
      @vessels_mutex.synchronize do
        @vessels << vessel
      end
    end
    
    def process_request(request)
      @vessels_mutex.synchronize do
        Marshal.dump(@vessels)
      end
    end
  end
end