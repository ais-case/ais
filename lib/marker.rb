require_relative 'domain/vessel'

class Marker
  attr_reader :id, :position, :icon, :line
  
  class MarkerLine
    attr_reader :direction, :length
    
    def initialize(direction, length)
      @direction = direction
      @length = length
    end
  end
    
  def initialize(id, position, icon)
    @id = id
    @position = position
    @icon = icon
    @line = nil
  end

  def add_line(direction, length)
    @line = MarkerLine.new(direction, length) 
  end  
  
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
    directions = {0 => 'n', 45 => 'ne', 90 => 'e', 135 => 'se', 
                  180 => 's', 225 => 'sw', 270 => 'w', 315 => 'nw'}
    heading = round_heading(vessel.heading)
    direction = directions[heading] if heading      
    cls = (vessel.vessel_class == Domain::Vessel::CLASS_A) ? 'a' : 'b'
    
    if direction
      "v_#{cls}_#{direction}.png"
    else
      "v_#{cls}.png"
    end
  end
  
  def self.from_vessel(vessel)
    marker = Marker.new(vessel.mmsi, vessel.position, self.icon_from_vessel(vessel))
    if vessel.heading and vessel.speed and vessel.speed >= 1.0
      if vessel.speed < 10.0
        length = 10.0 / 600
      elsif vessel.speed > 30.0
        length = 30.0 / 600
      else
        length = vessel.speed / 600
      end
      
      dir = self.round_heading(vessel.heading)
      
      marker.add_line((dir + 180) % 360, length)
    end
    marker
  end
  
  def ==(other)
    (@id == other.id) and 
    (@position == other.position) and
    (@icon == other.icon)
  end
end