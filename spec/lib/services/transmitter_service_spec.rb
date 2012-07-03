require 'spec_helper'

module Service
  describe TransmitterService do
    before(:all) do
      @timestamp = "0.9%f" % Time.new.to_f
      @sample_message = "!AIVDM,1,1,,A,10004lP0?w0BCp01eo@00?v00000,0*24"
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
        service.should_receive(:broadcast_message).once do |timestamp,message|
          timestamp.should match(/^\d+\.\d+$/)
          message.should eq(@sample_message)
        end
        service.process_raw_message(@sample_message)
      end
        
      it "ignores raw messages that start with #" do
        service = TransmitterService.new(@registry)
        service.should_not_receive(:broadcast_message)  
        service.process_raw_message('#' << @sample_message)
      end
      
      it "uses prepended timestamps of original message when available" do
        service = TransmitterService.new(@registry)
        service.should_receive(:broadcast_message).with(@timestamp, @sample_message)  
        service.process_raw_message("%s %s" % [@timestamp, @sample_message])
      end
    end
    
    describe "process_request" do
      describe "position reports" do
        before(:each) do
          service = double('Service')
          service.stub(:encode).and_return('10004lP0?w0BCp01eo@00?v00000')
          @registry.stub(:bind).and_return(service)
        end

        it "accepts position report requests" do  
          service = TransmitterService.new(@registry)
          service.process_request('POSITION ' << Marshal.dump([@vessel, Time.now]))
        end

        it "returns an empy response" do  
          service = TransmitterService.new(@registry)
          service.process_request('POSITION ' << Marshal.dump([@vessel, Time.now])).should eq('')
        end

        it "broadcasts the encoded position report" do
          timestamp = Time.now
          raw = 'POSITION ' << Marshal.dump([@vessel, timestamp])
    
          service = TransmitterService.new(@registry)
          service.should_receive(:broadcast_message).with("%0.9f" % timestamp, @sample_message)
          service.process_request(raw)
        end
      end
      
      describe "static reports" do
        before(:each) do
          encoded = "50004lP0?w0BCp01eo@00?v000000000000000160000000000000000"
          encoded << "00000000000000"
          service = double('Service')
          service.stub(:encode).and_return(encoded)
          @registry.stub(:bind).and_return(service)
        end

        it "accepts static info report requests" do  
          service = TransmitterService.new(@registry)
          service.process_request('STATIC ' << Marshal.dump([@vessel, Time.now]))
        end
  
        it "broadcasts the encoded static info report" do
          timestamp = Time.now
          raw = 'STATIC ' << Marshal.dump([@vessel, timestamp])
    
          expected = []
          expected << "!AIVDM,2,1,,A,50004lP0?w0BCp01eo@00?v000000000000000160000000000000000,0*24"
          expected << "!AIVDM,2,2,,A,00000000000000,0*26"
                    
          service = TransmitterService.new(@registry)
          service.should_receive(:broadcast_message).with("%0.9f" % timestamp, expected[0])
          service.should_receive(:broadcast_message).with("%0.9f" % timestamp, expected[1])
          service.process_request(raw)
        end
      end
    end
    
    describe "broadcast_message" do
      it "sends out a message to clients" do        
        handler = double('Subscriber')
        handler.should_receive(:handle_request).with("%s %s" % [@timestamp, @sample_message])
  
        subscr = Platform::SubscriberService.new(handler.method(:handle_request), [''], MockLogger.new)
        
        service = TransmitterService.new(@registry)
        begin
          service.start('tcp://*:29000')
  
          subscr.start('tcp://localhost:20000')
          service.broadcast_message(@timestamp, @sample_message)
          
          # Wait a very short time to allow for message delivery 
          sleep(0.01)
        ensure
          service.stop
          subscr.stop
        end
      end
    end
  end 
end