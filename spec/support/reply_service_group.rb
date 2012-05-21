shared_examples_for "a reply service" do
  it "starts and stops a reply service" do
    reply_service = double('ReplyService')
    reply_service.should_receive(:start).with('tcp://*:21000')
    reply_service.should_receive(:stop)

    service = described_class.new(Service::ServiceRegistry.new)
    service.reply_service = reply_service
    service.start('tcp://*:21000')
    service.stop
  end    
end