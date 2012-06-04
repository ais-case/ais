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
  
  def self.icon_from_vessel(vessel)
    dir = case vessel.heading
    when (0..23)
      'n'
    when (24..68)
      'ne'
    when (67..113)
      'e'
    when (114..156)
      'se'
    when (157..203)
      's'
    when (204..246)
      'sw'
    when (247..293)
      'w'
    when (294..336)
      'nw'
    when (337..360)
      'n'
    else 
      nil
    end
    
    cls = (vessel.vessel_class == Domain::Vessel::CLASS_A) ? 'a' : 'b'
    
    if dir
      "v_#{cls}_#{dir}.png"
    else
      "v_#{cls}.png"
    end
  end
  
  def self.from_vessel(vessel)
    marker = Marker.new(vessel.mmsi, vessel.position, self.icon_from_vessel(vessel))
    if vessel.heading and vessel.speed
      marker.add_line(vessel.heading, vessel.speed / 100)
    end
    marker
  end
  
  def ==(other)
    (@id == other.id) and 
    (@position == other.position) and
    (@icon == other.icon)
  end
end