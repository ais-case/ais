require 'spec_helper'

module Service
  describe MessageService do
    it_behaves_like "a service"
    
    it "listens for raw AIS data from a local TCP server on port 20000" do
      
      # Set up a mock TCP server that sends out a single 
      # message when the first client connects
      server = Thread.new(TCPServer.new(20000)) do |socket|
        begin
          client = socket.accept
          client.puts("!AIVDM,1,1,,B,13OF<80vh2wgiJJNes7EMGrD0<0e,0*00")
        ensure 
          socket.close
        end
      end
      
      service = MessageService.new(Platform::ServiceRegistry.new)
      service.should_receive(:process_message).with("!AIVDM,1,1,,B,13OF<80vh2wgiJJNes7EMGrD0<0e,0*00\n")        
      service.start('tcp://*:28000')
      
      # Wait for mock TCP server to finish request
      timeout(1) do
        server.join
      end

      service.stop
    end
  
    it "publishes processed messages" do
      service = MessageService.new(Platform::ServiceRegistry.new)
      service.should_receive(:publish_message).with(1,"13OF<80vh2wgiJJNes7EMGrD0<0e")
      service.process_message("!AIVDM,1,1,,B,13OF<80vh2wgiJJNes7EMGrD0<0e,0*00")
    end
    
    it "broadcasts published messages to subscribers" do
      handler = double('Subscriber')
      handler.should_receive(:handle_request).with("1 13OF<80vh2wgiJJNes7EMGrD0<0e")

      subscr = Platform::SubscriberService.new(handler.method(:handle_request), ['1 '])
      
      service = MessageService.new(Platform::ServiceRegistry.new)
      begin
        service.start('tcp://*:29000')

        subscr.start('tcp://localhost:29000')    
        service.publish_message(1,"13OF<80vh2wgiJJNes7EMGrD0<0e")
        
        # Wait a very short time to allow for message delivery 
        sleep(0.05)
      ensure
        service.stop
        subscr.stop
      end
    end
  end
end