class MockRegistry
  def initialize
    @lookup = {}
  end
  
  def register(name, endpoint)
    @lookup[name] = endpoint
  end
  
  def lookup(name)
    @lookup[name] if @lookup.has_key?(name)
  end
end