require 'spec_helper'

module Service::Platform
  describe ServiceManager do
    before(:each) do
      @manager = ServiceManager.new
    end
    
    it "starts and stops" do
      @manager.start
      @manager.stop
    end
    
    it "chooses a random endpoint for the registry" do
      @manager.get_registry_endpoint.should match(/tcp:\/\/localhost:21\d{3}/)
    end
  end
end