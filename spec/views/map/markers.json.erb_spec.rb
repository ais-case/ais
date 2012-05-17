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
        
    vessels = []
    for i in 1..5 do
      vessels << MarkerMock.new(i) 
    end
    assign(:vessels, vessels)
    render
    expected = ActiveSupport::JSON.encode({:markers => vessels})
    normalized = ActiveSupport::JSON.encode(ActiveSupport::JSON.decode rendered)  
    normalized.should eql(expected)
  end

  it "is empty when no vessels are visible" do
    vessels = []
    assign(:vessels, vessels)
    render
    ActiveSupport::JSON.decode(rendered).should eql({"markers" => []})
  end
  
end
