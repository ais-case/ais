Feature: Vessel Details
  In order to get information about a vessel
  As a coast guard
  I want to be able to select a vessel and see its details
  
  Scenario:
    Given vessel "Sea Lion" with details:
       | MMSI     | 245000000     |
       | Class    | A             |
       | Type     | Cargo         |
       | Position | 51.99N, 4.05E |
       | Heading  | 290           |
       | Speed    | 13.1          |
     When "Sea Lion" sends a position report
      And "Sea Lion" sends a voyage report 
      And I select vessel "Sea Lion" on the map
     Then I should see all details of vessel "Sea Lion"