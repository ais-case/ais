require 'spec_helper'

module Domain::AIS
  describe SixBitEncoding do
    it "can decode a payload using 6-bit decode" do
      SixBitEncoding.decode("13`wgT0").should eq("000001000011101000111111101111100100000000")
    end
  end
end