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
  end
end