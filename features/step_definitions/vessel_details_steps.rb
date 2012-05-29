Given /^vessel "(.*?)" with details:$/ do |name, table|
  @fields = table.rows_hash 
  
  if @fields['Class'] == 'A'
    vessel_class = Domain::Vessel::CLASS_A
  else
    vessel_class = Domain::Vessel::CLASS_B
  end
    
  @vessel = Domain::Vessel.new(@fields['MMSI'], vessel_class)
  @vessel.name =  name
  @vessel.type = Domain::VesselType.from_str(@fields['Type'])
  @vessel.heading = @fields['Heading'].to_f
  @vessel.speed = @fields['Speed'].to_f
  @vessel.position = Domain::LatLon.from_str(@fields['Position'])
end


When /^"(.*?)" sends a position report$/ do |arg1|
  @registry.bind('ais/transmitter') do |service|
    service.send_position_report_for @vessel
  end
end

When /^"(.*?)" sends a voyage report$/ do |arg1|
  @registry.bind('ais/transmitter') do |service|
    service.send_static_report_for @vessel
  end
end

When /^I select vessel "(.*?)" on the map$/ do |name|
  visit map_path
  point = @vessel.position
  page.evaluate_script('map.clickMarker(new LatLon(' << point.lat.to_s << ',' << point.lon.to_s << '))')
end

Then /^I should see all details of vessel "(.*?)"$/ do |name|
  @fields.each do |_, value|
    page.has_content?(value).should be_true
  end
end
