# This is an @wip specification until the companion gains a settings sandbox. It must back up
# and restore the real configuration file in Before/AfterScenario, including interrupted-run
# recovery, before any step calls WriteSettings.
@wip @review
Feature: RimScent Extended settings persist safely

  Background:
    Given the save "test-colony" is loaded
    And RimScent Extended settings are sandboxed at documented defaults

  Scenario: values changed through the primary route persist to the settings file
    When RimScent Extended opens the primary settings dialog
    And RimScent Extended turns temperature off
    And RimScent Extended sets adaptation floor to 25 percent
    And RimScent Extended sets adaptation duration to 6 hours
    And RimScent Extended turns pleasant adaptation off
    And RimScent Extended writes settings to the sandbox
    Then RimScent Extended settings file records the selected values
    When RimScent Extended settings are re-read from the sandbox
    Then RimScent Extended settings equal the selected values
    When I take a screenshot "RimScent Extended configured settings"

  Scenario: the MainButtons route shares the same settings object
    Given RimScent Extended settings are sandboxed at documented defaults
    When RimScent Extended activates the MainButtonDef "RimScentExtended_Settings"
    And RimScent Extended turns temperature off
    And I close all dialogs
    When RimScent Extended opens the primary settings dialog
    Then RimScent Extended temperature is off
