# A launch selects its language; this feature never changes language in-process. Run it separately
# with -Language English and -Language French. The visible layout is judged on the @review captures.
@review @requires:nelim.pickletools.colonistrace @requires:nelim.pickletools.loadaudit @requires:nelim.pickletools.screenshotstudio
Feature: RimScent Extended UI is readable in each startup language

  Background:
    Given the save "test-colony" is loaded
    And I close all dialogs

  Scenario: the primary settings dialog contains resolved translated text
    When Nelim's Pickle Tools: I open the mod options page of the mod "nelim.rimscent.extended"
    Then Nelim's Pickle Tools: the translation report has no problem for the mod "nelim.rimscent.extended"
    And Nelim's Pickle Tools: the active language recorded no load error
    When I take a screenshot "RimScent Extended settings in the startup language"
    And Nelim's Pickle Tools: I close the mod options window

  Scenario: the MainButtons description resolves for the startup language
    When RimScent Extended activates the MainButtonDef "RimScentExtended_Settings"
    Then Nelim's Pickle Tools: the translation report has no problem for the mod "nelim.rimscent.extended"
    When I take a screenshot "RimScent Extended MainButtons shortcut in the startup language"
    And I close all dialogs
