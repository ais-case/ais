Feature: Vessel Class
  In order to discriminate professional shipping and leisure shipping
  As a coast guard
  I want to see vessels of a specific class marked with a specific shape

  Scenario: professional vessel
    Given vessel "Sea Lion" of class "A"
     When I view the map
     Then vessel "Sea Lion" should have shape "Professional" 

  @wip
  Scenario: leisure vessel
    Given vessel "Seal" of class "B"
     When I view the map
     Then vessel "Seal" should have shape "Leisure" 