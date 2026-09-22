@review @rimmsqol @requires:MalteSchulze.RIMMSqol @requires:nelim.pickletools.rimmsqol @requires:nelim.pickletools.interfacescale
Feature: RIMMSQOL reveals and hides the RimScent Extended shortcut

  Background:
    Given the save "test-colony" is loaded
    And I close all dialogs
    Then mod "MalteSchulze.RIMMSqol" is loaded
    And RIMMSQOL is ready to be driven

  Scenario: RIMMSQOL lists the shortcut as hidden on a clean configuration
    Then RIMMSQOL's own list of main buttons offers "RimScentExtended_Settings"
    And RIMMSQOL shows the main button "RimScentExtended_Settings" as hidden
    And RIMMSQOL holds no choice for the main button "RimScentExtended_Settings"
    And the main bar does not draw the button "RimScentExtended_Settings"
    When RIMMSQOL's own window is opened on its list of main buttons
    Then RIMMSQOL's own window is open
    When I take a screenshot "RIMMSQOL list with RimScent Extended hidden"
    And I close all dialogs

  Scenario: a revealed shortcut opens RimScent Extended settings
    When RIMMSQOL reveals the main button "RimScentExtended_Settings"
    Then RIMMSQOL shows the main button "RimScentExtended_Settings" as visible
    And the main bar draws the button "RimScentExtended_Settings"
    When the main bar's button "RimScentExtended_Settings" is activated
    Then RimScent Extended sees its settings dialog open
    When I take a screenshot "RimScent Extended settings revealed by RIMMSQOL"
    And I close all dialogs

  Scenario: hiding the shortcut again removes it from the bar
    Given RIMMSQOL reveals the main button "RimScentExtended_Settings"
    When RIMMSQOL hides the main button "RimScentExtended_Settings"
    Then RIMMSQOL shows the main button "RimScentExtended_Settings" as hidden
    And the main bar does not draw the button "RimScentExtended_Settings"
