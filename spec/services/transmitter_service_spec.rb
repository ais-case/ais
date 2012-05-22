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
    
    it "accepts raw messages" do
      service = TransmitterService.new(ServiceRegistry.new)
      service.start('tcp://*:27000')
      socket = TCPSocket.new('localhost', 20000)      
      sleep(0.5)

      data = "!AIVDM,1,1,,A,1000h>@0000BCp01eo@00000000,0*21\n"
      service.process_raw_message(data)
      
      timeout(0.5) do
        socket.gets.should eq("!AIVDM,1,1,,A,1000h>@0000BCp01eo@00000000,0*21\n")
      end
      service.stop
    end
    
    it "sends out updates" do
      service = TransmitterService.new(ServiceRegistry.new)
      service.start('tcp://*:27000')
      socket = TCPSocket.new('localhost', 20000)
      sleep(0.5)

      begin
        vessel = Domain::Vessel.new(12345, Domain::Vessel::CLASS_A)
        vessel.position = Domain::LatLon.new(3.0, 4.0)
        service.process_request(Marshal.dump(vessel))
 
        timeout(0.5) do
          socket.gets.should eq("!AIVDM,1,1,,A,1000h>@0000BCp01eo@00000000,0*21\n")
        end
      ensure
        service.stop
        socket.close
      end
    end
  end  
end
