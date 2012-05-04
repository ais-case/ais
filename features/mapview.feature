Feature: Map View
  In order to asses the situation in my area
  As a coast guard
  I want to see the location of each vessel marked on a map

  Scenario: show vessel inside map area
    Given I vessel "Seal" at position "52.01N, 3.99E"
     When I view the map area between "52.10N, 3.90E" and "51.90N, 4.10E"
     Then I should see vessel "Seal" at position "52.01N, 3.99E"

  Scenario: vessels outside the map area should not be visible
    Given I vessel "Seagull" at position "51.97N, 4.12E"
     When I view the map area between "52.10N, 3.90E" and "51.90N, 4.10E"
     Then I should not see vessel "Seagull"