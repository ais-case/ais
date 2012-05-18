module Service
  class VesselService < BaseService
    def initialize
      @vessels = []
      @vessels_mutex = Mutex.new
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