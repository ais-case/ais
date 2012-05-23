require 'spec_helper'

module Service::Platform
  describe ServiceRegistryProxy do
    describe "bind" do
      it "returns a service binding" do
        socket = double("Socket")
        socket.stub(:connect) { 0 }
        socket.stub(:close) { 0 }
  
        context = double("Context")
        context.stub(:socket) { socket }
  
        registry = ServiceRegistryProxy.new context
        proxies = {'ais/transmitter' => Service::TransmitterProxy, 
                   'ais/vessels' => Service::VesselServiceProxy}
        proxies.each do |name, klass|
          registry.bind(name) do |service|
            service.should be_a_kind_of(klass) 
          end
        end      
      end
  
      it "can be used to look up endpoints" do
        registry = ServiceRegistryProxy.new
        endpoints = {'ais/message' => 'tcp://localhost:21002'}
        endpoints.each do |name, endpoint|
          registry.lookup(name).should eq(endpoint)        
        end
      end
  
      it "raises an exception when the socket fails" do
        socket = double("Socket")
        socket.stub(:connect) { -1 }
  
        context = double("Context")
        context.stub(:socket) { socket }
  
        registry = ServiceRegistryProxy.new(context)
  
        socket.stub(:connect) { -1 }
        registry = ServiceRegistryProxy.new(context)
        expect { registry.bind 'ais/transmitter' }.to raise_error
      end
  
      it "closes sockets of proxies when stopped" do
        socket = double("Socket")
        socket.stub(:connect) { 0 }
        socket.should_receive(:close)
  
        context = double("Context")
        context.stub(:socket) { socket }
  
        registry = ServiceRegistryProxy.new context
        registry.bind('ais/transmitter') {|service| }
      end
    end
  end
end