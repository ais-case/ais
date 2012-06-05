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

  def ==(other)
    (@id == other.id) and 
    (@position == other.position) and
    (@icon == other.icon)
  end
end