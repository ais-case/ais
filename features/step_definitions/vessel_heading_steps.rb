Given /^vessels:$/ do |table|
  @vessels = {}
  delta = 0.01
  table.rows_hash.each do |name,heading|
    next if name == 'name'
    vessel = Domain::Vessel.new(1_000 + (100 * delta).to_i, Domain::Vessel::CLASS_A)
    vessel.name =  name
    vessel.heading = heading.to_f
    vessel.position = Domain::LatLon.new(51.81 + delta, 4.0 + 10 * delta)
    @vessels[name] = vessel
    
    @registry.bind('ais/transmitter') do |service|
      service.send_position_report_for(vessel)
    end
    delta += 0.01
  end   
end

When /^I view the map$/ do
  visit map_path
end

Then /^I should see vessels with the following headings:$/ do |table|
  dirmap = {'up' => 'n', 'down' => 's', 'right' => 'e'}
  
  table.rows_hash.each do |name,direction|
    next unless @vessels.has_key?(name)
    position = @vessels[name].position
    args = [position.lat, position.lon, dirmap[direction]]
    js = "map.hasMarkerAt(new LatLon(%f,%f), '%s')" % args
    has_vessel = page.evaluate_script(js)
    has_vessel.should eq true
  end
end
