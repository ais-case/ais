describe Service::VesselService do
  it "returns a list of vessels" do
    vessel1 = Vessel.new(1234, Vessel::CLASS_A)
    vessel1.position = LatLon.new(3.0, 4.0) 
    vessel2 = Vessel.new(5678, Vessel::CLASS_A)
    vessel2.position = LatLon.new(5.0, 6.0)

    service = VesselService.new
    service.receiveVessel(vessel1)
    service.receiveVessel(vessel2)
    vessels = service.processRequest('')
    vessels.should eq(Marshal.dump([vessel1, vessel2]))
  end
end