require 'spec_helper'

describe MarkerFactory do
  describe "from_vessel" do
    it "can create a marker from a Domain::Vessel" do
      vessel = Domain::Vessel.new(4321, Domain::Vessel::CLASS_A)
      marker = MarkerFactory.from_vessel(vessel)
      marker.id.should eq(vessel.mmsi)
      marker.position.should eq(vessel.position)
      marker.icon.should eq('v_a.png')
    end
    
    it "can create a marker with a line from a Domain::Vessel" do
      vessel = Domain::Vessel.new(4321, Domain::Vessel::CLASS_A)
      vessel.heading = 60
      vessel.speed = 30.0
      marker = MarkerFactory.from_vessel(vessel)
      marker.id.should eq(vessel.mmsi)
      marker.line.direction.should eq(225)
      marker.line.length.should be_within(0.1).of(30.0);
    end

    it "only lines for non-stationary vessels" do
      vessel = Domain::Vessel.new(4321, Domain::Vessel::CLASS_A)
      vessel.heading = 60
      vessel.speed = 0.05
      marker = MarkerFactory.from_vessel(vessel)
      marker.line.should be_nil      
    end

    it "line has a minimum length" do
      vessel = Domain::Vessel.new(4321, Domain::Vessel::CLASS_A)
      vessel.heading = 60
      vessel.speed = 10.0
      marker = MarkerFactory.from_vessel(vessel)
      marker.line.length.should be_within(0.1).of(10.0)
      
      vessel.speed = 1.0
      marker = MarkerFactory.from_vessel(vessel)
      marker.line.length.should be_within(0.1).of(10.0)
    end

    it "line has a maximum length" do
      vessel = Domain::Vessel.new(4321, Domain::Vessel::CLASS_A)
      vessel.heading = 60
      vessel.speed = 30.0
      marker = MarkerFactory.from_vessel(vessel)
      marker.line.length.should be_within(0.1).of(30.0)
      
      vessel.speed = 50.0
      marker = MarkerFactory.from_vessel(vessel)
      marker.line.length.should be_within(0.1).of(30.0)
    end
  end
  
  describe "icon_from_vessel" do
    it "chooses the correct icon based on heading" do
      vessel = Domain::Vessel.new(4321, Domain::Vessel::CLASS_A)
      marker = MarkerFactory.from_vessel(vessel)
      
      {10 => 'n', 80 => 'e', 138 => 'se'}.each do |heading,icon|
        vessel.heading = heading
        marker = MarkerFactory.from_vessel(vessel)
        marker.icon.should eq("v_a_#{icon}.png")
      end
    end
    
    it "chooses the correct icon based on vessel class" do
      vessel_a = Domain::Vessel.new(4321, Domain::Vessel::CLASS_A)
      vessel_a.heading = 90
      marker = MarkerFactory.from_vessel(vessel_a)
      marker.icon.should eq("v_a_e.png")

      vessel_b = Domain::Vessel.new(4321, Domain::Vessel::CLASS_B)
      vessel_b.heading = 90
      marker = MarkerFactory.from_vessel(vessel_b)
      marker.icon.should eq("v_b_e.png")      
    end

    it "chooses the correct icon based on vessel type" do
      vessel = Domain::Vessel.new(4321, Domain::Vessel::CLASS_A)
      marker = MarkerFactory.from_vessel(vessel)
      
      colors = {'Passenger' => 'green', 'Fishing' => 'grey', 'Cargo' => 'blue',
                'Tanker' => 'black', 'Military' => 'white', 'Other' => 'yellow'}
      
      colors.each do |type,color|
        vessel.type = Domain::VesselType.from_str(type)
        marker = MarkerFactory.from_vessel(vessel)
        marker.icon.should eq("v_a_#{color}.png")
      end
    end
    
    it "chooses the correct icon for non-compliant vessels" do
      vessel = Domain::Vessel.new(4321, Domain::Vessel::CLASS_A)
      vessel.compliant = false
      marker = MarkerFactory.from_vessel(vessel)
      marker.icon.should eq("v_a_red.png")
    end
  end
end