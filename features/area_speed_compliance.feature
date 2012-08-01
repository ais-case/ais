Feature: Area Speed Compliance
  In order to see vessels that do not comply with area rules 
  As a coast guard
  I want to see which vessels move too fast in an area with speed limits

  Scenario: vessel inside area, moving with max speed
    Given class "A" vessel "Seal" at position "52.01N, 3.98E"
      And vessel "Seal" has speed "15.0"
      And an area with a maximum speed of "15.0" and coords:
        | 52.00N, 3,97E |
        | 52.02N, 3,98E |
        | 52.00N, 3,99E |
     When I see the map area between "52.10N, 3.90E" and "51.90N, 4.10E"
     Then vessel "Seal" should be shown as compliant
  
  Scenario: vessel inside area, moving slow
    Given class "A" vessel "Seal" at position "52.01N, 3.98E"
      And vessel "Seal" has speed "5.0"
      And an area with a maximum speed of "15.0" and coords:
        | 52.00N, 3,97E |
        | 52.02N, 3,98E |
        | 52.00N, 3,99E |
     When I see the map area between "52.10N, 3.90E" and "51.90N, 4.10E"
     Then vessel "Seal" should be shown as compliant
  
  Scenario: vessel inside area, moving too fast
    Given class "A" vessel "Seal" at position "52.01N, 3.98E"
      And vessel "Seal" has speed "25.0"
      And an area with a maximum speed of "15.0" and coords:
        | 52.00N, 3,97E |
        | 52.02N, 3,98E |
        | 52.00N, 3,99E |
     When I see the map area between "52.10N, 3.90E" and "51.90N, 4.10E"
     Then vessel "Seal" should be shown as non-compliant

  Scenario: vessel outside area, moving fast
    Given class "A" vessel "Seal" at position "52.00N, 3.98E"
      And vessel "Seal" has speed "25.0"
      And an area with a maximum speed of "15.0" and coords:
        | 52.00N, 3,97E |
        | 52.02N, 3,98E |
        | 52.00N, 3,99E |
     When I see the map area between "52.10N, 3.90E" and "51.90N, 4.10E"
     Then vessel "Seal" should be shown as compliant
