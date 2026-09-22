# Do not generate this fixture from the suite. A ticket must provide a disposable pre-extension
# save and document its RimScent/RimWorld versions before this @wip feature can be selected.
@wip
Feature: RimScent Extended is safe across save and removal boundaries

  Background:
    Given the fixture "rimscent-pre-extension-save" is loaded
    And RimScent Extended save observations are reset

  Scenario: loading an existing save adds no persistent data requirement
    When the fixture is saved to a disposable slot
    And RimScent Extended reloads the disposable slot
    Then RimScent Extended reports no load, Scribe, or scan exception
    And RimScent Extended observes no serialized adaptation state requirement

  Scenario: removal and re-addition do not leave stale scanner state
    Given the fixture is saved after RimScent Extended has scanned a scented room
    When RimScent Extended is removed from the disposable mod list
    And the fixture is loaded without RimScent Extended
    Then the fixture loads without a missing type or Scribe error
    When RimScent Extended is re-added and the fixture is loaded again
    Then RimScent Extended reports no stale scanner state or repeated exception
