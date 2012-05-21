require 'spec_helper'

module Service
  describe ReplyService do
    it "accepts requests on a socket" do
      handler_class = Class.new do
        def handle_request(data)
          data
        end
      end

      handler = handler_class.new
      service = ReplyService.new(handler.method(:handle_request))
      service.start('tcp://*:22000')
       
      ctx = ZMQ::Context.new
      sock = ctx.socket ZMQ::REQ
      rc = sock.connect 'tcp://localhost:22000'
      ZMQ::Util.resultcode_ok?(rc).should be_true
      begin
        sock.send_string(Marshal.dump("Test"))
        response = ''
        sock.recv_string(response)
        response.should eq(Marshal.dump("Test"))
      ensure
        sock.close
        service.stop
      end
    end    
  end
end