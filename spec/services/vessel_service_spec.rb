require 'spec_helper'
require 'ffi-rzmq'

module Service
  describe VesselService do
    it_behaves_like "a service"
    it_behaves_like "a request service"
    
    it "listens for AIS position reports" do
      ctx = ZMQ::Context.new
      sock = ctx.socket(ZMQ::PUB)
      begin
        rc = sock.bind('tcp://*:24000')
        ZMQ::Util.resultcode_ok?(rc).should be_true
        
        service = VesselService.new
        service.start('tcp://localhost:23000')
        service.should_receive(:processMessage).with("13`wgT0P5fPGmDfN>o?TN?vN2<05")        
        sock.send_string("1 13`wgT0P5fPGmDfN>o?TN?vN2<05")

        # Give service time to receive and process message
        sleep(0.1)
        
        service.stop
      ensure
        sock.close
      end
    end
    
    it "can process AIS messages" do
      payload = "13`wgT0P5fPGmDfN>o?TN?vN2<05"
      service = VesselService.new
      service.processMessage(payload)
      vessel = Marshal.load(service.processRequest(''))[0]
      vessel.vessel_class.should eq(Domain::Vessel::CLASS_A)
      vessel.mmsi.should eq(244314000)
    end
    
    it "returns a list of vessels" do
      vessel1 = Domain::Vessel.new(1234, Domain::Vessel::CLASS_A)
      vessel1.position = Domain::LatLon.new(3.0, 4.0) 
      vessel2 = Domain::Vessel.new(5678, Domain::Vessel::CLASS_A)
      vessel2.position = Domain::LatLon.new(5.0, 6.0)
  
      service = VesselService.new
      service.receiveVessel(vessel1)
      service.receiveVessel(vessel2)
      vessels = service.processRequest('')
      vessels.should eq(Marshal.dump([vessel1, vessel2]))
    end
  end
end