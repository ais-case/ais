require 'spec_helper'

module Domain::AIS
  describe MessageFactory do
    it "can create a message object from a payload" do
      payload = "13`wgT0P5fPGmDfN>o?TN?vN2<05"
      mf = MessageFactory.new
      msg = mf.fromPayload(payload)
      msg.mmsi.should eq(244314000)
    end
    
    it "can decode a payload using 6-bit decode" do
      mf = MessageFactory.new
      decoded = mf.decode("13`wgT0")
      decoded.should eq("000001000011101000111111101111100100000000")
    end    
  end
end