# Corpse and spoiled food thoughts are owned by the Decay expansion, which the scanner reads by defName: this pass stages it (wsl-deps.scanner-decay.map).
# The three other extension points (pawn scent with a stat threshold, a scent hediff, terrain scent) and the spoiled food scenario use
# a test-only def set in the Pickle companion mod (Tests/Pickle/Mod/Defs and Patches), written by this session (not a Pickle step).
#
#   Submit-PickleRun.ps1 -Mod RimScentExtended -DepMap wsl-deps.scanner-decay.map -Filter 08-extension-points
@requires:nelim.pickletools.colonistrace @requires:nelim.pickletools.stagedecor @requires:nelim.pickletools.coatsteps @requires:nelim.pickletools.screenshotstudio
Feature: RimScent Extended extension points and native scan additions

  Background:
    Given the save "test-colony" is loaded
    And Nelim's Pickle Tools: the settings of the mod "nelim.rimscent.extended" are sandboxed at their defaults

  Scenario: a rotting corpse uses its rot-stage thought
    Given Nelim's Pickle Tools: a closed roofed room is built at (144, 149) of 5 by 5
    And Nelim's Pickle Tools: a rotting corpse of the kind "Muffalo" is placed at (147, 152)
    And a colonist "Ada" exists
    And Nelim's Pickle Tools: "Ada" stands at (144, 150)
    And Nelim's Pickle Tools: "Ada" waits in place
    When I wait 600 ticks
    Then Nelim's Pickle Tools: "Ada" has the thought "RimScentExtended_Scent_CorpseRotting"

  # Tickets c5f6 and f5e4 were red with vanilla food: every vanilla food has rotDestroys=true (read in Core Items_Food.xml), so the meal is destroyed the moment it spoils and never lies spoiled in the room. The test-only RSE_Test_SpoilingCrate (companion mod, Defs) rots without being destroyed. Spoiled food alone in its room: the dominance contest keeps only the strongest scent.
  Scenario: spoiled food uses its thought
    Given Nelim's Pickle Tools: a closed roofed room is built at (144, 149) of 5 by 5
    And Nelim's Pickle Tools: the thing "RSE_Test_SpoilingCrate" is placed at (146, 152) at 1 of its time to rot
    And a colonist "Ada" exists
    And Nelim's Pickle Tools: "Ada" stands at (144, 150)
    And Nelim's Pickle Tools: "Ada" waits in place
    When I wait 600 ticks
    Then Nelim's Pickle Tools: "Ada" has the thought "RimScentExtended_Scent_RottenFood"

  Scenario: a fresh corpse smells of fresh death, not of rot
    Given Nelim's Pickle Tools: a closed roofed room is built at (144, 149) of 5 by 5
    And Nelim's Pickle Tools: a fresh corpse of the kind "Muffalo" is placed at (147, 152)
    And a colonist "Ada" exists
    And Nelim's Pickle Tools: "Ada" stands at (144, 150)
    And Nelim's Pickle Tools: "Ada" waits in place
    When I wait 600 ticks
    Then Nelim's Pickle Tools: "Ada" has the thought "RimScentExtended_Scent_CorpseFresh"
    And Nelim's Pickle Tools: "Ada" has no thought "RimScentExtended_Scent_CorpseRotting"

  # The next scenarios use test-only defs of the companion mod (Defs and Patches): a Chinchilla whose pawn scent needs MoveSpeed above 0.01, a Squirrel whose pawn scent needs MoveSpeed above 1000.
  Scenario: a pawn scent applies when its stat is above the threshold
    Given Nelim's Pickle Tools: a closed roofed room is built at (144, 149) of 5 by 5
    And Nelim's Pickle Tools: 1 animals of kind "Chinchilla" are spawned
    And Nelim's Pickle Tools: the animal "coat-1" stands at (147, 152)
    And a colonist "Ada" exists
    And Nelim's Pickle Tools: "Ada" stands at (144, 150)
    And Nelim's Pickle Tools: "Ada" waits in place
    When I wait 600 ticks
    Then Nelim's Pickle Tools: "Ada" has the thought "RSE_Test_BodyScent_Met"

  Scenario: a pawn scent stays silent when its stat is below the threshold
    Given Nelim's Pickle Tools: a closed roofed room is built at (144, 149) of 5 by 5
    And Nelim's Pickle Tools: 1 animals of kind "Squirrel" are spawned
    And Nelim's Pickle Tools: the animal "coat-1" stands at (147, 152)
    And a colonist "Ada" exists
    And Nelim's Pickle Tools: "Ada" stands at (144, 150)
    And Nelim's Pickle Tools: "Ada" waits in place
    When I wait 600 ticks
    Then Nelim's Pickle Tools: "Ada" has no thought "RSE_Test_BodyScent_Unmet"

  # The diffuser RSE_Test_AromaDiffuser puts RSE_Test_Aroma, which fades after 1500 ticks: still held after 3200 ticks means the scan refreshed it.
  @timeout:30
  Scenario: a scent hediff is refreshed while exposure continues
    Given Nelim's Pickle Tools: a closed roofed room is built at (144, 149) of 5 by 5
    And Nelim's Pickle Tools: the building "RSE_Test_AromaDiffuser" is spawned at (147, 152)
    And a colonist "Ada" exists
    And Nelim's Pickle Tools: "Ada" stands at (144, 150)
    And Nelim's Pickle Tools: "Ada" waits in place
    When I wait 3200 ticks
    Then Nelim's Pickle Tools: "Ada" holds the hediff "RSE_Test_Aroma"

  # RSE_Test_SmellyFloor smells above 30 degrees, once per tile up to a stack limit of 3, baseMoodEffect -4.
  Scenario: terrain scent counts one tile as weaker than three
    Given Nelim's Pickle Tools: a closed roofed room is built at (144, 149) of 5 by 5
    And Nelim's Pickle Tools: the floor of the area from (146, 151) to (146, 151) is set to the terrain "RSE_Test_SmellyFloor"
    And a colonist "Ada" exists
    And Nelim's Pickle Tools: "Ada" stands at (144, 150)
    And Nelim's Pickle Tools: "Ada" waits in place
    And Nelim's Pickle Tools: the room at (144, 150) is held at 40 degrees
    When I wait 600 ticks
    Then Nelim's Pickle Tools: "Ada" has the thought "RSE_Test_SmellyFloor"
    And "Ada" thought "RSE_Test_SmellyFloor" mood offset is above -8

  Scenario: terrain scent stacks on three tiles
    Given Nelim's Pickle Tools: a closed roofed room is built at (144, 149) of 5 by 5
    And Nelim's Pickle Tools: the floor of the area from (146, 151) to (148, 151) is set to the terrain "RSE_Test_SmellyFloor"
    And a colonist "Ada" exists
    And Nelim's Pickle Tools: "Ada" stands at (144, 150)
    And Nelim's Pickle Tools: "Ada" waits in place
    And Nelim's Pickle Tools: the room at (144, 150) is held at 40 degrees
    When I wait 600 ticks
    Then "Ada" thought "RSE_Test_SmellyFloor" mood offset is below -10

  Scenario: terrain scent is silent below its temperature gate
    Given Nelim's Pickle Tools: a closed roofed room is built at (144, 149) of 5 by 5
    And Nelim's Pickle Tools: the floor of the area from (146, 151) to (148, 151) is set to the terrain "RSE_Test_SmellyFloor"
    And a colonist "Ada" exists
    And Nelim's Pickle Tools: "Ada" stands at (144, 150)
    And Nelim's Pickle Tools: "Ada" waits in place
    And Nelim's Pickle Tools: the room at (144, 150) is held at 10 degrees
    When I wait 600 ticks
    Then Nelim's Pickle Tools: "Ada" has no thought "RSE_Test_SmellyFloor"
