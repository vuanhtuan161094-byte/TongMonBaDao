# TÔNG MÔN BÁ ĐẠO — DẪN TIÊN C2 / D7 Recruitment Design & Integration Gate

**Status: PROPOSED / OWNER REVIEW REQUIRED — NOT CODE APPROVED.**  
Checkpoint: 2026-11-01 (Asia/Bangkok).  
Authoritative inspected baseline: `integration/one-game-v65-20261030` at `199f888c7fd690830728dfbf29b6b79276e3b283`.  
This document is a proposal and gap/QA plan, **not a gameplay PASS, balancing approval, migration instruction, or merge authorization**.

## 0. Intent & ownership

Make New Game → Dẫn Tiên → inspect candidate → accept/reject → roster → assignment → production/training/PvE an actual deterministic, bounded, save-safe gameplay loop. Do not silently rewrite existing save identities or merge the unrelated Draft SX PRs (#57/#58/#59). Retain ONE GAME single state authority, one active job per disciple, injury gate, SaveService and durable receipts.

Sources inspected: `godot/src/simulation/recruitment/recruitment_system.gd`, `godot/src/simulation/recruitment/disciple_generator_open_points.gd`, `godot/src/simulation/recruitment/disciple_birth_roll_v2.gd`, `godot/src/simulation/core/p3_7_factory.gd`, `godot/src/simulation/core/live_game_runtime_v2.gd`, `godot/src/presentation/p3_2_landscape_sect.gd`, and legacy `docs/P3_7C1_FOUNDATION_DAN_TIEN_SPEC.md`; all at the baseline commit.

## 1. As-is source behavior (NOT newly approved balance)

| Topic | What code does |
|---|---|
| Ordinary visitors | Dẫn Tiên Lv1: 5 candidates per 1,440 simulation ticks (= 1 simulated day). Base `5 + 3 * floor(level/10)`, prior to assistant modifier. |
| Chiêu Mộ Lệnh | New Game has three; spending one creates an additional candidate, refunds only if generation fails. Accept/reject does not spend another order or Linh Thạch. Repeatable order source not proven. |
| Quality odds | Basic: Phàm 65%, Xuất Chúng 25%, Thiên Kiêu 8%, Tuyệt Luân 1.8%, Nghịch Thiên 0.2%. Max charisma-table: 35%, 25%, 20%, 15%, 5%. Interpolate via `clamp(charm/2500,0,1)`. |
| Enhanced rare cap | `ceil(charm/625)` enhanced Nghịch Thiên outcomes per simulated day, then revert to basic odds; **not** a guaranteed rare count or pity. |
| Assistant | Every whole 500 Mị Lực of each assistant adds 1 ordinary candidate/day. Assistant slots = `clamp(1+floor(level/20),1,6)-1`. |
| Accept | Must have roster capacity, candidate ID and complete V2 birth when V2 is enabled. Newly accepted V2 disciple starts Phàm Nhân tầng 1 / Phàm Thân tầng 1, 0 EXP. |
| D7 | Tam Căn: Tư Chất/Căn Cốt/Tâm Tính. Tứ Tính: Tiềm Lực/Thông Tuệ/Cơ Duyên/Mị Lực. Birth quality chooses D7 budgets; later quality label is derived from current values via `6/7` scale. |
| Special identity | Linh Căn, Dị Căn, Đặc Chất, Huyết Mạch, Thể Chất, Mệnh Cách have independent birth domains. Identity presence does not establish active gameplay effects. |
| UI | Candidate list renders every entry; card exposes six dimensions but omits Tâm Tính, Linh Căn details, profession grade and protected reveal data. |
| Current initial state | Six starter disciples, initial roster cap 8, three pre-created candidates/three orders per prior source audit; verify new-game fixture on exact implementing SHA. |

D7 does **not** yet have all seven live consumers. Tâm Tính has no proven runtime consumer; Tiềm Lực has a math helper but should not be claimed to scale final combat stats unless a real consumer and focused test exist. Profession talent birth paths/grades need unification. No new effects are authorized by this document.

## 2. Critical audited defects / blockers

**P0 — New Game candidate completeness:** `P37Factory.create_state()` creates its `P212Factory`-derived state and candidates before `LiveGameRuntimeV2._configure_live_state()` sets `disciple_v2_birth_enabled=true`. UI and `RecruitmentSystem.accept_candidate` reject candidates with incomplete V2 birth. A fresh New Game can therefore present 'Hồ sơ cũ' blocked candidates. Fix by a defined new-game construction order, OR a deterministic, provenance-backed completion of initial candidates. **Do not silently reroll names, identity, D7, seed, quality, or traits.** This is code-path evidence, not GUI reproduction.

**P0 — Unbounded candidate queue:** `_begin_guidance_day` loops the entire day's target, stores profiles in `state.recruitment_candidates`; UI loops all IDs and instantiates all cards. This risks growing saved state and GUI work without limit. Performance impact is not yet benchmarked.

**P1 — Inadequate assignment validation:** the main/assistant guide setters check roster IDs and assistant slots, but not all injury, PvE, busy/job and workforce conflict conditions. Avoid silently moving working disciples.

**P1 — Incomplete user decision:** recruitment inspection and comparison are limited; a candidate's full D7 and discovered profile are not visible at decision time. New Game capacity 8 with 6 initial disciples permits only 2 of 3 waiting candidates to join before capacity growth.

## 3. Proposed C2 decisions (OWNER approval pending)

**C2-01: Adopt D7 as the current canonical foundation spec.** Mark C1 six-dimension text superseded for *new* mechanics only. Maintain immutable birth snapshots and historical saves; do not overwrite earlier provenance. Show both birth quality and dynamically derived current quality only when model ownership is explicit. Preserve current probability and D7 budget tables pending balancing.

**C2-02: No pity yet.** Keep current odds and enhancement quota, clearly show odds and identify that the rare cap does not guarantee a rare. Revisit pity only when Chiêu Mộ Lệnh has a priced, renewable, auditable source. No extra currency, no guaranteed Nghịch Thiên, no multi-draw purchase invented.

**C2-03: Queue bounded with paging.** Suggested candidate cap (PROVISIONAL): `Q(L)=min(30, 12+2*floor(L/10))` for Dẫn Tiên Lv1–100 (Lv1:12, Lv20:16, Lv100:30); six compact candidate rows/cards per page. Code must preserve any pre-existing saved overflow rather than deleting it. No paid order debit when full. No duplicate generated ID or applicant profile after Save/Reload. Need performance measurement before final cap values are locked.

**C2-04: Daily visitors as bounded availability, not instant unbounded generation.** Generate at most free queue slots each day; persist remaining *same-day* visitor allowance and deterministic generation index; optionally refill slots upon accept/reject that same day. On day rollover, do not materialize unlimited historic visitor backlog. Exact expiry/defer policy for unused **free hypothetical** visits is OPEN and must be shown in UI; never discard an already generated candidate, a paid order or an earned receipt. Catch-up/offline and day-boundary tests must precede implementation.

**C2-05: New Game profile repair, versioned and deterministic.** Prefer ensuring V2 birth authorization **before** initial candidate generation. Existing saves get no automatic blanket reroll. A migration may fill *only* missing V2 fields if envelope/domain seeds and provenance are verified; compare all pre-existing fields byte/semantically before and after. If proof is insufficient, keep candidate visible with explicit incompatibility and a safe user option; never silently exchange it for a random new candidate.

**C2-06: Decision-oriented UI.** Compact list: name / derived grade / D7 strengths / key discovered root / profession best-fit / age / recruitability. Expanded details: seven numeric values, Tam Căn–Tứ Tính **one nested radar with separately normalized axes**, Ngũ Hành purity, awakened special identity, visible profession talent grade, cultivation paths, actual learned technique (if any), recruit vs reject. Do NOT indicate which candidates hold hidden Bloodline/Physique/Destiny merely by rendering a 'latent exists' badge. Use generic 'not discovered' where relevant; no information leakage. Comparison of two selected candidates is a future P1 feature.

**C2-07: Guide job conflicts.** Main/assistant assignment must validate roster membership, injury/PvE status, active job and access. If another role is active, show conflict/impact and require a separate cancel/reassign confirmation; no automatic takeover. Document when a replacement affects daily odds (next simulated-day snapshot). Respect one active job per disciple.

**C2-08: Starter capacity is a separate owner decision.** Current 6 founder + cap 8 + 3 waiting cannot accept all three immediately. Suggested early-game cap 10 for flexibility, but this **must not** be changed merely to green a test; compare with 9 (minimum to accept three) and progression economy before approving.

**C2-09: No phantom mechanics.** Birth trait, profession grade, roots and identity buff are *data* until the corresponding consumer has a passing test. No double counting in ATK/DEF/HP, XP or elemental damage. Do not add extra costs for accepting a candidate without a signed-off ledger.

## 4. User journey definition of done

1. Start New Game with 6 founders, 3 orders and valid starting candidates (no 'Hồ sơ cũ' blocker); all initial candidates have deterministic complete birth under the selected new-game contract.
2. Browse a paged list, inspect complete *discovered* D7 and profile. Capacity/recruitability/odds are visible; hidden identities stay hidden.
3. Accept one candidate: exactly one roster member appears with the same ID/profile and V2 level/tier 1, zero XP; capacity decrements exactly once.
4. Reject one candidate: no roster mutation, no refund of a previously spent order, no copy of the removed candidate later.
5. Spend an order: exactly one receipt, one candidate and one order charged; full queue prevents debit.
6. Day advances / offline catch-up: never materialize unbounded UI cards, duplicate candidates or bypass seed/probability state.
7. Assign guide: one-active-job, injury, PvE and snapshot-day constraints hold.
8. Save → close → reload → same candidate IDs, D7, birth hashes, orders, counters, queue, daily allowance, main/assistants and current roster; repeat Save/Reload has no second-generation or second-debit.
9. Android landscape 1280×720 remains visually usable; real screenshot/mouse/touch evidence recorded separately.
10. Any trained/crafted/looted career effect must be tested in its own consumer chain; do not claim completeness by catalog inspection.

## 5. Suggested implementation gates and test fixtures

| Gate | Minimal source owner | Test and acceptance |
|---|---|---|
| R0 audit | Recruitment + Factory + Birth + Save | Baseline New Game fixture, V2 validation, isolate both defects, exact SHA and reproducible logs. |
| R1 P0 birth | `P37Factory`, `LiveGameRuntimeV2`, generation envelope | 100 seeds: starter candidate validation, no forced reroll, first recruit can join; legacy Save A/B must stay semantically identical without explicit migration. |
| R2 P0 bounded queue | `RecruitmentSystem`, `BuildingState.production_state`, UI | Lv1/Lv20/Lv100, day roll/negative ticks, overflowing legacy queue, 100 simulated days, 0 duplicate/debit loss, deterministic Save roundtrip. |
| R3 UI/profile | `p3_2_landscape_sect.gd`, HS-09 design reference | Six cards/page, 1280×720 mouse/touch, no hidden trait leak, exact numeric vs profile data. |
| R4 job & UX | Recruitment + Workforce/One Active Job | busy/IDLE/PvE/Injury, valid replacement confirmation, no silent cancellation. |
| R5 full loop | New Game → recruit → assignment → production → V2 cultivation → Save/Reload | Official Godot 4.7.2 headless import/focused QA **and real GUI**; record startup RAM/FPS at idle and 30+ queue, not a single idle sample. |

Acceptance criteria are proposals; **no tests were run or production code changed** when this document was authored. No SX #57/#58 merge, balance alteration, migration of old saves or release tagging without separate review.

## 6. Owner decisions still needed

1. Approve D7 as replacement to six-dimension C1 specification; decide whether historical C1 document gets marked superseded or is kept as archived baseline.
2. Approve **no pity for C2**, or request a separate paid-only pity economy specification.
3. Approve queue cap formula and what unused *free* daily allowance does at the next simulated-day boundary; ensure no already-generated or paid candidate is lost.
4. Approve deterministic new-game birth order fix and conservative legacy migration policy.
5. Choose whether starter roster capacity stays 8 or changes (suggested 10) after early-game pacing evaluation.

Once approved, implement as isolated PR with SHA-bound tests and real QA. Avoid bundling with broken SX-01/SX-02 Drafts.