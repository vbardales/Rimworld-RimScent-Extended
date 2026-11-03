# Pass 1 (this file, RSE present) copies the saved game to the run folder. Pass 2 (RSE removed) is PickleTools' removal-check.feature, see STATUS.md.
# Between passes copy <run>/rimscent-extended-scanned.rws to Tests/Pickle/Mod/Pickle/Fixtures/ (git-ignored) and to PickleTools' removal-check.rws.
# Then 06b-save-reload reloads the copied fixture (pass 3, RSE re-added).
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
    And Nelim's Pickle Tools: the saved game "rimscent-extended-scanned" is copied to the run folder
