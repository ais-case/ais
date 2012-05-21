module Domain
  class Vessel
    attr_reader :mmsi, :vessel_class
    attr_accessor :name, :position
  
    CLASS_A = 'A'
    CLASS_B = 'B'
  
    def initialize(mmsi, vessel_class)
      @mmsi = mmsi
      @vessel_class = vessel_class
    end
    
    def ==(other)
      (@mmsi == other.mmsi) and 
      (@vessel_class == other.vessel_class)
    end
  end
end