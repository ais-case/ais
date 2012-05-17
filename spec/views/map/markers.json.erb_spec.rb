require 'spec_helper'

describe "map/markers.json.erb" do
  it "renders a list of markers" do
    
    vessels = []
    for i in 1..5 do
      vessels << Class.new do
        @position = "Hello #{i}"
        def self.position 
          @position
        end
      end  
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
