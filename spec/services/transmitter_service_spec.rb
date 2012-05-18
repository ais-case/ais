describe Service::TransmitterService do
  it "accepts requests" do
    vessel = Vessel.new(1234, Vessel::CLASS_A)
    vessel.position = LatLon.new(3.0, 4.0)

    service = TransmitterService.new
    service.processRequest(Marshal.dump(vessel))
  end
end