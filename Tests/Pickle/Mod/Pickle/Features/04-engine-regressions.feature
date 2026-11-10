# The scanner defects fixed in Source/Runtime/ScentScan.cs, played on rooms built by the generic StageDecor steps (no fixture save).
# Rooms are 5 by 5 inside, south-west inside cell given: the walls must avoid the natural rock around (153, 148), which blocked a 12 by 9 room (ticket 37b3).
# Scenario "an indoor pawn only scans their own room" stays @wip: it needs an opening between two rooms (asked of NPT).
#
#   Submit-PickleRun.ps1 -Mod RimScentExtended -DepMap wsl-deps.scanner.map -Filter 04-engine-regressions
@requires:nelim.pickletools.colonistrace @requires:nelim.pickletools.stagedecor
Feature: RimScent Extended scanner regressions

  Background:
    Given the save "test-colony" is loaded
    And Nelim's Pickle Tools: the settings of the mod "nelim.rimscent.extended" are sandboxed at their defaults

  Scenario: a switched-off fuelled generator contributes no scent
    Given Nelim's Pickle Tools: a closed roofed room is built at (144, 149) of 5 by 5
    And Nelim's Pickle Tools: I place the decor "WoodFiredGenerator" at (147, 152)
    And Nelim's Pickle Tools: the building "WoodFiredGenerator" at (147, 152) is fuelled
    And Nelim's Pickle Tools: the building "WoodFiredGenerator" at (147, 152) is switched off
    And a colonist "Ada" exists
    And Nelim's Pickle Tools: "Ada" stands at (144, 150)
    And Nelim's Pickle Tools: "Ada" waits in place
    When I wait 600 ticks
    Then Nelim's Pickle Tools: "Ada" has no thought "RimScent_GeneratorScent"
    When Nelim's Pickle Tools: the building "WoodFiredGenerator" at (147, 152) is switched on
    And I wait 600 ticks
    Then Nelim's Pickle Tools: "Ada" has the thought "RimScent_GeneratorScent"

  @wip
  Scenario: an indoor pawn only scans their own room
    # Needs two rooms joined by an opening (a door or a gap in the shared wall) so that line of sight crosses it: no generic step builds one yet.
    Given a colonist "Ada" exists
    Then Nelim's Pickle Tools: "Ada" has no thought "RimScent_CampfireScent"

  Scenario: trait-degree anosmia and dysosmia affect only matching pawns
    Given Nelim's Pickle Tools: a closed roofed room is built at (144, 149) of 5 by 5
    And Nelim's Pickle Tools: I place the decor "Campfire" at (147, 152)
    And Nelim's Pickle Tools: the building "Campfire" at (147, 152) is fuelled
    And a colonist "Ada" exists
    And a colonist "Bea" exists
    And a colonist "Cai" exists
    And Nelim's Pickle Tools: "Ada" has the trait "RimScent_Anosmic"
    And Nelim's Pickle Tools: "Bea" has the trait "RimScent_Dysosmic"
    And Nelim's Pickle Tools: "Cai" has no trait "RimScent_Anosmic"
    And Nelim's Pickle Tools: "Cai" has no trait "RimScent_Dysosmic"
    And Nelim's Pickle Tools: "Ada" stands at (144, 150)
    And Nelim's Pickle Tools: "Bea" stands at (144, 151)
    And Nelim's Pickle Tools: "Cai" stands at (144, 152)
    And Nelim's Pickle Tools: "Ada" waits in place
    And Nelim's Pickle Tools: "Bea" waits in place
    And Nelim's Pickle Tools: "Cai" waits in place
    When I wait 600 ticks
    Then Nelim's Pickle Tools: "Ada" has no thought "RimScent_CampfireScent"
    And "Bea" thought "RimScent_CampfireScent" mood offset is below 0
    And "Cai" thought "RimScent_CampfireScent" mood offset is above 2

  Scenario: temperature changes the strength of a scent
    # Two rooms, one campfire and one pawn each. A scent memory is made once per exposure, so each temperature needs its own pawn.
    Given Nelim's Pickle Tools: a closed roofed room is built at (144, 149) of 5 by 5
    And Nelim's Pickle Tools: a closed roofed room is built at (144, 157) of 5 by 5
    And Nelim's Pickle Tools: I place the decor "Campfire" at (147, 152)
    And Nelim's Pickle Tools: I place the decor "Campfire" at (147, 160)
    And Nelim's Pickle Tools: the building "Campfire" at (147, 152) is fuelled
    And Nelim's Pickle Tools: the building "Campfire" at (147, 160) is fuelled
    And Nelim's Pickle Tools: the room at (144, 150) is held at -10 degrees
    And Nelim's Pickle Tools: the room at (144, 158) is held at 45 degrees
    And a colonist "Ada" exists
    And a colonist "Bea" exists
    And Nelim's Pickle Tools: "Ada" stands at (144, 150)
    And Nelim's Pickle Tools: "Bea" stands at (144, 158)
    And Nelim's Pickle Tools: "Ada" waits in place
    And Nelim's Pickle Tools: "Bea" waits in place
    When I wait 600 ticks
    Then Nelim's Pickle Tools: the thermal state and thoughts of "Ada" are logged
    And Nelim's Pickle Tools: the thermal state and thoughts of "Bea" are logged
    And "Ada" thought "RimScent_CampfireScent" mood offset is below 3
    And "Bea" thought "RimScent_CampfireScent" mood offset is above 3

  Scenario: with temperature off the scent keeps its base strength
    Given Nelim's Pickle Tools: I set the option "temperatureEnabled" of the mod "nelim.rimscent.extended" to "False"
    And Nelim's Pickle Tools: a closed roofed room is built at (144, 149) of 5 by 5
    And Nelim's Pickle Tools: I place the decor "Campfire" at (147, 152)
    And Nelim's Pickle Tools: the building "Campfire" at (147, 152) is fuelled
    And Nelim's Pickle Tools: the room at (144, 150) is held at 45 degrees
    And a colonist "Ada" exists
    And Nelim's Pickle Tools: "Ada" stands at (144, 150)
    And Nelim's Pickle Tools: "Ada" waits in place
    When I wait 600 ticks
    Then "Ada" thought "RimScent_CampfireScent" mood offset is above 2.5
    And "Ada" thought "RimScent_CampfireScent" mood offset is below 3.5
