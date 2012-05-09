require "spec_helper"
require "service"

describe Service do
    describe "bind" do
        it "returns a service binding" do
            service = Service.new
            ret = service.bind 'ais/transmitter'
            ret.should be_a_kind_of(TransmitterProxy)
        end
    end    
end

describe "TransmitterProxy" do
    it "sends position reports to the Transmitter service" do
        vessel = "Vessel"
        socket = double('Socket')
        socket.should_receive(:send).with(Marshal.dump(vessel))

        t = TransmitterProxy.new socket
        t.send_position_report_for vessel
    end
end
