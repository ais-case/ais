require 'spec_helper'

module Service
  describe ReceiverService do
    it_behaves_like "a service"

    before(:all) do
      @valid_message = "!AIVDM,1,1,,B,13OF<80vh2wgiJJNes7EMGrD0<0e,0*00"
      @invalid_message = "!AIVDM,1,1,,B,13OF<80vh2wgiJJNes7EMGrD0<0e,0*11"
    end
    
    before(:each) do
      @registry = MockRegistry.new
      sleep(0.1)
      @server_queue = Queue.new
      @server = Thread.new(TCPServer.new(20000)) do |socket|
        begin
          client = socket.accept
          client.puts(@server_queue.pop)
        ensure 
          socket.close
        end
      end
    end
      
    after(:each) do
      @server.kill
      @server = nil
      @server_queue = nil
    end
    
    it "listens for raw AIS data from a local TCP server on port 20000" do
      service = ReceiverService.new(@registry)
      service.should_receive(:process_message).with(@valid_message)
      service.start('tcp://*:28000')
      
      # Wait for mock TCP server to finish request
      timeout(1) do
        @server_queue.push(@valid_message)
        @server.join
      end

      service.stop
    end
  
    it "publishes messages with valid checksums" do
      service = ReceiverService.new(@registry)
      service.should_receive(:publish_message).with(@valid_message)
      service.process_message(@valid_message)
    end

    it "does not publish messages with invalid checksums" do
      service = ReceiverService.new(@registry)
      service.should_not_receive(:publish_message)
      service.process_message(@invalid_message)
    end
    
    it "broadcasts published messages to subscribers" do
      handler = double('Subscriber')
      handler.should_receive(:handle_request).with("SENTENCE #{@valid_message}")

      subscr = Platform::SubscriberService.new(handler.method(:handle_request), ['SENTENCE '], MockLogger.new)
      
      service = ReceiverService.new(@registry)
      begin
        service.start('tcp://*:29000')

        subscr.start('tcp://localhost:29000')    
        service.publish_message(@valid_message)
        
        # Wait a very short time to allow for message delivery 
        sleep(0.1)
      ensure
        service.stop
        subscr.stop
      end
    end
  end
end