# Corpse and spoiled food thoughts are owned by the Decay expansion, which the scanner reads by defName: this pass stages it (wsl-deps.scanner-decay.map).
# The three other extension points (pawn scent with a stat threshold, a scent hediff, terrain scent) need defs that no shipped mod provides here:
# a test-only def set in the Pickle companion mod, written by this session (not a Pickle step). They stay @wip until then.
#
#   Submit-PickleRun.ps1 -Mod RimScentExtended -DepMap wsl-deps.scanner-decay.map -Filter 08-extension-points
@requires:nelim.pickletools.colonistrace @requires:nelim.pickletools.stagedecor
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

  # @wip (tickets c5f6, f5e4 red). Suspected, not verified: every vanilla food has rotDestroys=true (read in Core Items_Food.xml), so the meal is destroyed the moment it spoils and never lies spoiled in the room; a spoiled-food thought needs a rottable item that stays (a test-only def in the companion mod). Spoiled food alone in its room: the dominance contest keeps only the strongest scent.
  @wip
  Scenario: spoiled food uses its thought
    Given Nelim's Pickle Tools: a closed roofed room is built at (144, 149) of 5 by 5
    And Nelim's Pickle Tools: the thing "MealSimple" is placed at (146, 152) at 1 of its time to rot
    And a colonist "Ada" exists
    And Nelim's Pickle Tools: "Ada" stands at (144, 150)
    And Nelim's Pickle Tools: the other colonists are out of frame
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

  @wip
  Scenario: a pawn scent respects its configured stat threshold
    Given a colonist "Ada" exists
    Then Nelim's Pickle Tools: "Ada" has no thought "RimScent_Anosmic"

  @wip
  Scenario: a scent hediff is refreshed while exposure continues
    Given a colonist "Ada" exists
    Then Nelim's Pickle Tools: "Ada" does not hold the hediff "RimScent_Anosmic"

  @wip
  Scenario: terrain scent counts tiles and honours its temperature gate
    Given a colonist "Ada" exists
    Then Nelim's Pickle Tools: "Ada" has no thought "RimScent_Anosmic"
