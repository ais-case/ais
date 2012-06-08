require 'spec_helper'

module Service
  describe MessageService do
    before(:all) do
      @sample_message = "!AIVDM,1,1,,B,13OF<80vh2wgiJJNes7EMGrD0<0e,0*00"
      @sample_type    =                1
      @sample_payload =               "13OF<80vh2wgiJJNes7EMGrD0<0e"
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
    
    it_behaves_like "a service"
    
    it "listens for raw AIS data from a local TCP server on port 20000" do
      service = MessageService.new(@registry)
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
      # Set up proxy for decoder and checksum
      proxy = double('Proxy')
      proxy.stub(:decode).and_return('1')
      proxy.stub(:verify).and_return(true)
      @registry.stub(:bind).and_yield(proxy)

      service = MessageService.new(@registry)
      service.should_receive(:publish_message).with(@sample_type, @sample_payload)
      service.process_message(@sample_message)
    end

    it "does not publish messages with invalid checksums" do
      # Set up proxy for decoder and checksum
      proxy = double('Proxy')
      proxy.stub(:decode).and_return('101')
      proxy.stub(:verify).and_return(false)
      @registry.stub(:bind).and_yield(proxy)

      message = @sample_message.dup
      message[20] = 'E'
      service = MessageService.new(@registry)
      service.should_not_receive(:publish_message)
      service.process_message(message)
    end

    it "aggregates multi-fragment messages before publishing" do
      payload1 = "53aaW@00000000000000000000000000000000160000000000000000"
      payload2 = "00000000000000"

      # Set up proxy for decoder and checksum
      proxy = double('Proxy')
      proxy.stub(:decode).and_return('101')
      proxy.stub(:verify).and_return(true)
      @registry.stub(:bind).and_yield(proxy)

      service = MessageService.new(@registry)
      service.should_receive(:publish_message).with(5, payload1 + payload2)
      service.process_message("!AIVDM,2,1,,A,#{payload1},0*33")
      service.process_message("!AIVDM,2,2,,A,#{payload2},0*26")
    end
    
    it "broadcasts published messages to subscribers" do
      handler = double('Subscriber')
      handler.should_receive(:handle_request).with("#{@sample_type} #{@sample_payload}")

      subscr = Platform::SubscriberService.new(handler.method(:handle_request), ['1 '], MockLogger.new)
      
      service = MessageService.new(@registry)
      begin
        service.start('tcp://*:29000')

        subscr.start('tcp://localhost:29000')    
        service.publish_message(@sample_type, @sample_payload)
        
        # Wait a very short time to allow for message delivery 
        sleep(0.1)
      ensure
        service.stop
        subscr.stop
      end
    end
  end
end