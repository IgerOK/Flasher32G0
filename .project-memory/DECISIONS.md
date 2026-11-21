# Architectural Decisions

Record significant choices here. Each entry stays forever — no deletion, only additions.

## Decision format

```
## YYYY-MM-DD — <decision title>
- Decision: what was chosen and why.
- Consequences: what this affects.
```

## Current decisions (new ones added at end)

*(Add new decisions at the bottom. Do not modify old entries.)*

## 2026-11-08 — Initial memory structure

- Decision: use markdown files in repo for project memory, platform-independent.
- Consequences: works with any agent, any platform; no API keys; version-controlled with code.

## 2026-11-08 — Layering, current-task state, and event-driven updates

- Decision: separate memory into protocol (AGENTS.md) and project state (TASK.md, CONTEXT.md, DECISIONS.md, QUESTIONS.md), plus a local scratch layer (.in-progress.md); update state by event (decisions, verified steps, plan changes, resolved questions) rather than only at session end.
- Consequences: any agent can pick up the project and immediately know current work and open questions; state is compact and trackable; old history stays in SESSIONS.md/ARCHIVE.

- Decision: persistence now happens during the session, not only at its end — scratchpad `.in-progress.md` (`status: open/closed`), automatic recovery in the protocol, rescue-commit script `scripts/memory-autosave.sh`, optional pre-commit hook to sweep memory into every commit.
- Consequences: power loss / killed process no longer loses session context; recovery works by protocol; all four mechanisms are small, git-tracked and platform-independent.

## 2026-11-09 — Self-contained .project-memory folder

- Decision: all system elements live inside `.project-memory/` — `memory-autosave.sh` and the `pre-commit` hook moved into the folder, `scripts/` and `.githooks/` deleted. Hook install: `git config core.hooksPath .project-memory`.
- Alternatives considered: keep scripts outside the folder — rejected: the user wants a single self-contained folder.
- Consequences: installing the memory in another project = copying one folder; all path references updated (AGENTS.md, CONTEXT.md, both READMEs, the scripts themselves).

## 2026-11-09 — AllToAny as the single memory repo

- Decision: AllToAny is the single public repo of the memory system; older siblings (AllToZed, AllToDSH, alltoone, allToOne-setup) will be deleted by the user.
- Alternatives considered: "Смежные проекты" section with cross-links in the README — rejected: not needed once the old repos are gone.
- Consequences: AllToAny docs contain no external links to sibling repos (verified by grep); deleting them breaks nothing.

## 2026-11-21 — BOOT0 via nBOOT_SEL option byte (G0/G4)

- Decision: the requirement "enable BOOT0 recognition so the chip can be used both as SWD and UART" is implemented as a new `nBOOT_SEL` option byte control for G0/G4 only. `nBOOT_SEL=0` → the physical BOOT0 pin is honoured (legacy mode): BOOT0=1 boots the system memory bootloader (UART/USB DFU), BOOT0=0 boots user flash. `nBOOT_SEL=1` (factory default) → the pin is ignored and boot region comes from the `nBOOT0` option bit. SWD programming is unaffected in either case.
- Alternatives considered: adding `nBOOT0`/`nBOOT1` bits directly — rejected: with `nBOOT_SEL=1` the nBOOT0 bit already forces system-memory boot without any pin, which is a different, rarer use case; the pin-legacy semantics are what the user asked for. F1/F4 families left untouched (their boot behaviour differs, no BOOT0 pin option byte there).
- Consequences: GUI gains a "BOOT0" group (checkbox + current-state label), right panel buttons shift down, default window height 530→615. Generated `-ob` commands now append `nBOOT_SEL=` for G0/G4. Family-specific availability kept in `ConfigureGuiForFamily`.
- **Revoked 2026-11-21 (evening):** user reviewed the UI and asked to switch to "activation" semantics — see next entry.

## 2026-11-21 — BOOT0 = System Bootloader activation (nBOOT_SEL=1 + nBOOT0)

- Decision: after user review (screenshot, commit 80f142f), the "BOOT0" GUI group was redefined. It now writes `nBOOT_SEL=1` (factory value: physical pin ignored — on G0/G4 the pin is usually not exposed) combined with `nBOOT0=0` (system memory bootloader ON → firmware update over UART/USB DFU without ST-LINK, SWD still works) or `nBOOT0=1` (user-flash boot, bootloader off). The earlier "pin recognition" (`nBOOT_SEL=0`, legacy) semantics was replaced.
- Alternatives considered: keeping `nBOOT_SEL=0` legacy pin mode — rejected: on G0/G0/G4 the BOOT0 pin is typically absent from the PCB, so there is nothing to sample; `nBOOT0` is the ST-recommended programmatic way in.
- Consequences: command generation is now `nBOOT_SEL=1 nBOOT0=<0|1>` for G0/G4; the parser reads `nBOOT0` from `-ob displ` (regex also tries `BOOT0:`; fallback label «(не читается)» if the CLI output differs); IWDG label fix (w170, indicator under the checkbox) shipped in the same commit.
- **Refined 2026-11-21 (commit 5d57bc5) per user clarification:** the user clarified the exact intended semantics — the checkbox is a deliberate user choice: `nBOOT0=1` (off) → programming **via SWD only**; `nBOOT0=0` (on) → programming **via SWD (CLKSWD=0) AND via UART (CLKSWD=1)**, where the CLKSWD pin level is set by the user manually before power-up (jumper to VCC for =1; recommended 10kΩ pull-down from CLKSWD to GND). Text in GUI/preview/warnings/help/README was updated accordingly; .exe is recompiled by the user.