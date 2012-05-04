Feature: Vessel Details
  In order to get information about a vessel
  As a coast guard
  I want to be able to select a vessel and see its details
  
  Scenario:
    Given vessel "Sea Lion" with details:
       | detail   | value         |
       | Name     | Sea Lion      |
       | MMSI     | 245000000     |
       | Type     | Cargo ship    |
       | Position | 51.99N, 4.05E |
       | Heading  | 290.1         |
       | Speed    | 13.1          |
     When I select vessel "Sea Lion" on the map
     Then I should see the details of vessel "Sea Lion"