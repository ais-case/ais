require 'spec_helper'

module Service::Platform
  describe ReplyService do
    it "accepts requests on a socket" do
      handler = double('Handler')
      handler.should_receive(:handle_request).with("Test Request") { "Test Response" }
      service = ReplyService.new(handler.method(:handle_request))
      service.start('tcp://*:22000')
       
      ctx = ZMQ::Context.new
      sock = ctx.socket ZMQ::REQ
      rc = sock.connect 'tcp://localhost:22000'
      ZMQ::Util.resultcode_ok?(rc).should be_true
      begin
        sock.send_string("Test Request")
        response = ''
        sock.recv_string(response)
        response.should eq("Test Response")
      ensure
        sock.close
        service.stop
      end
    end    
  end
end