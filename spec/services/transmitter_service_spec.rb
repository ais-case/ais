require 'spec_helper'

module Service
  describe TransmitterService do
    before(:all) do
      @sample_message = "!AIVDM,1,1,,A,10004lP0000BCp01eo@00000000,0*3f\n" 
    end
    
    before(:each) do
      @registry = MockRegistry.new

      @vessel = Domain::Vessel.new(1234, Domain::Vessel::CLASS_A)
      @vessel.position = Domain::LatLon.new(3.0, 4.0)  
    end
    
    it_behaves_like "a service"
    it_behaves_like "a reply service"
    
    describe "process_raw_message" do
      it "broadcasts processed messages" do
        service = TransmitterService.new(@registry)
        service.should_receive(:broadcast_message).with(@sample_message)  
        service.process_raw_message(@sample_message)
      end
        
      it "ignores raw messages that start with #" do
        service = TransmitterService.new(@registry)
        service.should_not_receive(:broadcast_message)  
        service.process_raw_message('#' << @sample_message)
      end
      
      it "strips off prepended timestamps" do        
        service = TransmitterService.new(@registry)
        service.should_receive(:broadcast_message).with(@sample_message)  
        service.process_raw_message("1234.1234" << @sample_message)
      end
    end
    
    describe "process_request" do
      it "accepts requests" do  
        service = TransmitterService.new(@registry)
        service.process_request(Marshal.dump(@vessel))
      end

      it "returns an empy response" do  
        service = TransmitterService.new(@registry)
        service.process_request(Marshal.dump(@vessel)).should eq('')
      end
      
      it "broadcasts the encoded message" do
        raw = Marshal.dump(@vessel)
  
        service = TransmitterService.new(@registry)
        service.should_receive(:broadcast_message).with(@sample_message)
        service.process_request(raw)
      end
    end
    
    describe "broadcast_message" do
      it "sends out a message to clients" do
        service = TransmitterService.new(@registry)
        service.start('tcp://*:27000')
        socket = TCPSocket.new('localhost', 20000)
        sleep(0.1)
  
        begin
          service.broadcast_message(@sample_message)
   
          timeout(1) do
            socket.gets.should eq(@sample_message)
          end
        ensure
          service.stop
          socket.close
        end
      end
    end
  end 
end