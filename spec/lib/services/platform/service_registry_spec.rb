require 'spec_helper'

module Service::Platform
  describe ServiceRegistry do
    it_behaves_like "a service"
    it_behaves_like "a reply service"
    
    before(:each) do
      @registry = ServiceRegistry.new
      @registry.register('ais/message', 'tcp://localhost:21002')
    end
    
    describe "register" do
      it "registers a service at an endpoint" do
        @registry.lookup('ais/unknown').should eq(nil)
        @registry.register('ais/unknown', 'tcp://localhost:21000')
        @registry.lookup('ais/unknown').should eq('tcp://localhost:21000') 
      end      
    end
    
    describe "lookup" do
      it "can be used to look up endpoints" do
        @registry.lookup('ais/message').should eq('tcp://localhost:21002')        
      end
    end
    
    describe "unregister" do
      it "unregisters an endpoint" do
        @registry.unregister('ais/message')
        @registry.lookup('ais/message').should eq(nil) 
      end            
    end
    
    describe "process_request" do
      it "processes lookup requests" do
        @registry.should_receive(:lookup).with('ais/message') { 'tcp://localhost:21000' }
        @registry.process_request('LOOKUP ais/message')
      end

      it "processes register requests" do
        @registry.should_receive(:register).with('ais/message', 'tcp://localhost:21000')
        @registry.process_request('REGISTER ais/message tcp://localhost:21000')
      end

      it "processes unregister requests" do
        @registry.should_receive(:unregister).with('ais/message')
        @registry.process_request('UNREGISTER ais/message')
      end
    end
  end
end