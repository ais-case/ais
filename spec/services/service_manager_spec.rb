require 'spec_helper'

module Service
  describe ServiceManager do
    it "starts and stops all services in its bindings" do
      class ServiceMock
        @@started = []
        @@stopped = []
        
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
      sm.bindings = [{:endpoint => 'tcp://*:21000', :service => ServiceMock},
                     {:endpoint => 'tcp://*:21001', :service => ServiceMock}]
      sm.start
      ServiceMock.started.should include('tcp://*:21000', 'tcp://*:21000')
      sm.stop
      ServiceMock.stopped.should include('tcp://*:21000', 'tcp://*:21000')
    end
  end
end