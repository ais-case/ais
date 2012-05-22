shared_examples_for "a service" do
  it "can be started and stopped" do
    service = described_class.new(Service::Platform::ServiceRegistry.new)
    service.start('tcp://*:21000')
    service.stop
  end    
end