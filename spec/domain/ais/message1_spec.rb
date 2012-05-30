require 'spec_helper'

module Domain::AIS
  describe Message1 do
    it "has mmsi, vessel_class and type properties" do
      m = Message1.new(244314000)
      m.mmsi.should eq(244314000)
      m.type.should eq(1)
      m.vessel_class.should eq(Domain::Vessel::CLASS_A)
    end
    
    it "has lat, lon, speed and heading properties" do  
      m = Message1.new(244314000)
      m.lat = 1.0
      m.lat.should eq(1.0)
      m.lon = -1.0
      m.lon.should eq(-1.0)
      m.speed = 53.6
      m.speed.should be_within(0.01).of(53.6)
      m.heading = 35
      m.heading.should eq(35)
    end
    
    describe "payload" do
      it "returns the payload as bit string" do
        m = Message1.new(1234)
        m.lat = 3.0
        m.lon = 4.0
        m.speed = 54.1
        m.heading = 253
        Domain::AIS::SixBitEncoding.encode(m.payload).should eq("10004lP08M0BCp01eo@007r000000")
      end
    end
  end
end