# The scanner defects fixed in Source/Runtime/ScentScan.cs, played on rooms built by the generic StageDecor steps (no fixture save).
# Rooms are built large (the size counts the walls or not, depending on the step): pawns and sources stay well inside.
# Scenario "an indoor pawn only scans their own room" stays @wip: it needs an opening between two rooms (asked of NPT).
#
#   Submit-PickleRun.ps1 -Mod RimScentExtended -DepMap wsl-deps.scanner.map -Filter 04-engine-regressions
@requires:nelim.pickletools.colonistrace @requires:nelim.pickletools.stagedecor
Feature: RimScent Extended scanner regressions

  Background:
    Given the save "test-colony" is loaded
    And Nelim's Pickle Tools: the settings of the mod "nelim.rimscent.extended" are sandboxed at their defaults

  Scenario: a switched-off fuelled generator contributes no scent
    Given Nelim's Pickle Tools: a closed roofed room is built at (144, 149) of 12 by 9
    And Nelim's Pickle Tools: I place the decor "WoodFiredGenerator" at (150, 153)
    And Nelim's Pickle Tools: the building "WoodFiredGenerator" at (150, 153) is fuelled
    And Nelim's Pickle Tools: the building "WoodFiredGenerator" at (150, 153) is switched off
    And a colonist "Ada" exists
    And Nelim's Pickle Tools: "Ada" stands at (146, 151)
    And Nelim's Pickle Tools: "Ada" waits in place
    When I wait 600 ticks
    Then Nelim's Pickle Tools: "Ada" has no thought "RimScent_GeneratorScent"
    When Nelim's Pickle Tools: the building "WoodFiredGenerator" at (150, 153) is switched on
    And I wait 600 ticks
    Then Nelim's Pickle Tools: "Ada" has the thought "RimScent_GeneratorScent"

  @wip
  Scenario: an indoor pawn only scans their own room
    # Needs two rooms joined by an opening (a door or a gap in the shared wall) so that line of sight crosses it: no generic step builds one yet.
    Given a colonist "Ada" exists
    Then Nelim's Pickle Tools: "Ada" has no thought "RimScent_CampfireScent"

  Scenario: trait-degree anosmia and dysosmia affect only matching pawns
    Given Nelim's Pickle Tools: a closed roofed room is built at (144, 149) of 12 by 9
    And Nelim's Pickle Tools: I place the decor "Campfire" at (150, 153)
    And Nelim's Pickle Tools: the building "Campfire" at (150, 153) is fuelled
    And a colonist "Ada" exists
    And a colonist "Bea" exists
    And a colonist "Cai" exists
    And Nelim's Pickle Tools: "Ada" has the trait "RimScent_Anosmic"
    And Nelim's Pickle Tools: "Bea" has the trait "RimScent_Dysosmic"
    And Nelim's Pickle Tools: "Cai" has no trait "RimScent_Anosmic"
    And Nelim's Pickle Tools: "Cai" has no trait "RimScent_Dysosmic"
    And Nelim's Pickle Tools: "Ada" stands at (146, 151)
    And Nelim's Pickle Tools: "Bea" stands at (146, 152)
    And Nelim's Pickle Tools: "Cai" stands at (146, 153)
    And Nelim's Pickle Tools: "Ada" waits in place
    And Nelim's Pickle Tools: "Bea" waits in place
    And Nelim's Pickle Tools: "Cai" waits in place
    When I wait 600 ticks
    Then Nelim's Pickle Tools: "Ada" has no thought "RimScent_CampfireScent"
    And "Bea" thought "RimScent_CampfireScent" mood offset is below 0
    And "Cai" thought "RimScent_CampfireScent" mood offset is above 2

  Scenario: temperature changes the strength of a scent
    # Three rooms, one campfire and one pawn each. A scent memory is made once per exposure, so each temperature needs its own pawn.
    Given Nelim's Pickle Tools: a closed roofed room is built at (144, 149) of 12 by 9
    And Nelim's Pickle Tools: a closed roofed room is built at (160, 149) of 12 by 9
    And Nelim's Pickle Tools: I place the decor "Campfire" at (150, 153)
    And Nelim's Pickle Tools: I place the decor "Campfire" at (166, 153)
    And Nelim's Pickle Tools: the building "Campfire" at (150, 153) is fuelled
    And Nelim's Pickle Tools: the building "Campfire" at (166, 153) is fuelled
    And Nelim's Pickle Tools: the room at (146, 151) is held at -10 degrees
    And Nelim's Pickle Tools: the room at (162, 151) is held at 45 degrees
    And a colonist "Ada" exists
    And a colonist "Bea" exists
    And Nelim's Pickle Tools: "Ada" stands at (146, 151)
    And Nelim's Pickle Tools: "Bea" stands at (162, 151)
    And Nelim's Pickle Tools: "Ada" waits in place
    And Nelim's Pickle Tools: "Bea" waits in place
    When I wait 600 ticks
    Then Nelim's Pickle Tools: the thermal state and thoughts of "Ada" are logged
    And Nelim's Pickle Tools: the thermal state and thoughts of "Bea" are logged
    And "Ada" thought "RimScent_CampfireScent" mood offset is below 3
    And "Bea" thought "RimScent_CampfireScent" mood offset is above 3

  Scenario: with temperature off the scent keeps its base strength
    Given Nelim's Pickle Tools: I set the option "temperatureEnabled" of the mod "nelim.rimscent.extended" to "False"
    And Nelim's Pickle Tools: a closed roofed room is built at (144, 149) of 12 by 9
    And Nelim's Pickle Tools: I place the decor "Campfire" at (150, 153)
    And Nelim's Pickle Tools: the building "Campfire" at (150, 153) is fuelled
    And Nelim's Pickle Tools: the room at (146, 151) is held at 45 degrees
    And a colonist "Ada" exists
    And Nelim's Pickle Tools: "Ada" stands at (146, 151)
    And Nelim's Pickle Tools: "Ada" waits in place
    When I wait 600 ticks
    Then "Ada" thought "RimScent_CampfireScent" mood offset is above 2.5
    And "Ada" thought "RimScent_CampfireScent" mood offset is below 3.5
