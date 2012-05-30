require 'spec_helper'

describe "map/info.html.erb" do
  it "returns info for vessel with given mssi" do
    vessel = Domain::Vessel.new(898989, Domain::Vessel::CLASS_A)
    vessel.position = Domain::LatLon.new(52.1, 3.92)
    vessel.heading = 180
    vessel.speed = 30.56
    vessel.type = Domain::VesselType.from_str("Passenger")
    
    assign(:vessel, vessel)
    render

    details = [vessel.mmsi, vessel.position, vessel.heading, vessel.speed, vessel.type.description]
    texts = details.map { |o| o.to_s }
    texts.each do |text|
      if not rendered.include?(text)
        err = "Text '#{text}' not found in view"
        raise err
      end 
    end
  end
  
  it "handles vessel with only minimal info" do
    vessel = Domain::Vessel.new(898989, Domain::Vessel::CLASS_A)
    
    assign(:vessel, vessel)
    render
  end
  
  it "handles vessel with only position info" do
    vessel = Domain::Vessel.new(898989, Domain::Vessel::CLASS_A)
    vessel.position = Domain::LatLon.new(52.1, 3.92)
    vessel.heading = 180
    vessel.speed = 30.56
    
    assign(:vessel, vessel)
    render

    details = [vessel.mmsi, vessel.position, vessel.heading, vessel.speed]
    texts = details.map { |o| o.to_s }
    texts.each do |text|
      if not rendered.include?(text)
        err = "Text '#{text}' not found in view"
        raise err
      end 
    end
  end
end
