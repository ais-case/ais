describe Service::VesselServiceProxy do
  it "requests vessel information from the Vessel service" do
    vessel1 = Vessel.new(1234, Vessel::CLASS_A)
    vessel1.position = LatLon.new(3.0, 4.0) 
    vessel2 = Vessel.new(5678, Vessel::CLASS_A)
    vessel2.position = LatLon.new(5.0, 6.0)
    vessels = [vessel1, vessel2] 
    
    socket = (Class.new do
      def initialize(vessels)
        @vessels = vessels
      end
      
      def send_string(string)
      end
      
      def recv_string(string)
        string.replace(Marshal.dump(@vessels))
      end
    end).new(vessels)
    
    t = Service::VesselServiceProxy.new(socket)
    t.vessels.should eq(vessels)
  end  
end
