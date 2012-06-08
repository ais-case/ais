require 'spec_helper'

module Service
  describe PayloadDecoderProxy do
    before(:each) do
      @message = '13`wgT0'
      @decoded = '000001000011101000111111101111100100000000'
    end
  
    describe "decode" do
      it "uses the PayloadDecoderService to decode the message" do
            
        # Mock socket should be used correctly      
        socket = double('Socket')
        socket.should_receive(:send_string).with(Marshal.dump(@message))
        socket.should_receive(:recv_string) do |str|
          str.replace(Marshal.dump(@decoded))
        end
        
        # Mock should return decoded message
        decoder = PayloadDecoderProxy.new(socket)
        decoder.decode(@message).should eq(@decoded)
      end
    end
  end
end