require 'spec_helper'

module Service
  describe TransmitterProxy do
    it "sends position reports to the Transmitter service" do
      vessel = "Vessel"
      socket = double('Socket')
      socket.should_receive(:send_string).with(Marshal.dump(vessel))
  
      t = Service::TransmitterProxy.new(socket)
      t.send_position_report_for vessel
    end
  end
end