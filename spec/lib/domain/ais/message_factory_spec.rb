require 'spec_helper'

module Domain::AIS
  describe MessageFactory do
    before(:all) do
      @encoding = Domain::AIS::SixBitEncoding
    end
    
    describe "fromPayload" do
      it "can create a class A position report message from a payload" do
        payload = "13`wgT0P5fPGmDfN>o?TN2NN2<05"
        mf = MessageFactory.new
        msg = MessageFactory.fromPayload(@encoding.decode(payload))
        msg.mmsi.should eq(244314000)
        msg.vessel_class.should eq(Domain::Vessel::CLASS_A)
        msg.lat.should be_within(1.0/1_000_000).of(52.834663)
        msg.lon.should be_within(1.0/1_000_000).of(5.206438)
        msg.speed.should be_within(0.1).of(36.6)
        msg.heading.should be(79)
      end

      it "can create a class B position report message from a payload" do
        payload = "B6:fOUh0=R1oRQSC=jo9D7b61P06"
        mf = MessageFactory.new
        msg = MessageFactory.fromPayload(@encoding.decode(payload))
        msg.mmsi.should eq(413900695)
        msg.vessel_class.should eq(Domain::Vessel::CLASS_B)
        msg.lat.should be_within(1.0/1_000_000).of(23.070368)
        msg.lon.should be_within(1.0/1_000_000).of(113.480218)
        msg.speed.should be_within(0.1).of(5.4)
        msg.heading.should be(15)

        payload = "C6:fOUh0=R1oRQSC=jo9D7b61P06000000000000000000000000"
        mf = MessageFactory.new
        msg = MessageFactory.fromPayload(@encoding.decode(payload))
        msg.mmsi.should eq(413900695)
        msg.vessel_class.should eq(Domain::Vessel::CLASS_B)
        msg.lat.should be_within(1.0/1_000_000).of(23.070368)
        msg.lon.should be_within(1.0/1_000_000).of(113.480218)
        msg.speed.should be_within(0.1).of(5.4)
        msg.heading.should be(15)
      end
  
      it "can create a class A static info message from a payload" do
        payload = "53u=:PP00001<H?G7OI0ThuB37G61<F22222220j1042240Ht2P00000000000000000008"
        mf = MessageFactory.new
        msg = MessageFactory.fromPayload(@encoding.decode(payload))
        msg.mmsi.should eq(265505410)
        msg.vessel_class.should eq(Domain::Vessel::CLASS_A)
        msg.vessel_type.should eq(Domain::VesselType.new(50))
      end

      it "can create a class B static info message from a payload" do
        payload = "H44?BB4lDB1>C1CEC130001@F270"
        mf = MessageFactory.new
        msg = MessageFactory.fromPayload(@encoding.decode(payload))
        msg.mmsi.should eq(272880200)
        msg.vessel_class.should eq(Domain::Vessel::CLASS_B)
        msg.vessel_type.should eq(Domain::VesselType.new(52))
      end
      
      it "returns null for messages of incorrect length" do
        payload = "13`wgT0P5"
        mf = MessageFactory.new
        msg = MessageFactory.fromPayload(@encoding.decode(payload))
        msg.should eq(nil)
      end
    end
    
    describe "create_position_report" do
      it "creates position reports from class A vessel objects" do
        vessel = Domain::Vessel.new(1234, Domain::Vessel::CLASS_A)
        vessel.position = Domain::LatLon.new(3.0, 4.0)
        vessel.speed = 15.3
        vessel.heading = 90  
  
        mf = MessageFactory.new
        msg = mf.create_position_report(vessel)
        msg.type.should eq(1)
        msg.mmsi.should eq(1234)
        msg.lat.should eq(3.0)
        msg.lon.should eq(4.0)
        msg.speed.should eq(15.3)
        msg.heading.should eq(90)
      end

      it "creates position reports from class B vessel objects" do
        vessel = Domain::Vessel.new(1234, Domain::Vessel::CLASS_B)
        vessel.position = Domain::LatLon.new(3.0, 4.0)
        vessel.speed = 15.3
        vessel.heading = 90  
  
        mf = MessageFactory.new
        msg = mf.create_position_report(vessel)
        msg.type.should eq(18)
        msg.mmsi.should eq(1234)
        msg.lat.should eq(3.0)
        msg.lon.should eq(4.0)
        msg.speed.should eq(15.3)
        msg.heading.should eq(90)
      end
    end
    
    describe "create_static_info" do
      it "creates static info messages from class A vessel objects" do
        vessel_type = Domain::VesselType.from_str("Tanker")
        vessel = Domain::Vessel.new(1234, Domain::Vessel::CLASS_A)
        vessel.position = Domain::LatLon.new(3.0, 4.0)
        vessel.type = vessel_type  
  
        mf = MessageFactory.new
        msg = mf.create_static_info(vessel)
        msg.type.should eq(5)
        msg.mmsi.should eq(1234)
        msg.vessel_type.should eq(vessel_type)
      end
      
      it "creates static info messages from class B vessel objects" do
        vessel_type = Domain::VesselType.from_str("Tanker")
        vessel = Domain::Vessel.new(1234, Domain::Vessel::CLASS_B)
        vessel.position = Domain::LatLon.new(3.0, 4.0)
        vessel.type = vessel_type  
  
        mf = MessageFactory.new
        msg = mf.create_static_info(vessel)
        msg.type.should eq(24)
        msg.mmsi.should eq(1234)
        msg.vessel_type.should eq(vessel_type)
      end
    end
  end
end