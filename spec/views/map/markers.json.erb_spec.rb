require 'spec_helper'

describe "map/markers.json.erb" do
  it "renders a list of markers" do
    
     class MarkerMock
        def initialize(i)
          @position = LatLon.new(50.0 + i/10, 4.0 + i/10)
        end
        
        def position 
          @position
        end
    end
        
    markers = []
    for i in 1..5 do
      markers << MarkerMock.new(i) 
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
