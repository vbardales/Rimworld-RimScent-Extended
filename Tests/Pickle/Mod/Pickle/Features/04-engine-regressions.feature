# This feature is deliberately @wip: it names the fixture and local observations required for
# the five patched scanner defects. The fixture is not generated here; create it only from a
# dedicated ticket, then implement the RimScent Extended-prefixed steps against that fixture.
@wip @review
Feature: RimScent Extended scanner regressions

  Background:
    Given the fixture "rimscent-engine-regressions" is loaded
    And RimScent Extended scanner observations are reset

  Scenario: a switched-off fuelled incense burner contributes no scent
    Given the fixture has a fuelled flickable incense burner beside "Ada"
    When RimScent Extended switches that incense burner off
    Then RimScent Extended observes no incense thought for "Ada"
    When RimScent Extended switches that incense burner on
    Then RimScent Extended observes the fixture's incense thought for "Ada"

  Scenario: an indoor pawn only scans their own room
    Given the fixture puts "Ada" indoors beside a scented source in another room
    And the fixture puts a second scented source in Ada's room
    When RimScent Extended runs one scent scan for "Ada"
    Then RimScent Extended observes only the same-room scent for "Ada"

  Scenario: trait-degree anosmia and dysosmia affect only matching pawns
    Given the fixture gives "Ada" the matching anosmia trait degree
    And the fixture gives "Bea" the matching dysosmia trait degree
    When RimScent Extended runs one scent scan for each fixture pawn
    Then RimScent Extended observes no matched scent for "Ada"
    And RimScent Extended observes an inverted matched scent for "Bea"
    And RimScent Extended observes the ordinary matched scent for an unaffected pawn

  Scenario: temperature changes a scent factor only when enabled
    Given the fixture has equivalent scented rooms at -10 C, 20 C, and 45 C
    When RimScent Extended enables temperature and scans each room
    Then RimScent Extended observes scent factors 40, 100, and 160 percent
    When RimScent Extended disables temperature and scans each room
    Then RimScent Extended observes the base scent factor in every room
