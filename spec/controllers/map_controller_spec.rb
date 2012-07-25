require 'spec_helper'

describe MapController do
  before(:each) do
    @vessel1 = Domain::Vessel.new(1234, Domain::Vessel::CLASS_A)
    @vessel1.position = Domain::LatLon.new(20, 10)
    @vessel2 = Domain::Vessel.new(5678, Domain::Vessel::CLASS_A)
    @vessel2.position = Domain::LatLon.new(10, 10)
    @vessel3 = Domain::Vessel.new(9012, Domain::Vessel::CLASS_A)

    @service_class = Class.new do
      def initialize(vessels)
        @vessels = vessels
      end
    
      def vessels
        @vessels
      end
      
      def info(id)
        @vessels
      end
    end
  end

  describe "GET markers" do

    it "returns markers" do
      vessels = [@vessel1, @vessel2]
      markers = vessels.map { |v| MarkerFactory.from_vessel(v) }
      
      @controller.vessel_service = @service_class.new(vessels)
      
      get :markers, :format => :json
      response.should be_success
      assigns[:markers].should eq(markers)
    end

    it "only returns markers when the vessels have a position" do
      vessels = [@vessel1, @vessel3]
      @controller.vessel_service = @service_class.new(vessels)
      get :markers, :format => :json
      response.should be_success
      assigns[:markers].should eq([MarkerFactory.from_vessel(@vessel1)])
    end      

    it "only returns markers in a specific area when such an area is provided" do
      vessels = [@vessel1, @vessel2, @vessel3]
      proxy = double('Proxy')
      proxy.should_receive(:vessels).with(Domain::LatLon.new(5.5, 5), Domain::LatLon.new(15.0, 11.3)) { [@vessel2] }
             
      @controller.vessel_service = proxy
      get :markers, {'area' => '5.5,5_15.0,11.3', :format => :json}
      response.should be_success
      assigns[:markers].should eq([MarkerFactory.from_vessel(@vessel2)])
    end      
  end

  describe "GET info" do
    it "assigns a vessel" do
      @controller.vessel_service = @service_class.new(@vessel1)

      get :info, :id => 1234
      response.should be_success
      assigns[:vessel].should eq(@vessel1)
    end
  end
end
