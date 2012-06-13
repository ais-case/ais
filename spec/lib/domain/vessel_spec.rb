require 'spec_helper'

module Domain
  describe Vessel do
    before(:each) do
      @vessel = Vessel.new(1234, Vessel::CLASS_A)
    end
    
    it "requires a mmsi and class" do
      @vessel.mmsi.should eq 1234
      @vessel.vessel_class.should eq Vessel::CLASS_A
    end
    
    it "is compliant by default" do
      @vessel.compliant.should be_true
    end
    
    it "has name and position attributes" do
      @vessel.name = "Seal"
      @vessel.position = LatLon.new(50.0, 4.0)
  
      @vessel.name.should eq "Seal"
      @vessel.position.lat.should eq 50.0
      @vessel.position.lon.should eq 4.0
    end

    it "has navigation_status, heading, speed, anchored, type and compliant attributes" do
      nav_status = Domain::NavigationStatus::from_str('Moored')
      type = VesselType.from_str("Passenger")
      
      @vessel.navigation_status = nav_status
      @vessel.heading = 193
      @vessel.speed = 46.3
      @vessel.anchored = true
      @vessel.type = type
      @vessel.compliant = false
  
      @vessel.navigation_status.should eq(nav_status)
      @vessel.heading.should eq(193)
      @vessel.speed.should be_within(0.1).of(46.3)
      @vessel.anchored.should be_true
      @vessel.type.should eq(type)
      @vessel.compliant.should be_false
    end
    
    it "can be compared to other vessels" do
      v1 = Vessel.new(1234, Vessel::CLASS_A)
      v1.position = LatLon.new(10.0, 4.0)
      v2 = Vessel.new(1234, Vessel::CLASS_A)
      v2.position = LatLon.new(4.0, 4.0)
      v1.should eq(v2)

      v3 = Vessel.new(5678, Vessel::CLASS_A)
      v3.position = LatLon.new(10.0, 4.0)
      v2.should_not eq(v3)
      v1.should_not eq(nil)
    end
    
    it "can be updated with info from another Vessel object" do
      v1 = Vessel.new(1234, Vessel::CLASS_A)
      v1.position = LatLon.new(10.0, 4.0)
      v2 = Vessel.new(1234, Vessel::CLASS_A)
      v2.position = LatLon.new(4.0, 7.0)
      v2.type = VesselType.new(50)
      
      v1.update_from(v2)
      v1.position.should eq(v2.position)
      v1.type.should eq(v2.type)
    end
  end
end