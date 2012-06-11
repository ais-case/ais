require_relative 'marker'

class MarkerFactory
  def self.round_heading(heading)
    case heading
    when (0..23)
      0
    when (24..68)
      45
    when (67..113)
      90
    when (114..156)
      135
    when (157..203)
      180
    when (204..246)
      225
    when (247..293)
      270
    when (294..336)
      315
    when (337..360)
      0
    else 
      nil
    end    
  end
  
  def self.icon_from_vessel(vessel)
    cls = (vessel.vessel_class == Domain::Vessel::CLASS_A) ? 'a' : 'b'
    icon = "v_#{cls}"
    
    if not vessel.compliant
      return icon << "_non-compliant.png"
    end 
      
    directions = {0 => 'n', 45 => 'ne', 90 => 'e', 135 => 'se', 
                  180 => 's', 225 => 'sw', 270 => 'w', 315 => 'nw'}
    heading = round_heading(vessel.heading)
    direction = directions[heading] if heading      
    
    if direction
      icon << '_' << direction
    end
    
    colors = {'Passenger' => 'green', 'Fishing' => 'grey', 'Cargo' => 'blue',
              'Tanker' => 'black', 'Military' => 'white', 'Other' => 'yellow'}
    
    if vessel.type and colors.has_key?(vessel.type.description)
      icon << '_' << colors[vessel.type.description]
    end
    
    icon << '.png'
    
  end
  
  def self.from_vessel(vessel)
    marker = Marker.new(vessel.mmsi, vessel.position, self.icon_from_vessel(vessel))
    if vessel.heading and vessel.speed and vessel.speed >= 1.0
      if vessel.speed < 10.0
        length = 10.0
      elsif vessel.speed > 30.0
        length = 30.0
      else
        length = vessel.speed
      end
      
      dir = self.round_heading(vessel.heading)
      marker.add_line((dir + 180) % 360, length) if dir
    end
    marker
  end
  
end