Feature: Vessel Type
  In order to distinguish vessels of different types
  As a coast guard
  I want to see vessels of a specific type marked with a specific color
  
  Scenario: each type of ship has a specific color
    Given vessels:
      | name        | type      |
      | Sea Lion    | Passenger |
      | Sea Otter   | Fishing   |
      | Seagull     | Cargo     |
      | Seahorse    | Tanker    |
      | Seahawk     | Military  |
      | Seal        | Other     |
    When I view the map
    Then I should see vessels:
      | name        | color     |
      | Sea Lion    | green     |
      | Sea Otter   | grey      |
      | Seagull     | blue      |
      | Seahorse    | black     |
      | Seahawk     | white     |
      | Seal        | yellow    |
        