Feature: RimScent Extended loads with its hard dependency

  Scenario: the minimal mod set starts without an error
    Given the save "test-colony" is loaded
    Then no errors were logged
