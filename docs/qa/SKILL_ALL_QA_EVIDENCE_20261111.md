# SKILL-ALL QA — PR #72 (11/11/2026)

## Kết quả

- PR branch: integration/pve-p0-playable-ui-20261103.
- Code fix SHA: [9242ded8acc3e0123a07207bae4b188e065126b5](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/9242ded8acc3e0123a07207bae4b188e065126b5), parent 917a7668037133235157ef03ccea26f804d1f54b.
- Engine: Godot 4.7.2.stable.official.ed1daf0bf; executable SHA-256 AB1824F85BFD8E0E4128182C000C4003A3E042245B2967848D089B2A04B22424.
- Tests ran sequentially, isolated profile under QA checkout. No player save/default save opened or written. SaveService unchanged.
- Import and parse of changed lab script: exit 0.
- Focused Poison V4/VFX regression: 16/16 exit 0 on code SHA above.
- Catalogue/school/PVB1 runtime group: 8/8 exit 0 on code SHA above. Additional exact-SHA checks: V63 D6 mastery/snapshot 1/1, legacy P2.3 and P2.5 2/2, SaveService async roundtrip 10 checks exit 0.
- A broader 38-test local overlay also returned 38/38 exit 0. That run happened before the code commit and its worktree contained unrelated local test/import metadata changes; it is **supplementary overlay evidence, not an exact-SHA claim**.

## Exact-code-SHA matrix

Detailed markers and raw stdout/stderr are in [the evidence directory](../../godot/outputs/qa_evidence/skill_all_9242ded8_20261111/).

| Gate | Result |
|---|---|
| Godot 4.7.2 headless editor import | PASS, exit 0 |
| Parse modified combat_lab.gd | PASS, exit 0 |
| Poison V4 layer/art/VFX/tooltip/render/growth/range/status/AOE/cinematic + VFX08 + DV2-02 + V65 | PASS, 16 tests, all exit 0 |
| 549-ID catalogue integrity | PASS, 549 unique IDs, 105 families, 9 branches |
| Cung / Quyền / Độc matrix | PASS, 183 records per school |
| PVB1 poison rule matrix | PASS, 1,475 Godot checks, zero failures |
| PVB1 6v8 MapBattleV2 fixture | PASS, 40 simulated seconds; 87 casts, 1,047 hits, 558 status ticks, 30 consumes, 5 spreads, 4 downs; not live PvE |
| Poison 21 profiles + all-school 63 profiles | PASS, 42 + 126 normalized trials; not real DPS/balance acceptance |

Combined matrix: combined_matrix.csv (30 exact-code rows). Exact runtime matrices: matrix.csv and runtime_matrix.csv. Raw Godot stdout/stderr: logs/ (16 tests), runtime_logs/ (11 tests), SaveService async and import/parse logs. Each matrix row has code SHA and official engine version.

## Inventory and measurements

- [SKILL_ALL_ID_AUDIT.csv](SKILL_ALL_ID_AUDIT.csv): 564 rows, 564 unique IDs; 549 V6.3 plus 15 legacy/technique records. Includes raw source JSON and per-row normalized SHA-256. SHA-256: A5F1502524FF720D23B12E336789D6F725D3D093EBB9535A5DE72800F5AA1D88.
- [SKILL_ALL_NORMALIZED_MEASUREMENTS_20261111.csv](SKILL_ALL_NORMALIZED_MEASUREMENTS_20261111.csv): 168 fixed-seed engine-fixture trials. Measurements were captured on parent 917a766 before the tooltip/test-only commit; combat simulation sources did not change in 9242ded8. SHA-256: 67897CCD7AA5A0511D411C8D09C6AFBDE693A1BC31368C990D328E6F1B573519.
- Source SHA-256 manifest: [SOURCE_MANIFEST.csv](../../godot/outputs/qa_evidence/skill_all_9242ded8_20261111/SOURCE_MANIFEST.csv).

## Root cause and repair

Canonical source defines Bách Độc Tán Châm radius 2.8 and target cap 3, while an old lab contract expected radius 3.0. Vạn Linh Giải Ách is a bounded AoE heal (radius 2.5, cap 3); Giải Độc Hộ Tâm is the single-target heal (range 6.5, cap 1). These are stale test assumptions, not a Combat V2 defect. The lab tooltip had a hardcoded radius 3; it now reads radius and target limit from the canonical skill definition. No assertion was removed.

## Pending gates and environmental note

- GitHub Actions and combined status for 9242ded8 returned no workflow/status entries at evidence capture: **CI PENDING**, not PASS and not a gameplay failure.
- Production SaveService cold-process preservation of active PVB1 owner/tick/heal-budget receipts was not separately exercised. The V65 test verifies MapBattleSnapshot save/load and tick/event idempotence; the 1,475-check PVB1 test exercises bounded mechanics and in-memory serialization. **PENDING dedicated SaveService integration evidence.**
- Full V63 mastery/cast progression across all users has not been demonstrated in live GUI; D6 headless covers the tested rare-successor cast receipt and anti-replay only. **PENDING broader gameplay acceptance.**
- Physical Windows mouse GUI at 1280×720, real combat/VFX capture, Android device play, and owner visual acceptance: **PENDING**.
- All V6.3 feature gates remain OFF by default; candidate balance was not approved or enabled.
- Godot stderr contains the Windows warning “Failed to read the root certificate store”; import and tests still exit 0. It is recorded rather than suppressed.
- The V63 VFX manifest has asset_files empty; live runtime uses generic vector event cues. No per-skill source art was claimed.

These results close only the stated headless checks. They do not constitute public V6.3 release, real PvE balance, GUI, or Android acceptance.