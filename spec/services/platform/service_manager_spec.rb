require 'spec_helper'

module Service::Platform
  describe ServiceManager do
    it "starts and stops" do
      sm = ServiceManager.new
      sm.start
      sm.stop
    end
  end
end