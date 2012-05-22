require 'spec_helper'

module Service::Platform
  describe SubscriberService do
    it "accepts lists for updates on a socket" do
      handler = double('Handler')
      handler.should_receive(:handle_request).with("TEST Hello World!")
      service = SubscriberService.new(handler.method(:handle_request), ["TEST"])
       
      ctx = ZMQ::Context.new
      sock = ctx.socket ZMQ::PUB
      rc = sock.bind('tcp://*:26000')
      ZMQ::Util.resultcode_ok?(rc).should be_true
      begin
        service.start('tcp://localhost:26000')
        sock.send_string("OTHER Other message 1!")
        sock.send_string("TEST Hello World!")
        sock.send_string("OTHER Other message 2!")
        sleep(0.05)
      ensure
        sock.close
        service.stop
      end
    end    
  end
end