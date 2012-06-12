require 'spec_helper'

module Service
  describe ComplianceService do    
    before(:each) do
      @registry = MockRegistry.new
    end
      
    it_behaves_like "a service"
    
    
  end
end