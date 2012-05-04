Feature: Vessel Movement
  In order to see up the latest location for a vessel
  As a coast guard
  I want the vessel location to be automatically updated on the map
    
  Scenario: move within map view
    Given vessel "Sea Lion" at position "51.99N, 4.03E"
     When I view the map area between "52.10N, 3.90E" and "51.90N, 4.10E"
      And vessel "Sea Lion" moves to position "52.02N, 3.97E"
     Then I should see vessel "Sea Lion" at position "52.02N, 3.97E"

  Scenario: move out of map view
    Given vessel "Sea Lion" at position "51.99N, 4.03E"
     When I view the map area between "52.10N, 3.90E" and "51.90N, 4.10E"
      And vessel "Sea Lion" moves to position "52.04N, 3.85E"
     Then I should not see vessel "Sea Lion"

  Scenario: move in to map view
    Given vessel "Sea Lion" at position "52.04N, 3.85E"
     When I view the map area between "52.10N, 3.90E" and "51.90N, 4.10E"
      And vessel "Sea Lion" moves to position "51.99N, 4.03E"
     Then I should see vessel "Sea Lion" at position "51.99N, 4.03E"