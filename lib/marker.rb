class Marker
  attr_reader :id, :position
  
  def initialize(id, position)
    @id = id
    @position = position
  end
  
  def self.from_vessel(vessel)
    Marker.new(vessel.mmsi, vessel.position)
  end
  
  def ==(other)
    (@id == other.id) and 
    (@position == other.position)
  end
end