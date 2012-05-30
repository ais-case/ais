require 'spec_helper'

module Service
  describe TransmitterService do
    before(:all) do
      @sample_message = "!AIVDM,1,1,,A,10004lP0?w0BCp01eo@00?v00000,0*24\n"
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
      it "accepts position report requests" do  
        service = TransmitterService.new(@registry)
        service.process_request('POSITION ' << Marshal.dump(@vessel))
      end

      it "accepts static info report requests" do  
        service = TransmitterService.new(@registry)
        service.process_request('STATIC ' << Marshal.dump(@vessel))
      end

      it "returns an empy response" do  
        service = TransmitterService.new(@registry)
        service.process_request('POSITION ' << Marshal.dump(@vessel)).should eq('')
      end
      
      it "broadcasts the encoded position report" do
        raw = 'POSITION ' << Marshal.dump(@vessel)
  
        service = TransmitterService.new(@registry)
        service.should_receive(:broadcast_message).with(@sample_message)
        service.process_request(raw)
      end

      it "broadcasts the encoded static info report" do
        raw = 'STATIC ' << Marshal.dump(@vessel)
  
        service = TransmitterService.new(@registry)
        service.should_receive(:broadcast_message).twice
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