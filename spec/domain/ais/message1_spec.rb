require 'spec_helper'

module Domain::AIS
  describe Message1 do
    it "has mmsi, vessel_class and type properties" do
      m = Message1.new(244314000)
      m.mmsi.should eq(244314000)
      m.type.should eq(1)
      m.vessel_class.should eq(Domain::Vessel::CLASS_A)
    end
    
    it "has lat and lon properties" do  
      m = Message1.new(244314000)
      m.lat = 1.0
      m.lat.should eq(1.0)
      m.lon = -1.0
      m.lon.should eq(-1.0)
    end
    
    describe "payload" do
      it "returns the payload as bit string" do
        m = Message1.new(1234)
        m.lat = 3.0
        m.lon = 4.0
        Domain::AIS::SixBitEncoding.encode(m.payload).should eq("10004lP0000BCp01eo@0000000000")
      end
    end
  end
end