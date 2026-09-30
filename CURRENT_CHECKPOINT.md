# CURRENT CHECKPOINT

Date: 2026-09-30

## Project state

- Step 13 Technical Architecture & Development Roadmap: LOCKED.
- Step 14 P0 Prototype Specification: LOCKED.
- Step 15 P0 Foundation: LOCKED / PASS.
- Step 16 P1.1 Goal + Personality: LOCKED / PASS.
- Step 17 P1.2 Recruitment + Player Choice: LOCKED / PASS.
- Step 18 P1.3 Relationships + Behavioral Impact: LOCKED / PASS.
- Step 19 P1.4 Consequential Memory: IMPLEMENTED / AWAITING RUNTIME GATE.
- Step 20 P1.5 Organization + Teams + Leadership + Roles: IMPLEMENTED / AWAITING RUNTIME GATE.
- Step 21 P1.6 Sect Life + Needs + Resource Pressure: IMPLEMENTED / AWAITING RUNTIME GATE.
- Step 22 P2.1 Cultivation + Realms + Breakthrough: IMPLEMENTED / AWAITING RUNTIME GATE.
- Step 23 P2.2 Spiritual Root Quality + Long-Term Growth: IMPLEMENTED / AWAITING RUNTIME GATE.
- Step 24 P2.3 Technique Economy + Library + Mastery: IMPLEMENTED / AWAITING RUNTIME GATE.

Locked baseline before the unverified stack: `bbdca12b3f1efd14d31982810859d22f51990ff4` (P1.3 lock).

Implementation checkpoints before each pending phase:

- before P1.5: `b1fc434c6e05cac451b60ab11c4c855476e00842`;
- before P1.6: `541b67ccc9f847b4c9c44d43ea82317b5668c20e`;
- before P2.1: `a4fe78a8f94d774f9351aaf3b02fd78ad1aaee08`;
- before P2.2: `cc9be52e72b1e787962edaab44319b680805f3b3`;
- before P2.3: `705a7ff2ac2f6cdc2432edc118e7cb0ff337b79d`.

## Architecture locks

- Engine: Godot 4.7.2 / GDScript.
- Godot owns gameplay/simulation authority.
- Deterministic seeded simulation remains mandatory.
- Save/load, invariants and P0 money conservation remain mandatory.
- P0–P1.3 are locked regression baselines.
- P1.4–P2.3 may be implemented while the user is away from the Windows machine, but none may be marked PASS without real local Godot runtime evidence.
- New systems remain opt-in so earlier factory paths stay available.
- A mechanic is not complete if it adds only story/title/rarity/element/progress without measurable simulation or player-decision consequence.

## Locked P0–P1.3

P0, P1.1, P1.2 and P1.3 are PASS / LOCKED with recorded local Godot `4.7.2.stable.official.ed1daf0bf` evidence.

## Pending P1.4–P2.2

Implemented, not runtime-verified. Their contracts remain mandatory and are chained into the active verifier.

Key carried-forward consequences:

- P1.4 bounded consequential memory;
- P1.5 teams/leadership/roles;
- P1.6 medicine/supplies/lodging pressure;
- P2.1 cultivation/realms/breakthrough with real combat and region-choice consequences;
- P2.2 root quality changing cultivation rate and breakthrough probability without a hard realm cap.

## Active P2.3 — Technique Economy + Library + Mastery

P2.3 implements the complete first technique loop instead of a decorative technique list.

### Ownership model

A complete technique manual and Tàng Kinh Các archive are separate.

- gacha or fragment crafting creates a complete manual;
- a manual may be sold for sect spirit stones;
- or one manual may be consumed to permanently archive that technique;
- archived knowledge is not consumed when disciples learn;
- only archived techniques can be learned.

This preserves the player choice between immediate liquidity and long-term sect capability.

### In-game spirit-stone economy

P2.3 introduces spirit stones separately from P0 money.

- sect spirit stones pay for player gacha;
- personal spirit stones are farmed by disciples;
- learning transfers personal spirit stones into the sect pool;
- gacha is an explicit sect-spirit-stone sink;
- selling manuals is an explicit external-market spirit-stone source.

P0 money conservation remains independent and unchanged.

Initial fresh P2.3 state receives 500 sect spirit stones so the gacha interaction can be exercised.

### Gacha

- cost: 100 sect spirit stones;
- deterministic separate RNG using simulation seed + gacha index;
- does not consume gameplay/combat/recruitment RNG state;
- returns one complete manual.

No real-money/premium purchase, pity, banner or timed event system exists in P2.3.

### Farming

After a combat victory, a deterministic P2.3-only RNG stream may generate:

- personal spirit stones;
- Linh Tủy / Huyền Thiết / Yêu Đan;
- technique fragments.

These travel in the disciple inventory. When the disciple returns to the sect:

- spirit stones enter the personal wallet;
- fragments/materials enter sect stores;
- submitted fragments/materials award personal Contribution.

Special P2.3 loot is removed before ordinary P0 market selling, so it cannot accidentally be sold as a 1-money generic item.

### Fragment crafting

Fragment requirements are technique-specific.

Enough fragments may be combined into one complete manual. Crafting consumes the exact fragment requirement.

The crafted manual can then be archived or sold like a gacha manual.

### Learning

A disciple may know at most 3 techniques.

Learning requires:

- technique archived in Tàng Kinh Các;
- enough personal Contribution;
- enough personal spirit stones;
- an available learned-technique slot.

Learning consumes Contribution and transfers the personal spirit-stone fee into sect spirit stones.

Only one learned technique is active at a time. The player may switch the active technique. This prevents effect stacking while making multiple learned techniques strategically useful.

### Technique mastery and upgrades

During a successful CULTIVATE action:

- cultivation progress is gained through the existing P2.1/P2.2 logic plus active-technique effect;
- the active technique also gains mastery XP.

Mastery XP stops at the current upgrade threshold.

Technique level cap in P2.3: 5.

Level-up is not automatic. It requires the XP threshold plus sect-owned upgrade materials, and consumes those materials. XP resets after a successful level-up.

### Technique identity

Each technique has four tags from the start:

- rarity: Phàm / Huyền / Địa / Thiên;
- path: Kiếm / Thể / Pháp;
- element: Kim / Mộc / Thủy / Hỏa / Thổ;
- role: growth / offense / defense / stability.

P2.3 does NOT yet give a disciple a fixed class. These tags are stored now so a later cultivation-path phase can infer Kiếm tu/Thể tu/Pháp tu from actual technique history rather than retrofitting technique data.

### Elemental roots

P2.2 quality remains unchanged and still determines long-term cultivation/breakthrough potential.

P2.3 adds elemental affinity only because it now has a measurable interaction with techniques:

- Tạp root: 3 elements;
- Phàm root: 2 elements;
- Địa root: 1 element;
- Thiên root: 1 element.

Element assignment has its own deterministic seed and does not modify root-quality or recruitment RNG.

Matching element increases technique mastery speed and effect strength. Mismatch reduces them but never forbids learning.

P22Factory remains element-free.

### Six initial techniques

- Dưỡng Khí Quyết — Phàm / Pháp / Mộc / growth;
- Huyền Giáp Công — Huyền / Thể / Thổ / defense;
- Liệt Chiến Quyết — Huyền / Thể / Hỏa / offense;
- Thanh Phong Kiếm Quyết — Địa / Kiếm / Kim / offense;
- Xích Viêm Chân Quyết — Địa / Pháp / Hỏa / offense;
- Hàn Nguyệt Tâm Pháp — Thiên / Pháp / Thủy / stability.

### Real simulation consequences

Depending on technique, level and affinity, the active technique can change:

- cultivation gain;
- effective combat power;
- incoming combat damage;
- breakthrough probability;
- breakthrough-failure cultivation/HP/stamina loss.

Effective combat power already feeds region-choice under-power penalties, so technique progression can also change autonomous destination choice.

### Scale contract

- max 3 learned techniques per disciple;
- one active technique calculation per disciple;
- O(1) library/manual/fragment/material lookups;
- O(1) farm reward generation per combat victory;
- no new N x N structures;
- gacha only scans the small static technique pool.

### P2.3 verification contract

1. Full P0 through P2.2 gate chain must PASS first.
2. P22Factory remains technique-off and element-free.
3. P2.3 elemental roots are deterministic.
4. Gacha consumes exactly 100 sect spirit stones and does not mutate gameplay RNG/recruitment outcomes.
5. Gacha produces a tradable manual, not automatic archive access.
6. Archive consumes one manual and permanently enables teaching.
7. Spare/farmed manuals can be sold without deleting archived knowledge.
8. Combat farming produces real special loot; returning deposits it into the correct personal/sect stores.
9. Fragment crafting consumes the required fragments and produces exactly one manual.
10. Learning requires archive + contribution + personal spirit stones and transfers the stone fee to the sect.
11. The 3-technique learning cap is enforced.
12. Matching elemental affinity measurably improves mastery.
13. Mastery stops at threshold; upgrade requires/consumes materials and advances one level.
14. Active techniques measurably affect cultivation, breakthrough, combat power and/or defense according to their data.
15. Save/load preserves sect technique economy, root elements, learned techniques, active technique, mastery, Contribution and personal spirit stones.
16. Same-seed continuation remains deterministic.
17. P0 money conservation and all earlier invariants remain green.
18. P2.3 interaction scene launches under Godot 4.7.2.

Authoritative command: `Sync-P2-3.cmd`.

Expected final markers include:

- `P2.2 SPIRITUAL ROOT + GROWTH CONSEQUENCE GATE: PASS`
- `P2.3 TECHNIQUE ECONOMY + MASTERY CONSEQUENCE TEST PASS`
- `P2.3 TECHNIQUE ECONOMY + MASTERY CONSEQUENCE GATE: PASS`
- `P2.3 GATE: PASS`

## P2.3 exclusions

P2.3 does not add fixed character classes, multi-technique simultaneous stacking, combat skills/individual moves, master-disciple teaching, pills, equipment, special physiques, tribulations, secret realms, bosses/factions, premium/real-money gacha, pity/banner systems or combat-team V2.

## Completion status

- P0: PASS / LOCKED.
- P1.1: PASS / LOCKED.
- P1.2: PASS / LOCKED.
- P1.3: PASS / LOCKED.
- P1.4: IMPLEMENTED / AWAITING RUNTIME GATE.
- P1.5: IMPLEMENTED / AWAITING RUNTIME GATE.
- P1.6: IMPLEMENTED / AWAITING RUNTIME GATE.
- P2.1: IMPLEMENTED / AWAITING RUNTIME GATE.
- P2.2: IMPLEMENTED / AWAITING RUNTIME GATE.
- P2.3: IMPLEMENTED / AWAITING RUNTIME GATE.

Runtime verification for P1.4–P2.3 is intentionally deferred until the user returns to the Windows/Godot 4.7.2 machine. Do not mark any pending phase PASS before a real `Sync-P2-3.cmd` run completes successfully.
