When /^vessel "(.*?)" moves to position "(.*?)"$/ do |name, coords_str|
  @vessels[name].position = Domain::LatLon::from_str(coords_str)
  
   # Send position report for vessel
  @registry.bind('ais/transmitter') do |service|
    service.send_position_report_for @vessels[name]
  end
  sleep(1.0)
end