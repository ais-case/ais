Feature: Vessel Compliance
  In order to see how reliable vessel information is 
  As a coast guard
  I want to see which class A vessels do not comply with the AIS protocol

  Scenario: dynamic information of anchored vessels
    Given anchored class "A" vessels with dynamic information:
        | name       | speed |
        | Sea Lion   |  3.0  |
        | Seal       |  3.0  |
        | Seagull    |  3.1  |
        | Seahorse   |  3.1  |
     When these vessels send a position report
      And send another position report after:
        | name       | interval |
        | Sea Lion   | 180.0    |
        | Seal       | 180.1    |
        | Seagull    |  10.0    |
        | Seahorse   |  10.1    |
     Then the compliance of the vessels should be marked as:
        | name       | compliant |
        | Sea Lion   | yes       |
        | Seal       | no        |
        | Seagull    | yes       |
        | Seahorse   | no        |
   
  Scenario: dynamic information of moving, non-anchored vessels not changing course
    Given non-anchored class "A" vessels with dynamic information:
        | name       | speed |
        | Sea Lion   |  1.0  |
        | Seal       |  1.0  |
        | Seagull    | 14.1  |
        | Seahorse   | 14.1  |
        | Sea Otter  | 23.1  |
        | Seahawk    | 23.1  |
     When these vessels send a position report
      And send another position report after:
        | name       | interval |
        | Sea Lion   | 10.0     |
        | Seal       | 10.1     |
        | Seagull    |  6.0     |
        | Seahorse   |  6.1     |
        | Sea Otter  |  2.0     |
        | Seahawk    |  2.1     |
     Then the compliance of the vessels should be marked as:
        | name       | compliant |
        | Sea Lion   | yes       |
        | Seal       | no        |
        | Seagull    | yes       |
        | Seahorse   | no        |
        | Sea Otter  | yes       |
        | Seahawk    | no        |

  Scenario: dynamic information of moving, non-anchored vessels with a changing course
    Given class "A" vessels with a changing course and dynamic information:
        | name       | speed |
        | Sea Lion   |  1.0  |
        | Seal       |  1.0  |
        | Seagull    | 14.1  |
        | Seahorse   | 14.1  |
        | Sea Otter  | 23.1  |
        | Seahawk    | 23.1  |
     When these vessels send a position report
      And send another position report after:
        | name       | interval |
        | Sea Lion   | 3.5      |
        | Seal       | 3.6      |
        | Seagull    | 2.0      |
        | Seahorse   | 2.1      |
        | Sea Otter  | 2.0      |
        | Seahawk    | 2.1      |
     Then the compliance of the vessels should be marked as:
        | name       | compliant |
        | Sea Lion   | yes       |
        | Seal       | no        |
        | Seagull    | yes       |
        | Seahorse   | no        |
        | Sea Otter  | yes       |
        | Seahawk    | no        |

  Scenario: static reports should be received within 6 minutes of each other
    Given class "A" vessels:
        | name       |
        | Sea Lion   |
        | Seal       |
     When these vessels send a static report
      And send another static report after:
        | name       | interval |
        | Sea Lion   | 360.0   |
        | Seal       | 360.1   |
     Then the compliance of the vessels should be marked as:
        | name       | compliant |
        | Sea Lion   | yes       |
        | Seal       | no        |
        
  Scenario: static reports should be received within 6 minutes of a position report
    Given class "A" vessels:
        | name       |
        | Sea Lion   |
        | Seal       |
     When these vessels send a position report
      And send another static report after:
        | name       | interval |
        | Sea Lion   | 360.0   |
        | Seal       | 360.1   |
     Then the compliance of the vessels should be marked as:
        | name       | compliant |
        | Sea Lion   | yes       |
        | Seal       | no        |