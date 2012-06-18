require 'spec_helper'

module Service
  describe ReceiverService do
    it_behaves_like "a service"

    before(:all) do
      @timestamp = "%0.9f" % Time.new.to_f
      @valid_message = "!AIVDM,1,1,,B,13OF<80vh2wgiJJNes7EMGrD0<0e,0*00"
      @invalid_message = "!AIVDM,1,1,,B,13OF<80vh2wgiJJNes7EMGrD0<0e,0*11"
    end
    
    before(:each) do
      @registry = MockRegistry.new
    end
          
    it "listens for raw AIS data published by a remote host" do
      ctx = ZMQ::Context.new
      sock = ctx.socket(ZMQ::PUB)
      begin
        rc = sock.bind('tcp://*:21011')
        ZMQ::Util.resultcode_ok?(rc).should be_true
        @registry.register('ais/transmitter-pub', 'tcp://localhost:21011')
        
        service = (Class.new(ReceiverService) do
          attr_reader :received_data
          def process_message(data)
            @received_data = data
          end
        end).new(@registry)

        service.start('tcp://*:23003')
        sock.send_string(@valid_message)

        # Give service time to receive and process message
        sleep(0.01)
        service.received_data.should eq(@valid_message)  
        service.stop
      ensure
        sock.close
      end    
    end
  
    it "publishes messages with valid checksums" do
      service = ReceiverService.new(@registry)
      service.should_receive(:publish_message).with(@timestamp, @valid_message)
      service.process_message("%s %s" % [@timestamp, @valid_message])
    end

    it "does not publish messages with invalid checksums" do
      service = ReceiverService.new(@registry)
      service.should_not_receive(:publish_message)
      service.process_message("%s %s" % [@timestamp, @invalid_message])
    end
    
    it "broadcasts published messages to subscribers" do
      handler = double('Subscriber')
      handler.should_receive(:handle_request).with("%s %s" % [@timestamp, @valid_message])

      subscr = Platform::SubscriberService.new(handler.method(:handle_request), [''], MockLogger.new)
      
      service = ReceiverService.new(@registry)
      begin
        service.start('tcp://*:29000')

        subscr.start('tcp://localhost:29000')    
        service.publish_message(@timestamp, @valid_message)
        
        # Wait a very short time to allow for message delivery 
        sleep(0.1)
      ensure
        service.stop
        subscr.stop
      end
    end
  end
end