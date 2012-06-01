class Marker
  attr_reader :id, :position, :icon
  
  def initialize(id, position, icon)
    @id = id
    @position = position
    @icon = icon
  end
  
  def self.icon_from_vessel(vessel)
    dir = case vessel.heading
    when (0..45)
      'n'
    when (46..134)
      'e'
    when (135..225)
      's'
    when (226..314)
      'w'
    when (315..360)
    else 
      nil
    end
    
    if dir
      "/markers/v_#{dir}.png"
    else
      "/markers/v.png"
    end
  end
  
  def self.from_vessel(vessel)
    Marker.new(vessel.mmsi, vessel.position, self.icon_from_vessel(vessel))
  end
  
  def ==(other)
    (@id == other.id) and 
    (@position == other.position) and
    (@icon == other.icon)
  end
end