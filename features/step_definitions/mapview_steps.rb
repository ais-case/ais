require "uri"
require "service/lookup"
require "domain/vessel"

Given /^vessel "([^"]*)" at position "([^"]*)"$/ do |name, point_str|
    # Create vessel with given info
    @vessel = Vessel.new Vessel::CLASS_A
    @vessel.name = name
    @vessel.position = PointParser.parse point_str

    # Send position report for vessel
    transmitter = Service::lookup('ais/transmitter')
    transmitter.send_position_report_for vessel
end

When /^I view the map area between "([^"]*)" and "([^"]*)"$/ do |point1_str, point2_str|
    @browser = Selenium::WebDriver.for :firefox
    point1 = PointParser.parse point1_str
    point2 = PointParser.parse point2_str
    @browser.navigate_to "/?area=" << URI.encode(point1) << "," << URI.encode(point2)
end

Then /^I should see a vessel at position "([^"]*)"$/ do |point_str|
    point = PointParser.parse point_str
    marker = @browser.execute_script('return haveMarkerAtLatLon(' << point.lat << ',' << point.lon << ')')
    marker.should eq 'true'
end

Then /^I should not see vessel "([^"]*)"$/ do |name|
    marker = @browser.execute_script('return haveMarkers()')
    marker.should eq 'false'
end
