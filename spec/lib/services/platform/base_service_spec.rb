require 'spec_helper'

module Service::Platform
  describe BaseService do    
    describe "register_self" do
      it "registers the service with its registry" do
        name, endpoint = 'ais/test', 'tcp://*:9999'        
        registry = double('Registry')
        registry.should_receive(:register).with(name, 'tcp://localhost:9999')
        service = BaseService.new(registry)
        service.register_self(name, endpoint)
      end
    end
  end
end