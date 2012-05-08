class Vessel
    attr_reader :vessel_class
    attr_accessor :name, :position
    
    CLASS_A = 'A'
    CLASS_B = 'B'

    def initialize(vessel_class)
        @vessel_class = vessel_class
    end
end
