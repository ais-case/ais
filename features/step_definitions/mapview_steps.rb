require 'uri'
require 'domain/latlon'
require 'domain/vessel'
require 'service'
require 'capybara/rails'

Capybara.current_driver = Capybara.javascript_driver

Given /^vessel "([^"]*)" at position "([^"]*)"$/ do |name, coords_str|
    # Create vessel with given info
    @vessel = Vessel.new Vessel::CLASS_A
    @vessel.name = name
    @vessel.position = LatLon.from_str coords_str

    # Send position report for vessel
    service = Service.new
    transmitter = service.bind 'ais/transmitter'
    transmitter.send_position_report_for @vessel
    service.terminate
end

When /^I view the map area between "([^"]*)" and "([^"]*)"$/ do |coords1_str, coords2_str|
    point1 = LatLon.from_str coords1_str
    point2 = LatLon.from_str coords2_str
    visit "http://localhost/?area=" << URI.encode(point1.to_s) << "," << URI.encode(point2.to_s)
end

Then /^I should see a vessel at position "([^"]*)"$/ do |point_str|
    position = LatLon.from_str point_str
    marker = page.evaluate_script('return haveMarkerAtLatLon(' << position.lat.to_s << ',' << position.lon.to_s << ')')
    marker.should eq 'true'
end

Then /^I should not see vessel "([^"]*)"$/ do |name|
    marker = page.evaluate_script('return haveMarkers()')
    marker.should eq 'false'
end
