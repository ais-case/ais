require 'spec_helper'

module Service
  describe MessageService do
    before(:all) do
      @sample_type    = 1
      @sample_payload = "13OF<80vh2wgiJJNes7EMGrD0<0e"
    end
    
    before(:each) do
      @registry = MockRegistry.new
      Thread.new do end
    end
      
    it_behaves_like "a service"
    
    it "publishes processed messages" do
      # Set up proxy for decoder and checksum
      proxy = double('Proxy')
      proxy.stub(:decode).and_return('1')
      @registry.stub(:bind).and_yield(proxy)

      timestamp = "%0.9f" % Time.new.to_f
      service = MessageService.new(@registry)
      service.should_receive(:publish_message).with(@sample_type, timestamp, @sample_payload)
      service.process_message("%s %s" % [timestamp, @sample_payload])
    end

    it "listens for AIS payloads" do
      payloads = ['23afKn5P070CqEdMd<TqIwv6081W']
      
      ctx = ZMQ::Context.new
      sock = ctx.socket(ZMQ::PUB)
      begin
        rc = sock.bind('tcp://*:21013')
        ZMQ::Util.resultcode_ok?(rc).should be_true
        @registry.register('ais/combiner', 'tcp://localhost:21013')
        
        service = (Class.new(MessageService) do
          attr_reader :received_data
          def process_message(data)
            @received_data = data
          end
        end).new(@registry)

        service.start('tcp://*:23001')
        payloads.each do |payload|
          message = "%0.9f %s" % [Time.new.to_f, payload]
          sock.send_string(message)

          # Give service time to receive and process message
          sleep(0.01)
          service.received_data.should eq(message)  
        end
        service.stop
      ensure
        sock.close
      end
    end

    it "broadcasts published messages to subscribers" do
      timestamp = "%0.9f%" % Time.new.to_f
      expected = "%s %s %s" % [@sample_type, timestamp, @sample_payload]
      handler = double('Subscriber')
      handler.should_receive(:handle_request).with(expected)

      subscr = Platform::SubscriberService.new(handler.method(:handle_request), ['1 '], MockLogger.new)
      
      service = MessageService.new(@registry)
      begin
        service.start('tcp://*:29000')

        subscr.start('tcp://localhost:29000')    
        service.publish_message(@sample_type, timestamp, @sample_payload)
        
        # Wait a very short time to allow for message delivery 
        sleep(0.1)
      ensure
        service.stop
        subscr.stop
      end
    end
  end
end