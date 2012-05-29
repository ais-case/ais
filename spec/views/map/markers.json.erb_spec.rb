require 'spec_helper'

describe "map/markers.json.erb" do
  it "renders a list of markers" do
    
    marker_mock_class = Class.new do
      attr_reader :id, :position
             
      def initialize(i)
        @id = i
        @position = Domain::LatLon.new(50.0 + i/10, 4.0 + i/10)
      end  
    end
        
    markers = []
    for i in 1..5 do
      markers << marker_mock_class.new(i) 
    end
    assign(:markers, markers)
    render
    expected = ActiveSupport::JSON.encode({:markers => markers})
    normalized = ActiveSupport::JSON.encode(ActiveSupport::JSON.decode rendered)  
    normalized.should eql(expected)
  end

  it "is empty when no markers are visible" do
    markers = []
    assign(:markers, markers)
    render
    ActiveSupport::JSON.decode(rendered).should eql({"markers" => []})
  end
  
end
