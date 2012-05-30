require 'spec_helper'

module Domain::AIS
  describe SixBitEncoding do
    it "can decode a payload using 6-bit decode" do
      SixBitEncoding.decode("13`wgT0").should eq("000001000011101000111111101111100100000000")
    end    
  end
  
  describe SixBitEncoding do
    it "can encode a payload using 6-bit encode" do
      SixBitEncoding.encode("000001000011101000111111101111100100000000").should eq("13`wgT0")
    end
    
    it "pads with extra zeroes to the next 6-bit boundary" do
      SixBitEncoding.encode("11").should eq("h")
    end
  end
end