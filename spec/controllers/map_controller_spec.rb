require 'spec_helper'

class MockService
  def initialize(vessels)
    @vessels = vessels
  end
  
  def bind(name)
    MockProxy.new(@vessels)
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
    it "returns all markers" do
      vessels = [Vessel.new(Vessel::CLASS_A), Vessel.new(Vessel::CLASS_A)]
      @controller.service = MockService.new(vessels)
            
      get :markers, :format => :json
      response.should be_success
      assigns[:vessels].should eql(vessels)
    end
  end
end
