require 'spec_helper'

module Service::Platform
  describe ServiceManager do
    it "starts and stops all services in its bindings" do
      service_mock_class = Class.new do
        @@started = []
        @@stopped = []
        
        def initialize(registry)
        end
        
        def start(endpoint)
          @@started << endpoint
          @endpoint = endpoint    
        end
        
        def stop()
          @@stopped << @endpoint
        end
        
        def self.started
          @@started
        end
        
        def self.stopped
          @@stopped
        end
      end
      
      sm = ServiceManager.new
      sm.bindings = [{:endpoint => 'tcp://*:21000', :service => service_mock_class},
                     {:endpoint => 'tcp://*:21001', :service => service_mock_class}]
      sm.start
      service_mock_class.started.should include('tcp://*:21000', 'tcp://*:21000')
      sm.stop
      service_mock_class.stopped.should include('tcp://*:21000', 'tcp://*:21000')
    end
  end
end