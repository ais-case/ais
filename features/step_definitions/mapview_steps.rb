require 'uri'
require 'capybara/rails'

Before do
  Capybara.current_driver = Capybara.javascript_driver
  @manager = Service::Platform::ServiceManager.new
  @manager.start
  @registry = @manager.registry_proxy
end

After do |scenario|
  @manager.stop
end

Given /^vessel "([^"]*)" at position "([^"]*)"$/ do |name, coords_str|
  # Create vessel with given info
  @vessel = Domain::Vessel.new(1234, Domain::Vessel::CLASS_A)
  @vessel.name = name
  @vessel.position = Domain::LatLon.from_str(coords_str)

  # Send position report for vessel
  @registry.bind('ais/transmitter') do |service|
    service.send_position_report_for @vessel
  end
end

When /^I view the homepage$/ do
  visit root_path
end

When /^I see the map area between "([^"]*)" and "([^"]*)"$/ do |coords1_str, coords2_str|
  point1 = Domain::LatLon.from_str coords1_str
  point2 = Domain::LatLon.from_str coords2_str
  visit "#{map_path}##{URI::encode(point1.to_s)}_#{URI::encode(point2.to_s)}"
end

Then /^I should see a map of the area around "(.*?)"$/ do |coords|
  point = Domain::LatLon.from_str coords
  visible = page.evaluate_script('map.isCenteredAt(new LatLon(' << point.lat.to_s << ',' << point.lon.to_s << '))')
  visible.should eq true
end

Then /^I should see a vessel at position "([^"]*)"$/ do |point_str|
  position = Domain::LatLon.from_str point_str
  has_vessel = page.evaluate_script('map.hasMarkerAt(new LatLon(' << position.lat.to_s << ',' << position.lon.to_s << '))')
  has_vessel.should eq true
end