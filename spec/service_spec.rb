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

      socket.stub(:connect) { -1 }
      service = Service.new context
      expect { service.bind 'ais/transmitter' }.to raise_error
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