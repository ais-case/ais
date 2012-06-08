require 'spec_helper'

module Service
  describe ChecksumProxy do
    before(:each) do
      @message = ''
    end
  
    describe "verify" do
      it "returns true when the CheckService reports true" do            
        # Mock socket should be used correctly      
        socket = double('Socket')
        socket.should_receive(:send_string).with(Marshal.dump(@message))
        socket.should_receive(:recv_string) do |str|
          str.replace(Marshal.dump(true))
        end
        
        # Mock should return decoded message
        checksum = ChecksumProxy.new(socket)
        checksum.verify(@message).should be_true
      end
      
      it "returns false when the CheckService reports false" do            
        # Mock socket should be used correctly      
        socket = double('Socket')
        socket.should_receive(:send_string).with(Marshal.dump(@message))
        socket.should_receive(:recv_string) do |str|
          str.replace(Marshal.dump(false))
        end
        
        # Mock should return decoded message
        checksum = ChecksumProxy.new(socket)
        checksum.verify(@message).should be_false
      end
    end
  end
end