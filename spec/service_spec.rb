require 'spec_helper'
require 'service'

describe ServiceRegistry do
  describe "bind" do
    it "returns a service binding" do
      socket = double("Socket")
      socket.stub(:connect) { 0 }
      socket.stub(:close) { 0 }

      context = double("Context")
      context.stub(:socket) { socket }

      registry = ServiceRegistry.new context
      proxies = {'ais/transmitter' => TransmitterProxy, 'ais/vessels' => VesselServiceProxy}
      proxies.each do |name, klass|
        registry.bind(name) do |service|
          service.should be_a_kind_of(klass) 
        end
      end      
    end

    it "raises an exception when the socket fails" do
      socket = double("Socket")
      socket.stub(:connect) { -1 }

      context = double("Context")
      context.stub(:socket) { socket }

      registry = ServiceRegistry.new context

      socket.stub(:connect) { -1 }
      registry = ServiceRegistry.new context
      expect { registry.bind 'ais/transmitter' }.to raise_error
    end

    it "closes all sockets when stopped" do
      socket = double("Socket")
      socket.stub(:connect) { 0 }
      socket.should_receive(:close)

      context = double("Context")
      context.stub(:socket) { socket }

      registry = ServiceRegistry.new context
      registry.bind('ais/transmitter') {|service| }
    end
  end
end

describe "TransmitterProxy" do
  it "sends position reports to the Transmitter service" do
    vessel = "Vessel"
    socket = double('Socket')
    socket.should_receive(:send_string).with(Marshal.dump(vessel))

    t = TransmitterProxy.new socket
    t.send_position_report_for vessel
  end
end

describe "VesselServiceProxy" do
  it "requests vessel information from the Vessel service" do
    vessel1 = Vessel.new(1234, Vessel::CLASS_A)
    vessel1.position = LatLon.new(3.0, 4.0) 
    vessel2 = Vessel.new(5678, Vessel::CLASS_A)
    vessel2.position = LatLon.new(5.0, 6.0)
    vessels = [vessel1, vessel2] 
    
    socket = (Class.new do
      def initialize(vessels)
        @vessels = vessels
      end
      
      def send_string(string)
      end
      
      def recv_string(string)
        string.replace(Marshal.dump(@vessels))
      end
    end).new(vessels)
    
    t = VesselServiceProxy.new socket
    t.vessels.should eq(vessels)
  end  
end
