require "uri"
require "domain/latlon"
require "domain/vessel"
require "service/lookup"

Given /^vessel "([^"]*)" at position "([^"]*)"$/ do |name, coords_str|
    # Create vessel with given info
    @vessel = Vessel.new Vessel::CLASS_A
    @vessel.name = name
    @vessel.position = LatLon.from_str coords_str

    # Send position report for vessel
    transmitter = Service::lookup('ais/transmitter')
    transmitter.send_position_report_for vessel
end

When /^I view the map area between "([^"]*)" and "([^"]*)"$/ do |coords1_str, coords2_str|
    @browser = Selenium::WebDriver.for :firefox
    point1 = LatLon.from_str coords1_str
    point2 = LatLon.from_str coords2_str
    @browser.navigate_to "/?area=" << URI.encode(point1) << "," << URI.encode(point2)
end

Then /^I should see a vessel at position "([^"]*)"$/ do |point_str|
    position = LatLon.from_str point_str
    marker = @browser.execute_script('return haveMarkerAtLatLon(' << position.lat << ',' << position.lon << ')')
    marker.should eq 'true'
end

Then /^I should not see vessel "([^"]*)"$/ do |name|
    marker = @browser.execute_script('return haveMarkers()')
    marker.should eq 'false'
end
