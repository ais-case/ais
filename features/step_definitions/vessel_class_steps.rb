Given /^vessel "(.*?)" of class "(.*?)"$/ do |name, class_str|
  vessel_class = (class_str == 'B') ? Domain::Vessel::CLASS_B : Domain::Vessel::CLASS_A
  @vessel = Domain::Vessel.new(42, vessel_class)
  @vessel.name =  name
  @vessel.heading = 90
  @vessel.position = Domain::LatLon.new(52, 4.2)

  @registry.bind('ais/transmitter') do |service|
    service.send_position_report_for(@vessel)
  end
end

Then /^vessel "(.*?)" should have shape "(.*?)"$/ do |name, shape|
  @vessel.name.should eq(name)
  position = @vessel.position
  marker = (@vessel.vessel_class == Domain::Vessel::CLASS_A) ? 'a_e' : 'b_e'
  args = [position.lat, position.lon, marker]
  js = "map.hasMarkerAt(new LatLon(%f,%f), '%s')" % args
  has_vessel = page.evaluate_script(js)
  has_vessel.should be_true
end
