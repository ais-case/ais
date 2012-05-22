require 'spec_helper'

module Service::Platform
  describe SubscriberService do
    it "accepts lists for updates on a socket" do
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
      service = SubscriberService.new(handler.method(:handle_request), ["TEST"])
       
      ctx = ZMQ::Context.new
      sock = ctx.socket ZMQ::PUB
      rc = sock.bind('tcp://*:26000')
      ZMQ::Util.resultcode_ok?(rc).should be_true
      sleep(2)
      begin
        service.start('tcp://localhost:26000')
        sock.send_string("TEST Hello World!")
        sock.send_string("OTHER Other message!")
        sleep(1)
        handler.data.should eq("TEST Hello World!")    
      ensure
        sock.close
        service.stop
      end
    end    
  end
end