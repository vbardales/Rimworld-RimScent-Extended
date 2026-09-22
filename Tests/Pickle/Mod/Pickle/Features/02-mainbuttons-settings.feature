@review
Feature: the hidden MainButtons shortcut opens RimScent Extended settings

  Background:
    Given the save "test-colony" is loaded
    And I close all dialogs

  Scenario: hidden by default, it opens this mod's settings dialog when activated
    Then def "RimScentExtended_Settings" of type "MainButtonDef" exists
    And RimScent Extended MainButtonDef "RimScentExtended_Settings" is hidden by default
    When RimScent Extended activates the MainButtonDef "RimScentExtended_Settings"
    Then RimScent Extended sees its settings dialog open
    When I take a screenshot "RimScent Extended settings via MainButtons"
    And I close all dialogs
    Then no errors were logged
