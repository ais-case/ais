require 'spec_helper'
require 'timeout'

module Service::Platform
  describe PublisherService do

    it "publishes messages" do
      service = PublisherService.new MockLogger.new
      service.start('tcp://*:26005')

      sleep(0.01)
      
      received = Queue.new
      sub = Thread.new do
        ctx = ZMQ::Context.new
        sock = ctx.socket(ZMQ::SUB)
        sock.setsockopt(ZMQ::SUBSCRIBE, '')
        begin
          rc = sock.connect('tcp://localhost:26005')
          ZMQ::Util.resultcode_ok?(rc).should be_true
          sleep(0.01)
          received.push(nil)
          loop do
            sock.recv_string(data='')
            received.push(data)
          end
        rescue
          received.push(false)
        ensure
          sock.close
        end
      end

      Timeout::timeout(1) do
        received.pop.should be_nil
        service.publish('hello world')
        received.pop.should eq('hello world')
      end
    end    
  end
end