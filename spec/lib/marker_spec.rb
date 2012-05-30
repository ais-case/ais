require 'spec_helper'

describe Marker do
  it "has an id and position" do
    id = 4242
    position = Domain::LatLon.new(10, 20) 
    marker = Marker.new(id, position)
    marker.id.should eq(id)
    marker.position.should eq(position)
  end

  it "can be created from a Domain::Vessel" do
    vessel = Domain::Vessel.new(4321, Domain::Vessel::CLASS_A)
    vessel.position = Domain::LatLon.new(30, 40)
    marker = Marker.from_vessel(vessel)
    marker.id.should eq(vessel.mmsi)
    marker.position.should eq(vessel.position)
  end
  
  it "can be compared to other markers" do
    m1 = Marker.new(1, Domain::LatLon.new(10, 20))
    m2 = Marker.new(1, Domain::LatLon.new(10, 20))
    m3 = Marker.new(2, Domain::LatLon.new(10, 20))
    m4 = Marker.new(2, Domain::LatLon.new(20, 20))
    
    m1.should eq(m2)
    m2.should_not eq(m3)
    m3.should_not eq(m4)
  end
end