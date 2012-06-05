require 'spec_helper'

describe Marker do
  it "has an id, position and icon" do
    id = 4242
    position = Domain::LatLon.new(10, 20) 
    marker = Marker.new(id, position, 'v.png')
    marker.id.should eq(id)
    marker.position.should eq(position)
    marker.icon.should eq('v.png')
    marker.line.should eq(nil)
  end

  it "can be compared to other markers" do
    m1 = Marker.new(1, Domain::LatLon.new(10, 20), 'v.png')
    m2 = Marker.new(1, Domain::LatLon.new(10, 20), 'v.png')
    m3 = Marker.new(2, Domain::LatLon.new(10, 20), 'v.png')
    m4 = Marker.new(2, Domain::LatLon.new(20, 20), 'v.png')
    m5 = Marker.new(2, Domain::LatLon.new(20, 20), 'v_n.png')
    
    m1.should eq(m2)
    m2.should_not eq(m3)
    m3.should_not eq(m4)
    m4.should_not eq(m5)
  end
end