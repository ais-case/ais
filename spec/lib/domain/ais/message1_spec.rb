require 'spec_helper'

module Domain::AIS
  describe Message1 do
    it "has mmsi, vessel_class and type properties" do
      m = Message1.new(244314000)
      m.mmsi.should eq(244314000)
      m.type.should eq(1)
      m.vessel_class.should eq(Domain::Vessel::CLASS_A)
      m.navigation_status.should eq(Domain::NavigationStatus::from_str('Undefined'))
    end
    
    it "has lat, lon, speed, heading, navigation_status properties" do  
      m = Message1.new(244314000)
      m.lat = 1.0
      m.lat.should eq(1.0)
      m.lon = -1.0
      m.lon.should eq(-1.0)
      m.speed = 53.6
      m.speed.should be_within(0.01).of(53.6)
      m.heading = 35
      m.heading.should eq(35)
      m.navigation_status = Domain::NavigationStatus::from_str('Anchored')
      m.navigation_status.should eq(Domain::NavigationStatus::from_str('Anchored'))
    end
    
    describe "payload" do
      it "returns the payload as bit string" do
        m = Message1.new(1234)
        m.lat = 3.0
        m.lon = 4.0
        m.speed = 54.1
        m.heading = 253
        m.navigation_status = Domain::NavigationStatus::from_str('Moored')
        Domain::AIS::SixBitEncoding.encode(m.payload).should eq("10004lU08M0BCp01eo@007r00000")
      end

      it "correctly encodes when no speed and heading are provided" do
        m = Message1.new(1234)
        m.lat = 3.0
        m.lon = 4.0
        Domain::AIS::SixBitEncoding.encode(m.payload).should eq("10004lg0?w0BCp01eo@00?v00000")
      end
    end
  end
end