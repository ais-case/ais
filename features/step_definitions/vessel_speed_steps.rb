Given /^vessels with speeds:$/ do |table|
  @vessels = {}
  delta = 0.01
  table.rows_hash.each do |name,speed|
    next if name == 'name'
    vessel = Domain::Vessel.new(1_000 + (100 * delta).to_i, Domain::Vessel::CLASS_A)
    vessel.name =  name
    vessel.speed = speed.to_f
    vessel.heading = (4500 * delta).to_i
    vessel.position = Domain::LatLon.new(51.81 + delta, 4.0 + 10 * delta)
    @vessels[name] = vessel
    
    @registry.bind('ais/transmitter') do |service|
      service.send_position_report_for(vessel)
    end
    delta += 0.01
  end
end

Then /^I should see speed lines:$/ do |table|
  ref_length = nil
  table.rows_hash.each do |name,rel_length_str|
    next unless @vessels.has_key?(name)
    rel_length = rel_length_str.to_f
    position = @vessels[name].position
    args = [position.lat, position.lon]
    js = "map.getLineLength(new LatLon(%f,%f))" % args
    length = page.evaluate_script(js).to_f
    if ref_length
      length.should be_within(0.001).of(ref_length * rel_length)
    else
      ref_length = length / rel_length
    end
  end
end

Then /^I should see no speed lines$/ do
  @vessels.each do |name,vessel|
    args = [vessel.position.lat, vessel.position.lon]
    js = "map.getLineLength(new LatLon(%f,%f))" % args
    length = page.evaluate_script(js).to_f
    length.should be_within(0.0001).of(0.0)
  end  
end
