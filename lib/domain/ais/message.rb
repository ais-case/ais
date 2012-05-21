module Domain::AIS
  class Message
    attr_reader :mmsi
    
    def initialize(mmsi)
      @mmsi = mmsi
    end
  end
end