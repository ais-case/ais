require 'spec_helper'
require 'ffi-rzmq'

module Service
  describe PayloadEncoderService do
    it_behaves_like "a service"
    it_behaves_like "a reply service"
    
    describe "process_request" do
      it "encodes the request data" do
        @registry = MockRegistry.new
        service = PayloadEncoderService.new(@registry)
        decoded = '000001000011101000111111101111100100000000'
        encoded = Marshal.load(service.process_request(Marshal.dump(decoded)))
        encoded.should eq('13`wgT0')
      end
    end
  end
end