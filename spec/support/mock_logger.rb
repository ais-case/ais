class MockLogger
  def log(message)
  end 

  alias fatal log
  alias error log
  alias warn log
  alias info log
  alias debug log  
end