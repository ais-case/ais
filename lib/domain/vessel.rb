module Domain
  class Vessel
    attr_reader :mmsi, :vessel_class
    attr_accessor :name, :position, :heading, :speed, :anchored 
    attr_accessor :type, :compliant, :navigation_status
  
    CLASS_A = 'A'
    CLASS_B = 'B'
  
    def initialize(mmsi, vessel_class)
      @mmsi = mmsi
      @vessel_class = vessel_class
      @compliant = true
    end
    
    def update_from(other)
      if @mmsi != other.mmsi
        raise "Trying to update vessel with information from vessel with other MMSI"
      end
      
      if other.vessel_class
        @vessel_class = other.vessel_class
      end
      
      if other.name
        @name = other.name
      end
      
      if other.position
        @position = other.position
      end
      
      if other.heading
        @heading = other.heading
      end
      
      if other.speed
        @speed = other.speed
      end
      
      if other.type
        @type = other.type
      end
    end
    
    def ==(other)
      (other != nil) and
      (@mmsi == other.mmsi) and 
      (@vessel_class == other.vessel_class)
    end
  end
end