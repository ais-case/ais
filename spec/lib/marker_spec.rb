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

  describe "from_vessel" do
    it "can create a marker from a Domain::Vessel" do
      vessel = Domain::Vessel.new(4321, Domain::Vessel::CLASS_A)
      marker = Marker.from_vessel(vessel)
      marker.id.should eq(vessel.mmsi)
      marker.position.should eq(vessel.position)
      marker.icon.should eq('v_a.png')
    end
    
    it "can create a marker with a line from a Domain::Vessel" do
      vessel = Domain::Vessel.new(4321, Domain::Vessel::CLASS_A)
      vessel.heading = 60
      vessel.speed = 30.0
      marker = Marker.from_vessel(vessel)
      marker.id.should eq(vessel.mmsi)
      marker.line.direction.should eq(240)
      marker.line.length.should eq(0.1)
    end
  end
  
  describe "icon_from_vessel" do
    it "chooses the correct icon based on heading" do
      vessel = Domain::Vessel.new(4321, Domain::Vessel::CLASS_A)
      marker = Marker.from_vessel(vessel)
      
      {10 => 'n', 80 => 'e', 138 => 'se'}.each do |heading,icon|
        vessel.heading = heading
        marker = Marker.from_vessel(vessel)
        marker.icon.should eq("v_a_#{icon}.png")
      end
    end
    
    it "chooses the correct icon based on vessel class" do
      vessel_a = Domain::Vessel.new(4321, Domain::Vessel::CLASS_A)
      vessel_a.heading = 90
      marker = Marker.from_vessel(vessel_a)
      marker.icon.should eq("v_a_e.png")

      vessel_b = Domain::Vessel.new(4321, Domain::Vessel::CLASS_B)
      vessel_b.heading = 90
      marker = Marker.from_vessel(vessel_b)
      marker.icon.should eq("v_b_e.png")      
    end
  end
end