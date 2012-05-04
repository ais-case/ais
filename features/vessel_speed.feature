Feature: Vessel Speed
  In order to gauge the speed of vessels
  As a coast guard 
  I want to see a line behind each marked vessel indicating speed
  
  Scenario: regular movement 
    Given vessels:
        | name       | speed |
        | Sea Lion   | 10.0  |
        | Seagull    | 20.0  |
        | Seal       | 30.0  |
     When I view the map
     Then I should see speed lines:
        | name       | relative length |
        | Sea Lion   |  1.0            |
        | Seagull    |  2.0            |
        | Seal       |  3.0            |

  Scenario: slow vessels have a minimum line length
    Given vessels:
        | name       | speed |
        | Sea Lion   |  1.0  |
        | Seagull    |  5.0  |
        | Seal       | 10.0  |
     When I view the map
     Then I should see speed lines:
        | name       | relative length |
        | Sea Lion   |  1.0            |
        | Seagull    |  1.0            |
        | Seal       |  1.0            |

  Scenario: fast vessels have a maximum line length
    Given vessels:
        | name       | speed |
        | Sea Lion   | 30.0  |
        | Seagull    | 50.0  |
     When I view the map
     Then I should see speed lines:
        | name       | relative length |
        | Sea Lion   |  1.0            |
        | Seagull    |  1.0            |
          
  Scenario: stationary vessels have no lines
    Given vessels:
        | name       | speed |
        | Sea Lion   |  0.0  |
        | Seagull    |  0.99 |
     When I view the map
     Then I should see no speed lines