require 'spec_helper'

module Service
  describe TransmitterService do
    before(:all) do
      @sample_message = "!AIVDM,1,1,,A,1000h>@0000BCp01eo@00000000,0*21\n"      
    end
    
    it_behaves_like "a service"
    it_behaves_like "a reply service"

    it "accepts requests" do
      vessel = Domain::Vessel.new(1234, Domain::Vessel::CLASS_A)
      vessel.position = Domain::LatLon.new(3.0, 4.0)
  
      service = TransmitterService.new(Platform::ServiceRegistry.new)
      service.process_request(Marshal.dump(vessel))
    end
    
    describe "process_raw_message" do
      it "is called when a raw message is received" do
        service = TransmitterService.new(Platform::ServiceRegistry.new)
        service.start('tcp://*:27000')
        socket = TCPSocket.new('localhost', 20000)      
        sleep(1)
        service.process_raw_message(@sample_message)
        
        timeout(1) do
          socket.gets.should eq(@sample_message)
        end
        service.stop
      end
        
      it "ignores raw messages that start with #" do
        service = TransmitterService.new(Platform::ServiceRegistry.new)
        service.should_not_receive(:broadcast_message)  
        service.process_raw_message('#' << @sample_message)
      end
      
      it "strips off prepended timestamps" do        
        service = TransmitterService.new(Platform::ServiceRegistry.new)
        service.should_receive(:broadcast_message).with(@sample_message)  
        service.process_raw_message("1234.1234" << @sample_message)
      end
    end
        
    it "sends out updates" do
      service = TransmitterService.new(Platform::ServiceRegistry.new)
      service.start('tcp://*:27000')
      socket = TCPSocket.new('localhost', 20000)
      sleep(1)

      begin
        vessel = Domain::Vessel.new(12345, Domain::Vessel::CLASS_A)
        vessel.position = Domain::LatLon.new(3.0, 4.0)
        service.process_request(Marshal.dump(vessel))
 
        timeout(1) do
          socket.gets.should eq("!AIVDM,1,1,,A,1000h>@0000BCp01eo@00000000,0*21\n")
        end
      ensure
        service.stop
        socket.close
      end
    end
  end  
end
