# Pass 3: plays after 06 and the removal pass; needs rimscent-extended-scanned.rws in Tests/Pickle/Mod/Pickle/Fixtures/ (copied from the run folder, git-ignored).
@review @requires:nelim.pickletools.loadaudit @requires:nelim.pickletools.colonistrace @requires:nelim.pickletools.savesteps
Feature: RimScent Extended reloads its own save

  Background:
    Given the save "rimscent-extended-scanned" is loaded
    And Nelim's Pickle Tools: the error log is marked

  Scenario: the saved fixture reloads without stale scanner state
    When I wait 600 ticks
    Then Nelim's Pickle Tools: no error was logged since the error log was marked
    And Nelim's Pickle Tools: the load of the mod "nelim.rimscent.extended" is clean
