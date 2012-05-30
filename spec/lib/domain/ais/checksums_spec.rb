require 'spec_helper'

module Domain::AIS
  describe Checksums do
    describe 'verify' do
      it "returns true when the packet is valid" do
        packets = ["!AIVDM,1,1,,A,23afKn5P070CqEdMd<TqIwv6081W,0*64",
                   "!AIVDM,1,1,,B,@h2E3MhrFLHP7P00,0*6B",
                   "!AIVDM,1,1,,A,13aFeePP00PDPHFMdPk00?v42D7m,0*0A",
                   "!AIVDM,1,1,,A,33bjKJ50010BomHMfsCLQ6H42000,0*5D"] 
        packets.each do |packet|
          Checksums::verify(packet).should be_true
        end
      end
      
      it "returns false when the packet is not valid" do
        packets = ["!AIVDM,1,1,,A,23afKn5P070CqEdMd<TqIwv6081W,1*64",
                   "!AIVDM,1,1,,A,@h2E3MhrFLHP7P00,0*6B",
                   "!AIVDM,2,1,,A,13aFeePP00PDPHFMdPk00?v42D7m,0*0A",
                   "!BIVDM,1,1,,A,33bjKJ50010BomHMfsCLQ6H42000,0*5D"] 
        packets.each do |packet|
          Checksums::verify(packet).should be_false
        end        
      end
    end
    
    describe 'add' do
      it "appends a checksum to a packet and returns the result" do
        packets = {"!AIVDM,1,1,,A,23afKn5P070CqEdMd<TqIwv6081W,0" =>
                   "!AIVDM,1,1,,A,23afKn5P070CqEdMd<TqIwv6081W,0*64",
                   "!AIVDM,1,1,,A,13aFeePP00PDPHFMdPk00?v42D7m,0" =>
                   "!AIVDM,1,1,,A,13aFeePP00PDPHFMdPk00?v42D7m,0*0A"} 
        packets.each do |sentence, packet|
          Checksums::add(sentence).should eq(packet)  
        end        
      end
    end
  end 
end