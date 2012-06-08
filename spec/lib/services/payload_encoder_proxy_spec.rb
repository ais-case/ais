require 'spec_helper'

module Service
  describe PayloadEncoderProxy do
    before(:each) do
      @message = '000001000011101000111111101111100100000000'
      @encoded = '13`wgT0'
    end
  
    describe "encode" do
      it "uses the PayloadEncoderService to encode the message" do
            
        # Mock socket should be used correctly      
        socket = double('Socket')
        socket.should_receive(:send_string).with(Marshal.dump(@message))
        socket.should_receive(:recv_string) do |str|
          str.replace(Marshal.dump(@encoded))
        end
        
        # Mock should return encoded message
        encoder = PayloadEncoderProxy.new(socket)
        encoder.encode(@message).should eq(@encoded)
      end
    end
  end
end