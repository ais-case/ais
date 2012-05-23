require 'spec_helper'
require 'ffi-rzmq'

module Service
  describe VesselService do
    it_behaves_like "a service"
    it_behaves_like "a reply service"
    
    it "listens for AIS position reports" do
      ctx = ZMQ::Context.new
      sock = ctx.socket(ZMQ::PUB)
      begin
        rc = sock.bind('tcp://*:21002')
        ZMQ::Util.resultcode_ok?(rc).should be_true
        
        service = (Class.new(VesselService) do
          attr_reader :received_data
          def process_message(data)
            @received_data = data
          end
        end).new(Platform::ServiceRegistryProxy.new)
        service.start('tcp://localhost:23000')
        sock.send_string("1 13`wgT0P5fPGmDfN>o?TN?vN2<05")

        # Give service time to receive and process message
        sleep(0.1)
        service.received_data.should eq("1 13`wgT0P5fPGmDfN>o?TN?vN2<05")
        service.stop
      ensure
        sock.close
      end
    end
    
    it "processes incoming AIS messages into vessel information" do
      message = "1 13`wgT0P5fPGmDfN>o?TN?vN2<05"
      vessel = Domain::Vessel.new(244314000, Domain::Vessel::CLASS_A)

      # Send position report
      service = VesselService.new(Platform::ServiceRegistryProxy.new)
      service.stub(:receiveVessel)
      service.should_receive(:receiveVessel).with(vessel)
      service.process_message(message)      
    end
    
    it "updates the existing vessel when the position of a known vessel is reported" do
      vessel1 = Domain::Vessel.new(1234, Domain::Vessel::CLASS_A)
      vessel1.position = Domain::LatLon.new(3.0, 4.0) 
      vessel2 = Domain::Vessel.new(1234, Domain::Vessel::CLASS_A)
      vessel2.position = Domain::LatLon.new(5.0, 6.0)

      # Send the messages
      service = VesselService.new(Platform::ServiceRegistryProxy.new)
      service.receiveVessel(vessel1)
      service.receiveVessel(vessel2)
      
      # Only one vessel should be reported, and with the latest
      # position
      vessels = Marshal.load(service.process_request)
      vessels.length.should eq(1)
      vessels[0].position.lat.should be_within(0.01).of(5.0)
      vessels[0].position.lon.should be_within(0.01).of(6.0)
    end
    
    it "adds a vessels that are not known yet" do
      vessel1 = Domain::Vessel.new(1234, Domain::Vessel::CLASS_A)
      vessel1.position = Domain::LatLon.new(3.0, 4.0) 
      vessel2 = Domain::Vessel.new(5678, Domain::Vessel::CLASS_A)
      vessel2.position = Domain::LatLon.new(5.0, 6.0)
      
      service = VesselService.new(Platform::ServiceRegistryProxy.new)
      service.receiveVessel(vessel1)
      service.receiveVessel(vessel2)
      vessels = service.process_request
      vessels.should eq(Marshal.dump([vessel1, vessel2]))
    end
  end
end