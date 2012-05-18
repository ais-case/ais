require 'spec_helper'
require 'domain/vessel'
require 'domain/latlon'

describe Vessel do
  it "requires a mmsi and class" do
    vessel = Vessel.new(1234, Vessel::CLASS_A)
    vessel.mmsi.should eq 1234
    vessel.vessel_class.should eq Vessel::CLASS_A
  end
  
  it "has name and position attributes" do
    vessel = Vessel.new(1234, Vessel::CLASS_A)
    vessel.name = "Seal"
    vessel.position = LatLon.new 50.0, 4.0

    vessel.name.should eq "Seal"
    vessel.position.lat.should eq 50.0
    vessel.position.lon.should eq 4.0
  end
  
  it "can be compared to other vessels" do
    v1 = Vessel.new(1234, Vessel::CLASS_A)
    v1.position = LatLon.new(10.0, 4.0)
    v2 = Vessel.new(1234, Vessel::CLASS_A)
    v2.position = LatLon.new(10.0, 4.0)
    v3 = Vessel.new(5678, Vessel::CLASS_A)
    v3.position = LatLon.new(10.0, 4.0)
    v1.should eq(v2)
    v2.should_not eq(v3)
    
    v2.position = LatLon.new(0.0, 0.0)
    v1.should_not eq(v2)
  end
end
