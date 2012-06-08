require 'spec_helper'
require 'ffi-rzmq'

module Service
  describe PayloadDecoderService do
    it_behaves_like "a service"
    it_behaves_like "a reply service"
    
    describe "process_request" do
      it "decodes the request data" do
        @registry = MockRegistry.new
        service = PayloadDecoderService.new(@registry)
        decoded = Marshal.load(service.process_request(Marshal.dump('13`wgT0')))
        decoded.should eq('000001000011101000111111101111100100000000')
      end
    end
  end
end