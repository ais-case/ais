require 'spec_helper'

module Service
  describe MessageService do
    it_behaves_like "a service"
    
    it "listens for raw AIS data" do
      server = Thread.new do
        socket = TCPServer.new(20000)
        begin
          client = socket.accept
          client.puts("!AIVDM,1,1,,B,13OF<80vh2wgiJJNes7EMGrD0<0e,0*00")
        ensure 
          socket.close
        end
      end
      
      sleep(1)

      service = MessageService.new(Platform::ServiceRegistry.new)
      service.should_receive(:process_message).with("!AIVDM,1,1,,B,13OF<80vh2wgiJJNes7EMGrD0<0e,0*00\n")        
      service.start('tcp://*:28000')

      # Give service time to receive and process message
      sleep(0.1)
        
      service.stop
    end
  
    it "publishes incoming messages" do
      service = MessageService.new(Platform::ServiceRegistry.new)
      service.should_receive(:publish_message).with(1,"13OF<80vh2wgiJJNes7EMGrD0<0e")
      service.process_message("!AIVDM,1,1,,B,13OF<80vh2wgiJJNes7EMGrD0<0e,0*00")
    end
    
    it "publishes messages" do
      handler_class = Class.new do
        attr_reader :data
        
        def initialize
          @data = nil
        end
        
        def handle_request(data)
          @data = data
        end
      end

      handler = handler_class.new
      subscr = Platform::SubscriberService.new(handler.method(:handle_request), ['1 '])
      
      service = MessageService.new(Platform::ServiceRegistry.new)
      begin
        service.start('tcp://*:28000')

        subscr.start('tcp://localhost:28000')    
        service.publish_message(1,"13OF<80vh2wgiJJNes7EMGrD0<0e")
        sleep(0.1)
        
        handler.data.should eq("1 13OF<80vh2wgiJJNes7EMGrD0<0e")
      ensure
        subscr.stop
        service.stop
      end
    end
  end
end