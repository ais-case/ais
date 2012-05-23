require_relative 'platform/service_proxy'

module Service
  class VesselServiceProxy < Platform::ServiceProxy
    def vessels
      @socket.send_string("")
      @socket.recv_string(message = "")
      
      # Make sure Ruby knows about the unmarshalled classes
      Domain::Vessel.class
      Domain::LatLon.class

      return Marshal.load(message)
    end
  end
end
