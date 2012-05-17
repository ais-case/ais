require 'spec_helper'
require 'domain/latlon'

describe LatLon do
    it "can create a new LatLon from a string" do
      latlon = LatLon.from_str "47.16N, 9.66E"
      latlon.lat.should eq 47.16
      latlon.lon.should eq 9.66

      latlon = LatLon.from_str "47.16N, 9.66W"
      latlon.lat.should eq 47.16
      latlon.lon.should eq -9.66

      latlon = LatLon.from_str "47.16S, 9.66W"
      latlon.lat.should eq -47.16
      latlon.lon.should eq -9.66

      latlon = LatLon.from_str "47.16S, 9.66E"
      latlon.lat.should eq -47.16
      latlon.lon.should eq 9.66

      latlon = LatLon.from_str "47N, 9E"
      latlon.lat.should eq 47.0
      latlon.lon.should eq 9.0
    end
    
    it "rejects invalid string input" do
      expect { LatLon.from_str " 1.1N, 9.6E" }.to raise_error
      expect { LatLon.from_str "1.1 N, 9.6E" }.to raise_error
      expect { LatLon.from_str "1 1.1N, 9.6E" }.to raise_error
    end
    
    it 'can be converted to a string' do
      latlon = LatLon.from_str "47.16N, 9.66W"
      latlon.to_s.should eq "47.16,-9.66"
    end
    
    it "can be compared to other LatLon objects" do
      l = LatLon.new(1.0, 2.5)
      
      l.should eq(LatLon.new(1.0, 2.5))
      l.should_not eq(LatLon.new(2.0, 2.5))
      l.should_not eq(LatLon.new(1.0, 2.0))
    end
end
