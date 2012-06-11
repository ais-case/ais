require 'spec_helper'

module Service
  describe TransmitterProxy do
    describe "send_position-report_for" do
      it "sends position reports to the Transmitter service" do
        vessel = "Vessel"
        socket = double('Socket')
        socket.should_receive(:send_string).once
    
        t = Service::TransmitterProxy.new(socket)
        t.send_position_report_for(vessel)
      end
  
      it "sends position reports with specific timestamps to the Transmitter service" do
        timestamp = Time.now
        vessel = "Vessel"
        socket = double('Socket')
        socket.should_receive(:send_string).with('POSITION ' << Marshal.dump([vessel, timestamp]))
    
        t = Service::TransmitterProxy.new(socket)
        t.send_position_report_for(vessel, timestamp)
      end
    end
    
    describe "send_static_report_for" do
      it "sends position reports to the Transmitter service" do
        vessel = "Vessel"
        socket = double('Socket')
        socket.should_receive(:send_string).once
    
        t = Service::TransmitterProxy.new(socket)
        t.send_static_report_for(vessel)
      end      

      it "sends position reports with specific timestamps to the Transmitter service" do
        timestamp = Time.now
        vessel = "Vessel"
        socket = double('Socket')
        socket.should_receive(:send_string).with('STATIC ' << Marshal.dump([vessel, timestamp]))
    
        t = Service::TransmitterProxy.new(socket)
        t.send_static_report_for(vessel, timestamp)
      end      
    end
  end
end