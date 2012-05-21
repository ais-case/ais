module Domain::AIS
  class Message
    attr_reader :mmsi, :vessel_class
    attr_accessor :lat, :lon
    
    def initialize(mmsi)
      @mmsi = mmsi
      @vessel_class = Domain::Vessel::CLASS_A
    end
  end
end