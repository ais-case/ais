module Domain
  class VesselType
    attr_reader :code, :description
    
    TYPES = {
      0 => "Not available (default)",
      (1..19) => "Reserved for future use",
      (20..29) => "Wing in ground",
      30 => "Fishing",
      (31..32) => "Towing",
      33 => "Dredging or underwater ops",
      34 => "Diving ops",
      35 => "Military ops",
      36 => "Saling",
      37 => "Pleasure craft",
      (38..39) => "Reserved",
      (40..49) => "High speed craft",    
      50 => "Pilot vessel",
      51 => "Search and rescure",
      52 => "Tug",
      53 => "Port tender",
      54 => "Anti-polution equipment",
      55 => "Law enforcement",
      (56..57) => "Local vessel",
      58 => "Medical transport",
      59 => "Noncombatant vessel according to RR resolution no. 18",
      (60..69) => "Passenger",
      (70..79) => "Cargo",
      (80..89) => "Tanker",
      (90..99) => "Other",    
    }

    def self.from_str(description)
      codes = TYPES.key(description)
      raise ArgumentError, "Invalid description" if codes == nil
      if codes.is_a? Integer
        code = codes
      else
        code = codes.begin  
      end
      
      VesselType.new(code) 
    end
    
    def initialize(code)
      @code = code
      
      TYPES.each do |k,description|
        if k.is_a?(Integer) and k == code then
          @description = description
          break  
        elsif not k.is_a?(Integer) and k.include?(code) then
          @description = description  
          break
        end
      end
    end
    
    def ==(other)
      (other != nil) and (@code == other.code)
    end
  end  
end
