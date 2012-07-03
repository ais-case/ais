Feature: Too Many Sockets
  In order to be able to run the system for a long period of time
  As a coast guard
  I want the system to reuse sockets

  @wip
  Scenario: show map a number of times
     When I view the homepage
      And wait 3 seconds
     Then there should be only one connection to the vessel service