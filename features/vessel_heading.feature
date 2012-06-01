Feature: Vessel Heading
  In order to see the direction each vessel is moving in
  As a coast guard
  I want to to see the heading of each vessel marked on the map

  @wip
  Scenario: orientation of vessel icon changes with heading
    Given vessels:
      | name      | heading |
      | Sea Lion  |   0.0   |
      | Seagull   | 180.0   |
      | Seal      |  90.0   |
     When I view the map
     Then I should see vessels with the following headings:
      | name      | pointing |
      | Sea Lion  | up       |
      | Seagull   | down     |
      | Seal      | right    |