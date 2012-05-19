require 'spec_helper'

module Service
  describe VesselService do
    it_behaves_like "a service"
    
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