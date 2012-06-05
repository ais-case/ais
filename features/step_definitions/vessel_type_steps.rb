Given /^vessels with colors:$/ do |table|
  @vessels = {}
  delta = 0.01
  table.rows_hash.each do |name,type|
    next if name == 'name'
    vessel = Domain::Vessel.new(1_000 + (100 * delta).to_i, Domain::Vessel::CLASS_A)
    vessel.name =  name
    vessel.heading = (10 * delta).to_i
    vessel.position = Domain::LatLon.new(51.81 + delta, 4.0 + 10 * delta)
    vessel.type = Domain::VesselType.from_str(type) 
    @vessels[name] = vessel
    
    @registry.bind('ais/transmitter') do |service|
      service.send_position_report_for(vessel)
      service.send_static_report_for(vessel)
    end
    delta += 0.01
  end
end

Then /^I should see vessels with the following colors:$/ do |table|
  table.rows_hash.each do |name,color|
    next unless @vessels.has_key?(name)
    position = @vessels[name].position
    args = [position.lat, position.lon, color]
    js = "map.hasMarkerAt(new LatLon(%f,%f), '%s')" % args
    page.evaluate_script(js).should be_true
  end
end
