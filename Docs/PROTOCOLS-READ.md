# Documentation read ledger

Read on 2026-09-26 for the RimScent Extended audit and Pickle work.  This is a
cache of what was actually read, not a claim that later revisions were applied.
Protocol documents were read from the `rimworld-protocols` work tree at
`affb9c4cb67e969b87c22efe3934314be0fd8fd8`, with no local modification among
the listed paths.  The SHA-256 prefixes below identify the exact file content.
The mod documentation was read at local commit
`abd40fb0f45f4b461cfcd23c447bc78083ad6e72`, with a clean working tree before
this ledger was added.

## Used for the current work

| Path | Version read | Why it matters now |
| --- | --- | --- |
| `AGENTS.md` | `36631e730433` | Evidence retention, `docs/runs/` convention, and CI publishing boundaries. |
| `AUDIT.md` | `d5dc23b06e35` | Source-driven stages; Windows prohibition; WSL/dispatcher-only Pickle runs; how to conclude a ticket. |
| `MOD_SETTINGS.md` | `404916bc99a7` | Primary settings route and hidden-by-default MainButtons contract. |
| `PUBLISHING.md` | `7d34f55d583d` | Preconditions and owner-only production actions. |
| `TRANSLATIONS.md` | `298f74d226da` | English/French coverage and static versus in-game claims. |
| `STYLE_RIMWORLD.md` | `de13cbe5e1f9` | Preview and player-facing presentation conventions. |
| `PickleTools/README.md` | `628350c7bcc3` | Pickle companion and suite structure. |
| `PickleTools/Headless/README.md` | `488a0bb2ca83` | Headless execution, evidence and WSL constraints. |
| `PickleTools/docs/steps.md` | `0f897b4557a9` | Available Gherkin-step vocabulary and limits. |
| `Rimworld-Ticket-Dispatcher/docs/WELCOME.md` | `135d16d524e8` | Pass selection, owner label, dependency maps, and completion notifications. |
| `Rimworld-Ticket-Dispatcher/docs/SUBMIT.md` | `90b7385b1bda` | Submission arguments, evidence directory behavior, and exit-code interpretation. |
| `STATUS.md` | blob `36031f183e2` | Retained `preTest` status and its evidence/unverified boundaries. |
| `README.md` | blob `b46b46455a4` | Scope, player-facing behavior, settings, and extension-point contracts. |
| `CHANGELOG.md` | SHA-256 `d445c9d94240` | Declared 0.4.0 contents. |
| `ATTRIBUTION.md` | SHA-256 `d573ff2a398d` | Upstream attribution and rights boundary. |
| `LICENSE` | SHA-256 `b054d95f9b2c` | MIT terms for this repository's work. |
| `NOTES.md` | blob `610b383c3d18` | Design history and cross-expansion rationale. |
| `BUGS.md` | blob `a3ecb8f4cf20` | The five upstream scanner fixes and their intended behavior. |
| `Tests/Pickle/` | tree `ec16c315ed23` | Companion metadata, compiled steps, map and eight feature specifications; two minimal features are selectable and five are deliberately `@wip`. |
| `Mod/About/About.xml` | blob `171a20327f2` | Package identity, hard dependency and metadata contract. |

## Read but not useful to this task — do not automatically reread on change

These documents were read at the versions below.  A change alone does not make
them relevant to the current audit/Pickle task; reread them only for the stated
kind of work.

| Path | Version read | Reread only for |
| --- | --- | --- |
| `WORKSHOP_COMMENTS.md` | `6c69a05bb424` | Workshop comments or moderation work. |
| `scripts/SEARCHING.md` | `9dbd52b2bcd4` | A new cross-repository search procedure. |
| `Rimworld-Release-Admin/docs/OPERATIONS.md` | `f6f85474f6d3` | Release-admin, Steam secrets, dry-run or publication operations. |

## Requested paths not present at read time

No content was invented or treated as read for the following absent local
paths.  Their absence is itself relevant to documentation completeness.

| Requested path | State on 2026-09-26 |
| --- | --- |
| `PUBLICATION.md` | absent |
| `TESTING.md` | absent |
| `BACKLOG.md` | absent |
| `docs/runs/` | absent |

`docs/PROTOCOLS-READ.md` was also absent before this ledger; this file now
provides the requested local record.
