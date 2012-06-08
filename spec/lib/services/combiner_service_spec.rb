require 'spec_helper'

module Service
  describe CombinerService do
    before(:all) do
      @sample_payload = "13OF<80vh2wgiJJNes7EMGrD0<0e"
    end
    
    before(:each) do
      @registry = MockRegistry.new
    end
      
    it_behaves_like "a service"
  
    it "publishes processed messages" do
      message = "SENTENCE !AIVDM,1,1,,B,13OF<80vh2wgiJJNes7EMGrD0<0e,0*00"
      service = CombinerService.new(@registry)
      service.should_receive(:publish_message).with(@sample_payload)
      service.process_message(message)
    end

    it "aggregates multi-fragment messages before publishing" do
      payload1 = "53aaW@00000000000000000000000000000000160000000000000000"
      payload2 = "00000000000000"

      service = CombinerService.new(@registry)
      service.should_receive(:publish_message).with(payload1 + payload2)
      service.process_message("SENTENCE !AIVDM,2,1,,A,#{payload1},0*33")
      service.process_message("SENTENCE !AIVDM,2,2,,A,#{payload2},0*26")
    end
    
    it "listens for AIS sentences" do
      sentences = ['!AIVDM,1,1,,A,23afKn5P070CqEdMd<TqIwv6081W,0*64']
      
      ctx = ZMQ::Context.new
      sock = ctx.socket(ZMQ::PUB)
      begin
        rc = sock.bind('tcp://*:21013')
        ZMQ::Util.resultcode_ok?(rc).should be_true
        @registry.register('ais/receiver', 'tcp://localhost:21013')
        
        service = (Class.new(CombinerService) do
          attr_reader :received_data
          def process_message(data)
            @received_data = data
          end
        end).new(@registry)

        service.start('tcp://*:23001')
        sentences.each do |sentence|
          sock.send_string('SENTENCE ' << sentence)

          # Give service time to receive and process message
          sleep(0.1)
          service.received_data.should eq('SENTENCE ' << sentence)  
        end
        service.stop
      ensure
        sock.close
      end
    end
    
    it "broadcasts published messages to subscribers" do
      handler = double('Subscriber')
      handler.should_receive(:handle_request).with("PAYLOAD #{@sample_payload}")

      subscr = Platform::SubscriberService.new(handler.method(:handle_request), ['PAYLOAD '], MockLogger.new)
      service = CombinerService.new(@registry)
      begin
        service.start('tcp://*:29000')
        subscr.start('tcp://localhost:29000')
        service.publish_message(@sample_payload)
        
        # Wait a very short time to allow for message delivery 
        sleep(0.1)
      ensure
        service.stop
        subscr.stop
      end
    end
  end
end