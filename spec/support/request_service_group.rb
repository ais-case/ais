shared_examples_for "a request service" do
  it "starts and stops a request service" do
    request_service = double('RequestService')
    request_service.should_receive(:start).with('tcp://*:21000')
    request_service.should_receive(:stop)

    service = described_class.new
    service.request_service = request_service
    service.start('tcp://*:21000')
    service.stop
  end    
end