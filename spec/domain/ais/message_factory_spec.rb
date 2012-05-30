require 'spec_helper'

module Domain::AIS
  describe MessageFactory do
    describe "fromPayload" do
      it "can create a position report message from a payload" do
        payload = "13`wgT0P5fPGmDfN>o?TN?vN2<05"
        mf = MessageFactory.new
        msg = MessageFactory.fromPayload(payload)
        msg.mmsi.should eq(244314000)
        msg.vessel_class.should eq(Domain::Vessel::CLASS_A)
        msg.lat.should be_within(1.0/1_000_000).of(52.834663)
        msg.lon.should be_within(1.0/1_000_000).of(5.206438)
      end
  
      it "can create a static info message from a payload" do
        payload = "53u=:PP00001<H?G7OI0ThuB37G61<F22222220j1042240Ht2P00000000000000000008"
        mf = MessageFactory.new
        msg = MessageFactory.fromPayload(payload)
        msg.mmsi.should eq(265505410)
        msg.vessel_class.should eq(Domain::Vessel::CLASS_A)
        msg.vessel_type.should eq(Domain::VesselType.new(50))
      end
      
      it "returns null for messages of incorrect length" do
        payload = "13`wgT0P5"
        mf = MessageFactory.new
        msg = MessageFactory.fromPayload(payload)
        msg.should eq(nil)
      end      
    end
    
    it "can create position report messages from vessel info" do
      vessel = Domain::Vessel.new(1234, Domain::Vessel::CLASS_A)
      vessel.position = Domain::LatLon.new(3.0, 4.0)  

      mf = MessageFactory.new
      msg = mf.create_position_report(vessel)
      msg.type.should eq(1)
      msg.mmsi.should eq(1234)
      msg.lat.should eq(3.0)
      msg.lon.should eq(4.0)
    end

    it "can create static info messages from vessel info" do
      vessel_type = VesselType.from_str("Tanker")
      vessel = Domain::Vessel.new(1234, Domain::Vessel::CLASS_A)
      vessel.position = Domain::LatLon.new(3.0, 4.0)
      vessel.type = vessel_type  

      mf = MessageFactory.new
      msg = mf.create_static_info(vessel)
      msg.type.should eq(5)
      msg.mmsi.should eq(1234)
      msg.vessel_type.should eq(vessel_type)
    end

  end
end