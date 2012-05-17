require 'spec_helper'
require 'service'

describe Service do
  describe "bind" do
    it "returns a service binding" do
      socket = double("Socket")
      socket.stub(:connect) { 0 }

      context = double("Context")
      context.stub(:socket) { socket }

      service = Service.new context

      ret = service.bind 'ais/transmitter'
      ret.should be_a_kind_of(TransmitterProxy)

      ret = service.bind 'ais/vessels'
      ret.should be_a_kind_of(VesselServiceProxy)
    end

    it "raises an exception when the socket fails" do
      socket = double("Socket")
      socket.stub(:connect) { -1 }

      context = double("Context")
      context.stub(:socket) { socket }

      service = Service.new context

      socket.stub(:connect) { -1 }
      service = Service.new context
      expect { service.bind 'ais/transmitter' }.to raise_error
    end

    it "closes all sockets when stopped" do
      socket = double("Socket")
      socket.stub(:connect) { 0 }
      socket.should_receive(:close)

      context = double("Context")
      context.stub(:socket) { socket }

      service = Service.new context
      service.bind 'ais/transmitter'
      service.terminate
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
    vessel1 = Vessel.new(Vessel::CLASS_A)
    vessel1.position = LatLon.new(3.0, 4.0) 
    vessel2 = Vessel.new(Vessel::CLASS_A)
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
