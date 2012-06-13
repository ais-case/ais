require 'spec_helper'

module Service
  describe ComplianceService do    
    before(:each) do
      @registry = MockRegistry.new
    end
      
    it_behaves_like "a service"
    
    it "listens for AIS messages reports" do
      raw = {1 => "#{Time.new.to_f} 13`wgT0P5fPGmDfN>o?TN?vN2<05",
             2 => "#{Time.new.to_f} 23`wgT0P5fPGmDfN>o?TN?vN2<05",
             3 => "#{Time.new.to_f} 33`wgT0P5fPGmDfN>o?TN?vN2<05",
             5 => "#{Time.new.to_f} 53u=:PP00001<H?G7OI0ThuB37G61<F22222220j1042240Ht2P00000000000000000008"}

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

    describe "process_message" do
      it "adds expectations to the queue" do
        payload1 = "50004lP00000000000000000000000000000000t0000000000000000000000000000000"
        payload2 = "50005lP00000000000000000000000000000000t0000000000000000000000000000000"
      
        proxy = double('Proxy')
        proxy.stub(:decode).with(payload1).and_return(Domain::AIS::SixBitEncoding.decode(payload1))
        proxy.stub(:decode).with(payload2).and_return(Domain::AIS::SixBitEncoding.decode(payload2))
        @registry.stub(:bind).and_yield(proxy)
        
        queue = double('Queue')

        service = ComplianceService.new(@registry)
        service.expected = queue

        last = Time.new.to_f

        messages = [
          {:ts => last - 400, :mmsi => 1490, :payload => payload2},
          {:ts => last - 360 - 1, :mmsi => 1234, :payload => payload1},
          {:ts => last - 90, :mmsi => 1490, :payload => payload2},
          {:ts => last, :mmsi => 1234, :payload => payload1}
          ]
          
        messages.each do |msg|
          queue.should_receive(:push).with([msg[:ts], msg[:ts] + 360, msg[:mmsi]])
          service.process_message("5 #{msg[:ts]} #{msg[:payload]}")
        end        
      end
    end
    
    describe "check_compliance" do
      it "broadcasts when the interval between static reports is longer than 6 minutes" do
        queue = Queue.new
        recv = {}
        publisher = double('Publisher')
        publisher.should_receive(:publish).with("NON-COMPLIANT 1234")
        
        expect_at = Time.new.to_f
        last = expect_at - 361.0
        recv[1234] = Queue.new
        recv[1234].push(last)
        recv[1234].push(last + 361.0)
        queue.push([last, expect_at, 1234])
       
        service = ComplianceService.new(@registry)
        service.check_compliance(publisher.method(:publish), queue, recv)
      end

      it "does not broadcast when the interval between static reports is 6 minutes or shorter" do
        queue = Queue.new
        recv = {}
        publisher = double('Publisher')
        publisher.should_not_receive(:publish)
        
        expect_at = Time.new.to_f
        last = expect_at - 360.0
        recv[1234] = Queue.new
        recv[1234].push(last)
        recv[1234].push(last + 359.0)
        queue.push([last, expect_at, 1234])
        
        service = ComplianceService.new(@registry)
        service.check_compliance(publisher.method(:publish), queue, recv)
      end
    end  
  end
end