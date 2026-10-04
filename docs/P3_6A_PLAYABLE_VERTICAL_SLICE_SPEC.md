# P3.6A — PLAYABLE VERTICAL SLICE / BIẾN DEBUG SHELL THÀNH GAME CÓ THỂ CHƠI

Date: 2026-10-05
Status: DESIGN LOCKED FROM REAL USER VIDEO / IMPLEMENTATION NEXT

## 0. Trigger

Real Windows video supplied by the user after P3.5 PASS showed that the current live main scene is still a QA/debug shell rather than a player-ready game surface.

Observed problems:

- buildings are placeholder rectangles/letter markers rather than production presentation;
- panels expose internal phase wording such as P3.4A/P3.4B/P3.4C;
- left task rail is still a demo/proof checklist, not real objective/gameplay;
- map/world lacks sufficient production environment/readability to feel like a living sect;
- interactions prove backend wiring but feel like operating a test dashboard;
- the scene is not yet suitable for the P3.6 5–10 minute product-loop acceptance test.

Therefore P3.6 product playtest is **BLOCKED** until P3.6A is complete.

---

## 1. Goal

Turn the existing technically working live scene into the first **player-facing playable slice** without inventing a parallel simulation.

Target experience:

`open game -> immediately see a small living sect -> understand what disciples/buildings are doing -> make one meaningful decision -> see a real consequence`.

P3.6A is presentation/productization over already-green P3.3/P3.4/P3.5 systems.

---

## 2. Non-negotiable cleanup

The live player scene must contain **zero developer-phase copy**.

Remove player-visible strings such as:

- P3.4A / P3.4B / P3.4C / P3.5;
- "authority thật";
- "baseline";
- "runtime";
- "sẽ mở ở phase...";
- contract/test explanation text.

Replace with concise in-world/player-facing Vietnamese.

Tests may still search internal node names/functions; only player-facing copy must be clean.

---

## 3. Main map must stop reading like a test board

### Required

- map remains 1280×720 landscape;
- production visual direction remains hand-painted xianxia;
- real building identities are readable from visual/silhouette, not A/B/C markers;
- actor movement remains driven by real current_action/destination;
- world cues remain max 3;
- selected building/disciple remains obvious;
- top resource bar remains compact;
- map remains primary surface.

### Not acceptable

- colored debug rectangles as the final building representation;
- giant letter markers used as gameplay identity;
- raw diagnostic labels permanently visible;
- empty flat board with UI widgets floating over it.

If exact approved building/environment source bytes are still unavailable, P3.6A must explicitly stop at a **player-readable temporary visual pack** only after following the presentation approval workflow. It must not silently redesign previously approved art.

---

## 4. Task rail

Current P3.1 demo checklist is not a quest system.

For P3.6A:

- hide/remove the demo checklist from the normal player build, OR
- replace it only with a minimal real onboarding objective derived from existing actions.

Do not present proof tasks such as "observe X" as if they are finished game content.

No reward/claim loop is added.

---

## 5. Building panels

Keep P3.4 authority/actions but rewrite presentation.

### Player sees

- building name;
- current operating state;
- relevant workers/resources;
- real warning/reason if blocked;
- compact actionable buttons.

### Player must NOT see

- implementation explanations;
- phase names;
- internal system names unless they are real game terminology;
- paragraphs explaining what future phase will implement.

Routine building panel should feel like a game management panel, not documentation.

---

## 6. Disciple panel/deep screen

Keep P3.3 flow and real six tabs.

P3.6A must:

- remove debug/proof wording;
- preserve real HP/stamina/cultivation/action/location;
- make quick orders visually obvious;
- keep deep screen optional for routine play.

No new character mechanic is required.

---

## 7. Visible autonomous loop

Before P3.6 playtest can resume, the live slice must visibly demonstrate at least:

1. disciple moves to a destination because simulation action changed;
2. one work/cultivation/rest behavior completes without player micromanaging each tick;
3. a real resource/state changes;
4. world cue appears/disappears from real condition/event;
5. one policy/group/direct order can be issued and its consequence can later be observed.

This is not a new mechanic. It is the already-existing mechanics presented coherently.

---

## 8. P3.6A acceptance

A real Windows video/session must prove:

1. first impression looks like a game, not a QA board;
2. no P3.x/debug/internal implementation copy visible;
3. no demo checklist pretending to be gameplay;
4. player can identify core buildings/actors without letter-box placeholders;
5. at least one meaningful action is understandable without reading documentation;
6. autonomous simulation visibly continues while player watches;
7. player sees one real consequence from a management decision;
8. map remains the primary interaction surface;
9. P3.3/P3.4/P3.5 cumulative gates remain green.

Only after this is accepted does P3.6 5–10 minute product-loop playtest resume.

---

## 9. Scope discipline

P3.6A does NOT add:

- daily chores;
- offline rewards;
- building level trees;
- fake crafting queues;
- new currencies;
- world-map feature expansion;
- recruitment redesign;
- notification center;
- new disciple systems.

It is a productization pass over the systems already implemented.

---

## 10. Visual production rule

Any new/generated/edited visual asset or mockup still requires the locked presentation workflow:

`read authority -> present exact plan -> user says OK -> generate/edit -> user accepts -> update authority/registry`.

Do not generate replacement art automatically.
