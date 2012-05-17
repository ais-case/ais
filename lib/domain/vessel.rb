class Vessel
  attr_reader :vessel_class
  attr_accessor :name, :position

  CLASS_A = 'A'
  CLASS_B = 'B'

  def initialize(vessel_class)
    @vessel_class = vessel_class
  end
  
  def ==(other)
    (@vessel_class == other.vessel_class) and (@position == other.position) 
  end
end
