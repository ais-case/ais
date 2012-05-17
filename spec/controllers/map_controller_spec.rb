require 'spec_helper'

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
  describe "GET markers" do
    before(:each) do
      @vessel1 = Vessel.new(Vessel::CLASS_A)
      @vessel1.position = LatLon.new(20, 10)
      @vessel2 = Vessel.new(Vessel::CLASS_A)
      @vessel2.position = LatLon.new(10, 10)
      @vessel3 = Vessel.new(Vessel::CLASS_A)
    end

    it "returns markers" do
      vessels = [@vessel1, @vessel2]
      @controller.registry = MockServiceRegistry.new(vessels)
      get :markers, :format => :json
      response.should be_success
      assigns[:markers].should eql(vessels)
    end

    it "only returns markers when the vessels have a position" do
      vessels = [@vessel1, @vessel3]
      @controller.registry = MockServiceRegistry.new(vessels)            
      get :markers, :format => :json
      response.should be_success
      assigns[:markers].should eql([@vessel1])
    end      
  end
end
