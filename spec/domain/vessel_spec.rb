require 'spec_helper'
require 'domain/vessel'
require 'domain/latlon'

describe Vessel do
  it "has vessel_class, name and position attributes" do
    vessel = Vessel.new Vessel::CLASS_A
    vessel.name = "Seal"
    vessel.position = LatLon.new 50.0, 4.0

    vessel.vessel_class.should eq Vessel::CLASS_A
    vessel.name.should eq "Seal"
    vessel.position.lat.should eq 50.0
    vessel.position.lon.should eq 4.0
  end
end
