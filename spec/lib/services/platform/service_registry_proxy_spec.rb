require 'spec_helper'

module Service::Platform
  describe ServiceRegistryProxy do
    before(:each) do
      @registry = ServiceRegistryProxy.new(nil) 
    end

    describe "lookup" do
      it "can be used to look up endpoints" do
        name = 'ais/message'
        endpoint = 'tcp://localhost:21002'

        socket = double("Socket")
        socket.should_receive(:setsockopt)
        socket.should_receive(:connect) { 0 }
        socket.should_receive(:send_string).with('LOOKUP ' << name)
        socket.should_receive(:recv_string) { |s| s.replace(endpoint) }
        socket.should_receive(:close) { 0 }
  
        context = double("Context")
        context.should_receive(:socket) { socket }

        @registry.context = context
        @registry.lookup(name).should eq(endpoint)        
      end
    end

    describe "register" do
      it "sends a register request" do
        name = 'ais/transmitter'
        endpoint = 'tcp://localhost:22000'
        
        socket = double("Socket")
        socket.should_receive(:setsockopt)
        socket.should_receive(:connect) { 0 }
        socket.should_receive(:send_string).with("REGISTER #{name} #{endpoint}") { 0 }
        socket.should_receive(:recv_string) { '' }
        socket.should_receive(:close) { 0 }
  
        context = double("Context")
        context.should_receive(:socket) { socket }
  
        @registry.context = context
        @registry.register(name, endpoint)        
      end
    end
        
    describe "bind" do
      it "returns a service binding" do
        name = 'ais/transmitter'
        endpoint = 'tcp://localhost:22000'
        
        socket = double("Socket")
        socket.should_receive(:connect).with(endpoint) { 0 }
        socket.should_receive(:setsockopt)
        socket.should_not_receive(:close)
  
        context = double("Context")
        context.should_receive(:socket) { socket }
  
        @registry.context = context
        @registry.should_receive(:lookup).with(name) { endpoint }
                
        service = @registry.bind(name)
        service.should be_a_kind_of(Service::TransmitterProxy)
      end

      it "accepts a block and automatically releases the proxy" do
        name = 'ais/transmitter'
        endpoint = 'tcp://localhost:22000'
        
        socket = double("Socket")
        socket.should_receive(:connect).with(endpoint) { 0 }
        socket.should_receive(:setsockopt)
        socket.should_receive(:close) { 0 }
  
        context = double("Context")
        context.should_receive(:socket) { socket }
  
        @registry.context = context
        @registry.should_receive(:lookup).with(name) { endpoint }
        
        @registry.bind(name) do |service|
          service.should be_a_kind_of(Service::TransmitterProxy) 
        end
      end

      it "raises an exception when the socket fails" do
        socket = double("Socket")
        socket.stub(:connect) { -1 }  
        context = double("Context")
        context.stub(:socket) { socket }
        
        @registry.context = context  
        expect { @registry.bind('ais/transmitter') }.to raise_error
      end
    end    
  end
end