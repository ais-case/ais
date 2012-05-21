module Service
  class VesselService < BaseService
    def initialize
      @vessels = []
      @vessels_mutex = Mutex.new
    end

    def processMessage(payload)
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
    
    def processRequest(request)
      @vessels_mutex.synchronize do
        Marshal.dump(@vessels)
      end
    end
  end
end