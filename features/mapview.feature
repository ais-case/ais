Feature: Map View
  In order to asses the situation in my area
  As a coast guard
  I want to see the location of each vessel marked on a map

  @wip
  Scenario: show map
     When I view the homepage
     Then I should see a map of the area around "52.10N, 3.90E"
  
  Scenario: show vessel inside map area
    Given vessel "Seal" at position "52.01N, 3.99E"
     When I view a map of the area around "52.01N, 3.99E"
     Then I should see a vessel at position "52.01N, 3.99E"