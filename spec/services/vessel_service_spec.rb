require 'spec_helper'
require 'ffi-rzmq'

module Service
  describe VesselService do
    it_behaves_like "a service"
    it_behaves_like "a reply service"
    
    before(:each) do
      @registry = MockRegistry.new
      @registry.register('ais/message', 'tcp://localhost:21002')
      
      @vessel1 = Domain::Vessel.new(1234, Domain::Vessel::CLASS_A)
      @vessel1.position = Domain::LatLon.new(3.0, 5.0) 
      @vessel2 = Domain::Vessel.new(5678, Domain::Vessel::CLASS_A)
      @vessel2.position = Domain::LatLon.new(3.0, 4.0)
      @vessel3 = Domain::Vessel.new(9012, Domain::Vessel::CLASS_B)
      @vessel3.position = Domain::LatLon.new(2.0, 4.0) 
    end
    
    it "returns a list of vessels" do
      service = VesselService.new(@registry)
      service.receiveVessel(@vessel1)
      service.receiveVessel(@vessel2)

      vessels = Marshal.load(service.process_request('LIST'))
      vessels.length.should eq(2)
    end

    it "returns a filtered list of vessels when provided with an area" do
      service = VesselService.new(@registry)
      service.receiveVessel(@vessel1)
      service.receiveVessel(@vessel2)
      service.receiveVessel(@vessel3)
      
      latlons = Marshal.dump([Domain::LatLon.new(2.5, 4.5), Domain::LatLon.new(3.5, 3.5)]) 
      vessels = Marshal.load(service.process_request('LIST ' + latlons))
      vessels.length.should eq(1)
      vessels[0].mmsi.should eq(5678)
    end
    
    it "returns vessel info for a single vessel" do
      service = VesselService.new(@registry)
      service.receiveVessel(@vessel3)      
      vessel = Marshal.load(service.process_request('INFO 9012'))
      vessel.should eq(@vessel3)
    end
    
    it "listens for AIS position reports" do
      ctx = ZMQ::Context.new
      sock = ctx.socket(ZMQ::PUB)
      begin
        rc = sock.bind('tcp://*:21012')
        ZMQ::Util.resultcode_ok?(rc).should be_true
        @registry.register('ais/message', 'tcp://localhost:21012')
        
        service = (Class.new(VesselService) do
          attr_reader :received_data
          def process_message(data)
            @received_data = data
          end
        end).new(@registry)
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
    
    it "listens for AIS static info reports" do
      raw = "53u=:PP00001<H?G7OI0ThuB37G61<F22222220j1042240Ht2P00000000000000000008"

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
        end).new(@registry)
        service.start('tcp://localhost:23000')
        sock.send_string("5 " << raw)

        # Give service time to receive and process message
        sleep(0.1)
        service.received_data.should eq("5 " << raw)
        service.stop
      ensure
        sock.close
      end
      
    end
    
    it "processes incoming AIS messages into vessel information" do
      # Send position report
      message = "1 13`wgT0P5fPGmDfN>o?TN?vN2<05"
      vessel = Domain::Vessel.new(244314000, Domain::Vessel::CLASS_A)

      service = VesselService.new(@registry)
      service.stub(:receiveVessel)
      service.should_receive(:receiveVessel).with(vessel)
      service.process_message(message)
      
      vessel = Domain::Vessel.new(265505410, Domain::Vessel::CLASS_A)
      message = "5 53u=:PP00001<H?G7OI0ThuB37G61<F22222220j1042240Ht2P00000000000000000008"

      service = VesselService.new(@registry)
      service.stub(:receiveVessel)
      service.should_receive(:receiveVessel).with(vessel)
      service.process_message(message)
    end

    it "don't processes invalid AIS messages" do
      message = "1 13`wgT0P5fPGmDfN>"

      # Send position report
      service = VesselService.new(@registry)
      service.should_not_receive(:receiveVessel)
      service.process_message(message)      
    end
    
    it "updates the existing vessel when the position of a known vessel is reported" do
      vessel1 = Domain::Vessel.new(1234, Domain::Vessel::CLASS_A)
      vessel1.position = Domain::LatLon.new(3.0, 4.0) 
      vessel2 = Domain::Vessel.new(1234, Domain::Vessel::CLASS_A)
      vessel2.position = Domain::LatLon.new(5.0, 6.0)

      # Send the messages
      service = VesselService.new(@registry)
      service.receiveVessel(vessel1)
      service.receiveVessel(vessel2)
      
      # Only one vessel should be reported, and with the latest
      # position
      vessels = Marshal.load(service.process_request('LIST'))
      vessels.length.should eq(1)
      vessels[0].position.lat.should be_within(0.01).of(5.0)
      vessels[0].position.lon.should be_within(0.01).of(6.0)
    end
    
    it "adds a vessels that are not known yet" do
      vessel1 = Domain::Vessel.new(1234, Domain::Vessel::CLASS_A)
      vessel1.position = Domain::LatLon.new(3.0, 4.0) 
      vessel2 = Domain::Vessel.new(5678, Domain::Vessel::CLASS_A)
      vessel2.position = Domain::LatLon.new(5.0, 6.0)
      
      service = VesselService.new(@registry)
      service.receiveVessel(vessel1)
      service.receiveVessel(vessel2)
      vessels = service.process_request('LIST')
      vessels.should eq(Marshal.dump([vessel1, vessel2]))
    end    
  end
end