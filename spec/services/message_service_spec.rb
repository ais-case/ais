require 'spec_helper'

module Service
  describe MessageService do
    before(:all) do
      @sample_message = "!AIVDM,1,1,,B,13OF<80vh2wgiJJNes7EMGrD0<0e,0*00"
      @sample_type    =                1
      @sample_payload =               "13OF<80vh2wgiJJNes7EMGrD0<0e"
    end
    
    before(:each) do
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
    
    it_behaves_like "a service"
    
    it "listens for raw AIS data from a local TCP server on port 20000" do
      service = MessageService.new(Platform::ServiceRegistry.new)
      service.should_receive(:process_message).with(@sample_message << "\n")
      service.start('tcp://*:28000')
      
      # Wait for mock TCP server to finish request
      timeout(1) do
        @server_queue.push(@sample_message)
        @server.join
      end

      service.stop
    end
  
    it "publishes processed messages" do
      service = MessageService.new(Platform::ServiceRegistry.new)
      service.should_receive(:publish_message).with(@sample_type, @sample_payload)
      service.process_message(@sample_message)
    end
    
    it "broadcasts published messages to subscribers" do
      handler = double('Subscriber')
      handler.should_receive(:handle_request).with("#{@sample_type} #{@sample_payload}")

      subscr = Platform::SubscriberService.new(handler.method(:handle_request), ['1 '])
      
      service = MessageService.new(Platform::ServiceRegistry.new)
      begin
        service.start('tcp://*:29000')

        subscr.start('tcp://localhost:29000')    
        service.publish_message(@sample_type, @sample_payload)
        
        # Wait a very short time to allow for message delivery 
        sleep(0.05)
      ensure
        service.stop
        subscr.stop
      end
    end
  end
end