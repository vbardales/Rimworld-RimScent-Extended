# A launch selects its language; this feature never changes language in-process. It is @wip until
# the companion exposes a safe settings-dialog observer. Run it separately with -Language English
# and -Language French once the observer exists.
@wip @review
Feature: RimScent Extended UI is readable in each startup language

  Background:
    Given the save "test-colony" is loaded
    And I close all dialogs

  Scenario: the primary settings dialog contains resolved translated text
    When RimScent Extended opens the primary settings dialog
    Then RimScent Extended settings text is resolved for the active language
    And RimScent Extended settings controls fit their visible layout
    When I take a screenshot "RimScent Extended settings in the startup language"
    And I close all dialogs

  Scenario: the MainButtons description resolves for the startup language
    When RimScent Extended activates the MainButtonDef "RimScentExtended_Settings"
    Then RimScent Extended MainButtonDef "RimScentExtended_Settings" has translated label and description
    When I take a screenshot "RimScent Extended MainButtons shortcut in the startup language"
    And I close all dialogs
