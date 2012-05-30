require 'spec_helper'

module Domain::AIS
  describe Message24 do
    it "has mmsi and type properties" do
      m = Message24.new(244314000)
      m.type.should eq(24)
    end
    
    it "has a vessel_class property" do
      m = Message24.new(244314000)
      m.vessel_class.should eq(Domain::Vessel::CLASS_B)  
    end
    
    it "has a vessel_type property" do
      vt = Domain::VesselType.from_str('Passenger')
        
      m = Message24.new(244314000)
      m.vessel_type.should eq(nil)
      m.vessel_type = vt 
      m.vessel_type.should eq(vt)
    end    
    
    describe "payload" do
      it "returns the payload as bit string" do
        expected = "H0004lTt00000000000000000000"
        m = Message24.new(1234)
        m.vessel_type = Domain::VesselType.from_str('Passenger')
        Domain::AIS::SixBitEncoding.encode(m.payload).should eq(expected)
      end
    end
  end
end