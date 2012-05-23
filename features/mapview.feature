Feature: Map View
  In order to asses the situation in my area
  As a coast guard
  I want to see the location of each vessel marked on a map

  Scenario: show map
     When I view the homepage
     Then I should see a map of the area around "51.9N, 4.35E"

  Scenario: show vessel inside map area
    Given vessel "Seal" at position "52.01N, 3.99E"
     When I see the map area between "52.01N, 3.99E" and "52.01N, 3.99E"
     Then I should see a vessel at position "52.01N, 3.99E"