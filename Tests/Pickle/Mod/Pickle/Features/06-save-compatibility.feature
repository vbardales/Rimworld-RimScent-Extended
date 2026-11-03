# Pass 1 and pass 3 run with RimScent Extended. Mod removal cannot happen in-process: the pass
# without the mod needs a host mod and a feature that do not depend on it (see STATUS.md, 7.d).
# Then 06b-save-reload plays the handed-over fixture.
@review @requires:nelim.pickletools.loadaudit @requires:nelim.pickletools.colonistrace @requires:nelim.pickletools.savesteps
Feature: RimScent Extended is safe across save boundaries

  Background:
    Given the save "test-colony" is loaded
    And Nelim's Pickle Tools: the error log is marked

  Scenario: rse-adds-no-save-data: an existing save loads, scans and saves cleanly
    When I wait 600 ticks
    Then Nelim's Pickle Tools: no error was logged since the error log was marked
    And Nelim's Pickle Tools: the load of the mod "nelim.rimscent.extended" is clean
    When Nelim's Pickle Tools: the game is saved as "rimscent-extended-scanned"
    And Nelim's Pickle Tools: the saved game "rimscent-extended-scanned" is handed to the mod "nelim.pickletools"
