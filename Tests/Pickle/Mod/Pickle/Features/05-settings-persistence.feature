@review @requires:nelim.pickletools.colonistrace
Feature: RimScent Extended settings persist safely

  Background:
    Given the save "test-colony" is loaded
    And Nelim's Pickle Tools: the settings of the mod "nelim.rimscent.extended" are sandboxed at their defaults

  Scenario: values changed through the primary route persist to the settings file
    When Nelim's Pickle Tools: I open the mod options page of the mod "nelim.rimscent.extended"
    And Nelim's Pickle Tools: I set the option "temperatureEnabled" of the mod "nelim.rimscent.extended" to "false"
    And Nelim's Pickle Tools: I set the option "adaptationFloor" of the mod "nelim.rimscent.extended" to "0.25"
    And Nelim's Pickle Tools: I set the option "adaptationHours" of the mod "nelim.rimscent.extended" to "6"
    And Nelim's Pickle Tools: I set the option "adaptToPleasant" of the mod "nelim.rimscent.extended" to "false"
    Then Nelim's Pickle Tools: the settings file of the mod "nelim.rimscent.extended" holds "temperatureEnabled" as "False"
    And Nelim's Pickle Tools: the settings file of the mod "nelim.rimscent.extended" holds "adaptationFloor" as "0.25"
    And Nelim's Pickle Tools: the settings file of the mod "nelim.rimscent.extended" holds "adaptationHours" as "6"
    And Nelim's Pickle Tools: the settings file of the mod "nelim.rimscent.extended" holds "adaptToPleasant" as "False"
    When Nelim's Pickle Tools: the settings of the mod "nelim.rimscent.extended" are re-read from the file
    Then Nelim's Pickle Tools: the option "temperatureEnabled" of the mod "nelim.rimscent.extended" is "False"
    And Nelim's Pickle Tools: the option "adaptationFloor" of the mod "nelim.rimscent.extended" is "0.25"
    And Nelim's Pickle Tools: the option "adaptationHours" of the mod "nelim.rimscent.extended" is "6"
    And Nelim's Pickle Tools: the option "adaptToPleasant" of the mod "nelim.rimscent.extended" is "False"
    When I take a screenshot "RimScent Extended configured settings"
    And Nelim's Pickle Tools: I close the mod options window

  Scenario: the MainButtons route shares the same settings object
    When RimScent Extended activates the MainButtonDef "RimScentExtended_Settings"
    And Nelim's Pickle Tools: I set the option "temperatureEnabled" of the mod "nelim.rimscent.extended" to "false"
    And I close all dialogs
    And Nelim's Pickle Tools: I open the mod options page of the mod "nelim.rimscent.extended"
    Then Nelim's Pickle Tools: the option "temperatureEnabled" of the mod "nelim.rimscent.extended" is "False"
    When Nelim's Pickle Tools: I close the mod options window
    Then no errors were logged
