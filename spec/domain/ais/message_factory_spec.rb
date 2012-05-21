require 'spec_helper'

module Domain::AIS
  describe MessageFactory do
    it "can create a message object from a payload" do
      payload = "13`wgT0P5fPGmDfN>o?TN?vN2<05"
      mf = MessageFactory.new
      msg = mf.fromPayload(payload)
      msg.mmsi.should eq(244314000)
    end    
  end
end