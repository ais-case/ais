module Domain
  class NavigationStatus
    attr_reader :code, :description
    
    STATUS = {
      0 => "Underway using engine",
      1 => "Anchored",
      2 => "Not under command",
      3 => "Restricted manoeuverability",
      4 => "Constrained by draught",
      5 => "Moored",
      6 => "Aground",
      7 => "Fishing",
      8 => "Underway sailing",
      (9..14) => "Reserved for future use",
      15 => "Undefined",    
    }

    def self.from_str(description)
      codes = STATUS.key(description)
      raise ArgumentError, "Invalid description" if codes == nil
      if codes.is_a? Integer
        code = codes
      else
        code = codes.begin  
      end
      
      NavigationStatus.new(code) 
    end
    
    def initialize(code)
      @code = code
      
      STATUS.each do |k,description|
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
