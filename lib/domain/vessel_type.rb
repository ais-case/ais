module Domain
  class VesselType
    attr_reader :code, :description
    
    TYPES = [
              {:code => 60, :description => "Passenger"},
              {:code => 70, :description => "Cargo"},
              {:code => 80, :description => "Tanker"},
            ]
            
    def self.from_str(description)
      index = TYPES.index {|t| t[:description] == description}
      type = TYPES[index]
      VesselType.new(type[:code], type[:description]) 
    end
    
    def initialize(code, description)
      @code = code
      @description = description
    end
  end  
end
