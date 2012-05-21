require 'spec_helper'

module Domain::AIS
  describe Message do
    it "has a mmsi property" do
      m = Message.new(244314000)
      m.mmsi.should eq(244314000)
    end    
  end
end