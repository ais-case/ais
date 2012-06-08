require 'spec_helper'
require 'ffi-rzmq'

module Service
  describe ChecksumService do
    it_behaves_like "a service"
    it_behaves_like "a reply service"
    
    describe "process_request" do
      it "returns true for messages with valid checksums" do
        message = '!AIVDM,1,1,,A,23afKn5P070CqEdMd<TqIwv6081W,0*64'
        @registry = MockRegistry.new
        service = ChecksumService.new(@registry)
        valid = Marshal.load(service.process_request(Marshal.dump(message)))
        valid.should be_true
      end

      it "returns false for messages with invalid checksums" do
        message = '!AIVDM,1,1,,A,23afKn5P070CqEdMd<TqIwv6081W,1*64'
        @registry = MockRegistry.new
        service = ChecksumService.new(@registry)
        valid = Marshal.load(service.process_request(Marshal.dump(message)))
        valid.should be_false
      end
    end
  end
end