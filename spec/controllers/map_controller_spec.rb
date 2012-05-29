require 'spec_helper'
include Domain

class MockServiceRegistry
  def initialize(vessels)
    @vessels = vessels
  end
  
  def bind(name)
    yield MockProxy.new(@vessels)
  end
  
  def terminate()
  end
end

class MockProxy
  def initialize(vessels)
    @vessels = vessels
  end

  def vessels
    @vessels
  end
end

describe MapController do
  describe "get_registry" do
    it "returns a registry" do
      @controller.get_registry
    end
  end

  describe "GET markers" do
    before(:each) do
      @vessel1 = Domain::Vessel.new(1234, Domain::Vessel::CLASS_A)
      @vessel1.position = Domain::LatLon.new(20, 10)
      @vessel2 = Domain::Vessel.new(5678, Domain::Vessel::CLASS_A)
      @vessel2.position = Domain::LatLon.new(10, 10)
      @vessel3 = Domain::Vessel.new(9012, Domain::Vessel::CLASS_A)
    end

    it "returns markers" do
      vessels = [@vessel1, @vessel2]
      markers = vessels.map { |v| Marker.from_vessel(v) }
      
      @controller.registry = MockServiceRegistry.new(vessels)
      get :markers, :format => :json
      response.should be_success
      assigns[:markers].should eq(markers)
    end

    it "only returns markers when the vessels have a position" do
      vessels = [@vessel1, @vessel3]
      @controller.registry = MockServiceRegistry.new(vessels)            
      get :markers, :format => :json
      response.should be_success
      assigns[:markers].should eq([Marker.from_vessel(@vessel1)])
    end      

    it "only returns markers in a specific area when such an area is provided" do
      vessels = [@vessel1, @vessel2, @vessel3]
      proxy = double('Proxy')
      proxy.should_receive(:vessels).with(LatLon.new(5.5, 5), LatLon.new(15.0, 11.3)) { [@vessel2] }
      
      a_registry = (Class.new(MockRegistry) do
        def initialize(prox)
          @prox = prox
        end
        
        def bind(name)
          yield @prox
        end  
      end).new(proxy)
       
      @controller.registry = a_registry
      get :markers, {'area' => '5.5,5_15.0,11.3', :format => :json}
      response.should be_success
      assigns[:markers].should eq([Marker.from_vessel(@vessel2)])
    end      
  end
end
