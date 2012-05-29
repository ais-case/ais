require 'spec_helper'

module Service
  describe VesselProxy do
    before(:each) do
        vessel1 = Domain::Vessel.new(1234, Domain::Vessel::CLASS_A)
        vessel1.position = Domain::LatLon.new(3.0, 4.0) 
        vessel2 = Domain::Vessel.new(5678, Domain::Vessel::CLASS_A)
        vessel2.position = Domain::LatLon.new(5.0, 6.0)
        @vessels = [vessel1, vessel2] 
    end
  
    it "requests vessel information from the Vessel service" do      
      # Mock socket should be used correctly      
      socket = double('Socket')
      socket.should_receive(:send_string).with('')
      socket.should_receive(:recv_string) do |str|
        str.replace(Marshal.dump(@vessels))
      end
      
      # Mock should return correct list of vessels
      t = VesselProxy.new(socket)
      t.vessels.should eq(@vessels)
    end  

    it "requests only vessels within the required area" do
      latlon1 = Domain::LatLon.new(3.0, 3.0)
      latlon2 = Domain::LatLon.new(5.0, 6.0)

      # Mock socket should be used correctly      
      socket = double('Socket')
      socket.should_receive(:send_string).with(Marshal.dump([latlon1, latlon2]))
      socket.should_receive(:recv_string) do |str|
        str.replace(Marshal.dump(@vessels))
      end
      
      t = VesselProxy.new(socket)
      t.vessels(latlon1, latlon2).should eq(@vessels)
    end  
  end
end