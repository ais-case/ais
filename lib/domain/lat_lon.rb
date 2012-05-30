module Domain
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
  
    def ==(other)
      (@lat == other.lat) and (@lon == other.lon) 
    end
  
    def to_s
      lat_suffix = @lat > 0 ? 'N' : 'S'
      lon_suffix = @lon > 0 ? 'E' : 'W' 
      "#{@lat.abs}#{lat_suffix}, #{@lon.abs}#{lon_suffix}"
    end
  end
end