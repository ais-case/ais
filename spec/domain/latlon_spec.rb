require "spec_helper"
require "domain/latlon"

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
end
