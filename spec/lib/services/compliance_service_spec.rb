require 'spec_helper'

module Service
  describe ComplianceService do    
    before(:each) do
      @registry = MockRegistry.new
    end
      
    it_behaves_like "a service"
    
    it "listens for AIS messages reports" do
      raw = {1 => "13`wgT0P5fPGmDfN>o?TN?vN2<05",
             2 => "23`wgT0P5fPGmDfN>o?TN?vN2<05",
             3 => "33`wgT0P5fPGmDfN>o?TN?vN2<05",
             5 => "53u=:PP00001<H?G7OI0ThuB37G61<F22222220j1042240Ht2P00000000000000000008"}

      ctx = ZMQ::Context.new
      sock = ctx.socket(ZMQ::PUB)
      begin
        rc = sock.bind('tcp://*:21012')
        ZMQ::Util.resultcode_ok?(rc).should be_true
        @registry.register('ais/message', 'tcp://localhost:21012')
        
        service = (Class.new(ComplianceService) do
          attr_reader :received_data
          def process_message(data)
            @received_data = data
          end
        end).new(@registry)

        service.start('tcp://*:23000')
        raw.each do |type,data|
          sock.send_string("#{type} " << data)

          # Give service time to receive and process message
          sleep(0.1)
          service.received_data.should eq("#{type} " << data)  
        end
        service.stop
      ensure
        sock.close
      end
    end

    it "broadcasts published messages to subscribers" do
      handler = double('Subscriber')
      handler.should_receive(:handle_request).with("NON-COMPLIANT 12345")

      subscr = Platform::SubscriberService.new(handler.method(:handle_request), [''], MockLogger.new)
      
      service = ComplianceService.new(@registry)
      begin
        service.start('tcp://*:29000')

        subscr.start('tcp://localhost:29000')
        service.publish_message(12345)
        
        # Wait a very short time to allow for message delivery 
        sleep(0.1)
      ensure
        service.stop
        subscr.stop
      end
    end
  end
end