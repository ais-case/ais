require 'spec_helper'

module Domain::AIS
  describe Message do
    it "has mmsi, vessel_class and type properties" do
      m = Message.new(244314000)
      m.mmsi.should eq(244314000)
      m.type.should eq(1)
      m.vessel_class.should eq(Domain::Vessel::CLASS_A)
    end
    
    it "has lat and lon properties" do  
      m = Message.new(244314000)
      m.lat = 1.0
      m.lat.should eq(1.0)
      m.lon = -1.0
      m.lon.should eq(-1.0)
    end    
  end
end