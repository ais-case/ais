require 'spec_helper'

module Domain::AIS
  describe Message19 do
    it "has mmsi, vessel_class and type properties" do
      m = Message19.new(244314000)
      m.mmsi.should eq(244314000)
      m.type.should eq(19)
      m.vessel_class.should eq(Domain::Vessel::CLASS_B)
    end

    it "has lat, lon, speed and heading properties" do  
      m = Message19.new(244314000)
      m.lat = 1.0
      m.lat.should eq(1.0)
      m.lon = -1.0
      m.lon.should eq(-1.0)
      m.speed = 53.6
      m.speed.should be_within(0.01).of(53.6)
      m.heading = 35
      m.heading.should eq(35)
    end
    
    describe "payload" do
      it "returns the payload as bit string" do
        m = Message19.new(1234)
        m.lat = 3.0
        m.lon = 4.0
        m.speed = 54.1
        m.heading = 253
        expected = "C0004lP27@4Tv00KMl001vP00000000000000000000000000000"
        Domain::AIS::SixBitEncoding.encode(m.payload).should eq(expected)
      end

      it "correctly encodes when no speed and heading are provided" do
        m = Message19.new(1234)
        m.lat = 3.0
        m.lon = 4.0
        expected = "C0004lP3wh4Tv00KMl003wP00000000000000000000000000000"
        Domain::AIS::SixBitEncoding.encode(m.payload).should eq(expected)
      end
    end
  end
end