shared_examples_for "a service" do
  it "can be started and stopped and registers itself" do
    service = described_class.new(MockRegistry.new)
    service.should_receive(:register_self)
    service.start('tcp://*:21000')
    service.stop
    
    # Give some time for sockets to free
    sleep(0.1)
  end    
end