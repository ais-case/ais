require_relative 'platform/service_proxy'

module Service
  class VesselProxy < Platform::ServiceProxy
    def vessels(*args)
      if args.length == 2
        req = Marshal.dump([args[0], args[1]]) 
      else
        req = ''  
      end
      @socket.send_string(req)
      @socket.recv_string(message = "")
      
      # Make sure Ruby knows about the unmarshalled classes
      Domain::Vessel.class
      Domain::LatLon.class

      return Marshal.load(message)
    end
  end
end
