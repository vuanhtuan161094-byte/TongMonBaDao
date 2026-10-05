# CURRENT CHECKPOINT

Date: 2026-10-04

## Runtime-confirmed baseline

Real Windows + Godot 4.7.2 evidence confirms:

- P0-P2.12: PASS;
- P3.1 mobile landscape + living sect shell: PASS;
- P3.2 camera + map target selection + real disciple tabs interaction slice: PASS;
- P3.2 Character Creator V1 shared-rig scaffold: PASS;
- P3.2 `female_normal_v1` Stage A **3-DIRECTION FAST** check: PASS (down/right/up) with user visual review accepted.
- P3.2 `female_normal_v1` shared **IDLE + WALK FAST** check: PASS on real Windows Godot 4.7.2; user video visual review accepted.
- P3.2 live modular female map integration: **REAL PASS** on Windows Godot 4.7.2. `[8/8]` printed `P3.2 LIVE MODULAR FEMALE MAP INTEGRATION TEST PASS` and the final live-map FAST PASS lines.
- P3.3 disciple operational flow (right summary -> real quick orders -> 6-tab deep screen -> context restore): **REAL PASS** on Windows Godot 4.7.2. Contract test + live scene smoke + cumulative P3.2 baseline all green.
- P3.4 building management: **REAL PASS / LOCKED** on Windows Godot 4.7.2. P3.4A read-only panel, P3.4B people management and P3.4C real system actions all green.
- P3.5 living sect cues: **REAL PASS / LOCKED** on Windows Godot 4.7.2. Core resolver/tracker, live-map routing and scene smoke all green; max 3 cues.
- P3.6 Sect Master gameplay loop: design locked; product playtest remains blocked until **P3.6A visual acceptance**. P3.6A player-facing productization is **REAL RUNTIME PASS / VISUAL REVIEW PENDING** on Windows Godot 4.7.2.

Latest real 3-direction FAST tail supplied by the user:

```text
P3.2 CHARACTER CREATOR SHARED RIG CONTRACT TEST PASS
P3.2 FEMALE STAGE A DOWN ASSET CONTRACT TEST PASS
P3.2 FEMALE STAGE A 3-DIRECTION ASSET CONTRACT TEST PASS
P3.2 FEMALE STAGE A 3-DIRECTION FAST CHECK: PASS
FEMALE STAGE A 3-DIRECTION FAST CHECK: PASS
```

User also supplied the real direction-preview screenshot. Visual review accepted front/side/back identity, common ground registration, readable 0.75x silhouette, and no front-face leakage in the back view.

The production female visual slice / Stage A final milestone is **NOT final PASS yet**. Three-direction FAST + visual review are locked. Shared idle/walk runtime contract, sandbox smoke and user video visual review are now accepted. Variants/tints/six-combo proof and the FULL cumulative acceptance remain later.

---

# Character Creator locked contract

Canonical architecture remains **modular appearance + shared 2D rig/animation**.

Locked registration:

- source canvas `128×128`;
- foot anchor `(64,104)`;
- map scale `0.68` at zoom 1.0;
- actor box `88×92`;
- bones: `root, pelvis, torso, head, arm_l, arm_r, hand_weapon, leg_l, leg_r`;
- render order: `shadow -> aura -> hair_back -> weapon_back -> body -> outfit -> face -> hair_front -> head_accessory -> weapon_front -> accessory`.

Appearance remains presentation-only and must not mutate `DiscipleState`, stats, economy, actions, `sex_id`, or P2.8 RNG consumption/order.

---

# Stage A down/front — visual pivot accepted

The user opened the real preview after the down/front FAST gate passed and supplied a screenshot at `0.75x`, `1.00x`, `1.35x`.

Accepted visual observations:

- face/hair/horns remain coherent;
- shoulders/arms do not visibly split from torso;
- no major outfit/skirt seam;
- legs/feet share the same ground registration;
- silhouette remains readable at `0.75x`.

Dark hair + skirt merge somewhat at `0.75x`, but this is future art contrast/simplification work, not evidence of a pivot mismatch.

Therefore **down/front practical pivots are visually locked** and current bone rest positions remain unchanged.

---

# Stage A authored directions — Windows FAST + visual review PASS

Diagnostic proof now supports authored:

- `down` = front;
- `right` = side;
- `up` = back;
- `left` remains mirror-right while mirror-safe.

Each authored direction has 14 registered `128×128` components, total **42 PNGs**. `up` face is intentionally transparent to prevent front-face leakage.

Relevant implementation:

- `godot/src/presentation/p3/female_stage_a_asset_loader.gd`;
- `godot/tests/presentation/p3_2_female_stage_a_down_contract_test.gd`;
- `godot/tests/presentation/p3_2_female_stage_a_directions_contract_test.gd`;
- `godot/src/presentation/p3/female_stage_a_directions_sandbox.gd`;
- `godot/scenes/p3/p3_2_female_stage_a_directions_sandbox.tscn`;
- `Preview-P3-2-Female-Directions.cmd`;
- `Verify-P3-2-Female-StageA.cmd` — 5-step P3.2-only FAST gate;
- `Verify-P3-2-Female-StageA-Full.cmd` — final acceptance only; **do not run yet**.

Live sect-map integration remains untouched.

Real Windows Godot 4.7.2 FAST gate passed on 2026-10-04. The user then opened `Preview-P3-2-Female-Directions.cmd`; front/side/back were visually accepted. No pivot/rest-position retune is needed from this proof.

---

# FAST verification policy

Normal art/pivot iteration remains **P3.2 FAST only** and does not rerun P0-P2.12.

FAST runs:

1. import changed Stage A assets;
2. Character Creator shared-rig contract;
3. locked down/front regression contract;
4. authored `down/right/up` asset contract;
5. authored-direction sandbox smoke.

Expected green tail:

```text
P3.2 CHARACTER CREATOR SHARED RIG CONTRACT TEST PASS
P3.2 FEMALE STAGE A DOWN ASSET CONTRACT TEST PASS
P3.2 FEMALE STAGE A 3-DIRECTION ASSET CONTRACT TEST PASS
P3.2 FEMALE STAGE A 3-DIRECTION FAST CHECK: PASS
FEMALE STAGE A 3-DIRECTION FAST CHECK: PASS
```

---

# Binary asset transport — current authoritative method

The canonical Stage A pack is now transported in Git as text-safe Base64 parts under:

`.github/assets/p3/female_stage_a/`

Canonical ZIP properties remain:

- file: `female_normal_v1_stageA_runtime_pack_v2_quant.zip`;
- 42 Stage A PNGs (`down/right/up`);
- ZIP size: **44,838 bytes**;
- SHA-256: `6a4213b9129ffb3f438c21cbb5326672ddf8915323836bf80cb33b8e5fabfdca`.

Transport repair completed on 2026-10-05:

- central-directory corruption in the unfinished tracked parts was repaired;
- one remaining Base64 payload corruption was isolated to `part11.b64`, index 1432 (0-based), corrected from `a` to `e`;
- a clean CI run then rebuilt the ZIP directly from the tracked parts with **no repair logic**, matched the canonical SHA-256, passed `unzip -t`, extracted 42 PNGs, imported Godot and passed P3.6A FAST;
- the diagnostic brute-force/rebuild code was removed from the production workflow.

`Install-P3-2-Female-StageA.cmd` now prefers this tracked transport, verifies the canonical SHA before extraction, and retains the external ZIP search only as a fallback when the tracked transport is unavailable.

For the current P3.6A Windows flow, use the repository-wide sync policy:

`Sync-Main.cmd Run-P3-6A-Playable-Slice.cmd`

Do not create a phase-specific `Sync-P3-6A-*.cmd`.

---

# Shared idle + walk — Windows FAST + visual motion review PASS

Real Windows Godot 4.7.2 evidence supplied by the user:

```text
P3.2 FEMALE SHARED IDLE WALK MOTION CONTRACT TEST PASS
P3.2 FEMALE STAGE A 3-DIRECTION FAST CHECK: PASS
P3.2 FEMALE SHARED IDLE WALK FAST CHECK: PASS
FEMALE STAGE A + SHARED MOTION FAST CHECK: PASS
```

The user supplied an 11.6-second real Windows motion video. Review accepted the current V1 motion: idle breathing is restrained, walk cadence is stable, there is no obvious anchor jump or severe shoulder/hip tearing, hair/horns remain attached, and LEFT mirrors RIGHT cleanly. Motion is intentionally simple/stiff at this stage; long-hair secondary motion is future polish, not a blocker for map integration.


P3.4C first real Windows attempt reached the cumulative P3.4B regression and failed because the old Medicine Hall test incorrectly required zero controls. P3.4C legitimately adds real NeedsSystem priority controls. The regression was corrected in commit `7c4ce83c13d8e6e7ce7e2cef6e53e3472f0375b6` to forbid only fabricated HEAL/direct-treatment actions. P3.4C itself remains runtime pending until rerun.

P3.5 first Windows attempt exposed a `seed()` naming collision; it was fixed by renaming to `seed_from_state()`. The rerun then passed core, live-map integration and scene smoke.

P3.6A first Windows gate exposed a popup lifecycle bug (`DiscipleDeepScreen2`); `_clear_popup()` was fixed to detach children immediately before `queue_free()`. The subsequent FULL cumulative rerun passed P3.6A contract + live scene smoke.

GitHub CI preview now restores and SHA-verifies the canonical 42-PNG `female_normal_v1` pack before Godot import. Clean CI run #15 passed restore/import/P3.6A FAST/capture/upload and produced the reviewed `1280x720` artifact. The live map now uses real female modular actors where the female rig is authoritative and a neutral humanoid modular fallback for rigs whose art pack is not produced yet; legacy letter-in-circle actors are gated out.

# Next authoritative action

P3.2, P3.3, full P3.4, P3.5 and **P3.6A runtime** remain REAL PASS / LOCKED.

P3.6A actor-pack CI integration is now green:

- tracked Base64 -> canonical ZIP SHA: PASS;
- 42 PNG extraction: PASS;
- Godot import: PASS;
- P3.6A FAST gate: PASS;
- CI preview capture/upload: PASS;
- legacy letter-circle actors removed from the live map contract;
- fixed actor-status text removed from the idle map to reduce overlap;
- live actor spacing and building cue offsets improved.

Latest reviewed CI preview is materially cleaner, but **final P3.6A visual acceptance still belongs to the user on the real Windows preview**. Do not self-declare visual PASS.

With the Windows machine available, run from repo root:

`Sync-Main.cmd Run-P3-6A-Playable-Slice.cmd`

That performs:

`safe main sync -> tracked Stage A restore + SHA check -> P3.6A FAST -> real preview on PASS`.

No FULL cumulative rerun is required for this visual review because the FULL gate already passed in this acceptance cycle.

# Current development priority — functionality first

User explicitly deprioritized micro-detail on the small map actor. Character Creator remains necessary only to avoid obvious clones; it must not block management gameplay.

Order:

1. P3.2 live modular female map `[8/8]`: **REAL PASS / LOCKED**;
2. P3.3 disciple operational flow: **REAL PASS / LOCKED**;
3. P3.4 building interaction/management: real workers, inputs, outputs, assignment/management actions;
4. P3.5 living-sect cues: fatigue/heal/breakthrough/material/finished-work signals from real state;
5. P3.6A productize the live map into a genuinely playable slice; only then resume the P3.6 5–10 minute playtest;
6. add only the minimum face/hair/outfit/weapon/tint variants needed to make disciples visually distinguishable;
7. six-combo proof + FULL female visual gate later, after core management interaction is stable;
8. appearance persistence;
9. male rig/art expansion later.

Do not let cosmetic production block functional map-management work.


# P3.7 long-term sect economy / hunting direction — DESIGN AUTHORITY ADDED 2026-10-05

Canonical spec:

`docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md`

Locked direction:
- 1,000–3,000 disciples are supported conceptually; management must be by teams/halls/policies rather than per-disciple micro;
- hunting/outside activity is the main long-term loop, with a rough 70% outside / 30% rear-base target;
- standard hunting team is 5; solo-oriented traits may support solo hunting;
- no permanent disciple death in the current design; defeat creates Thương Thế and recovery downtime;
- hunting naturally consumes time/stamina/medicine/durability and returns Spirit Stones, materials, items, techniques, treasure fragments and progression;
- disciples do not have full RPG inventories; temporary team loot bags settle into sect storage on return;
- personal economy is limited to equipped gear, personal Spirit Stones, Contribution Points and a small consumable allowance;
- equipment distribution is policy-driven with direct Sect Master override;
- profession levels may reach 1,000+; every profession level gives +1% profession efficiency, EXP requirements rise with level, profession levels never decay;
- profession milestone specialization and broad Bách Nghệ Lịch Luyện bonuses are planned;
- sect members continue gaining passive cultivation while working; focused cultivation is faster, while work also grants profession/economic growth;
- Secret Chambers are paid services using personal Spirit Stones; disciples choose autonomously according to AI/personality but the Sect Master can intervene;
- all material magnitude uses one canonical numeric quality measure: **Phẩm Lực**; realm-style labels are presentation only and are not hard content locks;
- normal building instances target Lv.1–100; long-term scale comes from more facilities rather than infinitely leveled individual buildings;
- all Sect Treasures may contribute simultaneously; no tiny active-slot cap.

## Construction resource rule

Normal building upgrades use one common construction language:

1. **Linh Mộc** — structural wood/organic construction material;
2. **Khoáng Liệu** — structural mineral/stone/metal material;
3. **Linh Thạch** — currency + activation/energy sink.

Material quantity can be satisfied by eligible stock using **Phẩm Lực**, avoiding hard "material tier = building level" recipes.

Only milestone upgrades require one thematic specialty component, e.g.:
- Spirit Field -> Spirit Soil / Spirit Spring / formation component;
- Mine -> prospecting/reinforcement component;
- Alchemy -> furnace core / Fire Essence;
- Artifact Hall -> furnace core / special metal;
- Secret Chamber -> Formation Core / spirit-jade;
- Beast Hall -> Beast Core / taming formation component.

Next design action: finish the canonical building tree before implementing broad P3.7 code.


# P3.7 building tree authority — ADDED 2026-10-05

Canonical child spec:
`docs/P3_7_BUILDING_TREE_SPEC.md`

Locked building architecture:
- normal building instances are Lv.1–100;
- routine levels raise efficiency/capacity/throughput/processing capability;
- milestone levels open mechanics rather than only +% stats;
- long-term scale comes from more facility instances, not infinite building levels;
- common upgrade language is Linh Mộc + Khoáng Liệu + Linh Thạch;
- milestone upgrades add only one thematic specialty component;
- construction material fulfillment is Phẩm Lực-based with warehouse reserve/lock rules;
- production buildings do not hard-lock material by realm/tier; higher-PL material above facility capability suffers penalties instead;
- the first authoritative implementation slice is: Đại Điện, Kho, Linh Điền, Mỏ, Đệ Tử Xá, Tu Luyện Đài, Y Quán, Luyện Đan, Luyện Khí, Hậu Cần, Săn Yêu Điện, Phường Thị, Cổng Tông Môn;
- Mật Thất follows immediately after the personal Spirit Stone economy exists;
- Phù Lục, Trận Pháp, Ngự Thú, Tửu, Linh Trù, Hoa, Đấu Giá and advanced facilities are later expansions.

Next design task before code:
define exact data contracts for resource stacks/Phẩm Lực, building instances, profession EXP curve, warehouse policy, construction resolver and hunting settlement.


# P3.7 loadout / hunting progression authority — ADDED 2026-10-05

Canonical child spec:
`docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md`

Locked:
- no full personal RPG inventory at 1,000–3,000 disciple scale;
- personal loadout target: weapon x1, armor x1, talisman x3, Pháp Bảo x2, Main Technique x1, Auxiliary Techniques x2, small consumable belt;
- disciple AI autonomously seeks compatible upgrades and avoids tiny churn;
- explicit item ownership: sect-owned loan vs disciple-owned personal property;
- sect-owned gear may be reassigned normally;
- forcibly requisitioning disciple-owned gear requires Contribution compensation;
- returned hunting loot defaults to sect property and grants Contribution credit to hunters;
- hunting grants Tu Vi + Contribution + Spirit Stones + loot;
- hunting cultivation reward scales from the disciple's current-stage Tu Vi requirement and relative monster realm/challenge;
- target healthy appropriate hunting progression is roughly 10–20× ordinary rear-base work cultivation rate;
- no permanent death; injury/medicine/durability/downtime are the PvE cost;
- P2.1's old +2 cultivation/victory is preserved as historical locked baseline until explicit P3.7 migration.
