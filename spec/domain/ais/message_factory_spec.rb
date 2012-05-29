require 'spec_helper'

module Domain::AIS
  describe MessageFactory do
    it "can create a message object from a payload" do
      payload = "13`wgT0P5fPGmDfN>o?TN?vN2<05"
      mf = MessageFactory.new
      msg = MessageFactory.fromPayload(payload)
      msg.mmsi.should eq(244314000)
      msg.vessel_class.should eq(Domain::Vessel::CLASS_A)
      msg.lat.should be_within(1.0/1_000_000).of(52.834663)
      msg.lon.should be_within(1.0/1_000_000).of(5.206438)
    end
    
    it "returns null for messages of incorrect length" do
      payload = "13`wgT0P5"
      mf = MessageFactory.new
      msg = MessageFactory.fromPayload(payload)
      msg.should eq(nil)
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
  end
end