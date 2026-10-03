# ADR-0001 — Use presentation authority + registry workflow

Status: accepted
Date: 2026-10-03

## Context

Presentation work had begun to drift between chats: a new mockup could accidentally invent a new building family or UI language even though approved assets already existed. Binary art was also not reliably recoverable from live GitHub, so prose memory alone was not enough.

The project needs a workflow that lets a future chat answer four questions immediately:

1. what is authoritative?;
2. which asset/reference was already approved?;
3. what is still pending visually vs runtime?;
4. what may be changed without redesigning locked work?

## Options

### A. One giant P3 document

Pros: one file to open.

Cons: grows quickly, duplicates subsystem details, hard to maintain, easy to miss the relevant section.

### B. Independent MD files only

Pros: focused.

Cons: no single router/status source; future chats may read the wrong file or miss a locked asset.

### C. Master router + Art Bible + per-domain authority docs + machine-readable registry + ADRs

Pros:

- one entry point;
- focused domain detail;
- cross-cutting style stays coherent;
- asset status can be validated automatically;
- historical rationale is not lost when canonical docs evolve.

Cons: adds a small amount of documentation discipline.

## Decision

Choose option C.

Canonical flow:

`P3_PRESENTATION_MASTER -> P3_ART_BIBLE -> relevant domain MD -> approved source/reference -> plan -> user approval -> image/implementation -> registry/doc update`.

Every image generation/edit/mockup requires a user-approved textual plan first.

`docs/P3_ASSET_REGISTRY.json` tracks status/evidence without duplicating detailed art specs.

Major lasting decisions go in `docs/decisions/`; routine asset/tuning changes do not.

## Consequences

Positive:

- approved building/actor/UI families cannot be silently reinvented;
- visual approval and runtime PASS remain separate evidence axes;
- future chats have a deterministic read path;
- CI can catch missing authority docs, invalid status values and duplicate asset IDs.

Costs:

- every accepted visual needs a short registry/doc update;
- binary source assets still need a durable storage mechanism, addressed separately by ADR-0002.

## Links

- `docs/P3_PRESENTATION_MASTER.md`
- `docs/P3_ART_BIBLE.md`
- `docs/P3_ASSET_REGISTRY.json`
- `tools/validate_p3_presentation.py`
