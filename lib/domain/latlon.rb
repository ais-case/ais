class LatLon
    attr_reader :lat, :lon
    
    def initialize(lat, lon)
        @lat = lat
        @lon = lon    
    end
    
    def self.from_str(str)
        pattern = /^(?<latnum>\d+(\.\d+)?)(?<ns>[NS]),\s*(?<lonnum>\d+(\.\d+)?)(?<ew>[EW])$/i
        if pattern =~ str
            lat = $~[:latnum].to_f
            if $~[:ns].upcase == 'S'
                lat = -lat
            end
            
            lon = $~[:lonnum].to_f
            if $~[:ew].upcase == 'W'
                lon = -lon
            end
            
            LatLon.new lat, lon
        else
            raise ArgumentError, "Unrecognized format"
        end
    end
end