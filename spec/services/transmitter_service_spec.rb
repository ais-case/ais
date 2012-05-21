require 'spec_helper'

module Service
  describe TransmitterService do
    it_behaves_like "a service"
    it_behaves_like "a reply service"

    it "accepts requests" do
      vessel = Domain::Vessel.new(1234, Domain::Vessel::CLASS_A)
      vessel.position = Domain::LatLon.new(3.0, 4.0)
  
      service = TransmitterService.new(ServiceRegistry.new)
      service.process_request(Marshal.dump(vessel))
    end
  end  
end
