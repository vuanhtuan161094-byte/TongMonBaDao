# TÔNG MÔN BÁ ĐẠO — DẪN TIÊN C2 / D7 UI + P0 implementation checkpoint

Date: 2026-11-01. **CODE COMMITTED / GODOT 4.7.2 NOT RUN / GUI NOT CAPTURED / MERGE BLOCKED.**

Baseline: ONE GAME \`integration/one-game-v65-20261030\` at \`199f888c7fd690830728dfbf29b6b79276e3b283\`.  
Implementation branch: \`feature/dan-tien-c2-ui-p0-20261101\`, includes proposal \`docs/design/DAN_TIEN_C2_D7_RECRUITMENT_PROPOSAL_20261101.md\`.  
No code changes in \`main\`, PR #52, SX #57, SX #58 or SX #59. No owner saves touched.

## Implemented in candidate code (not accepted/tested yet)

1. \`godot/src/presentation/dan_tien_screen_v2.gd\`: real Control modal (approximately 1170 × 656 at 1280 × 720); search, quality filter, 6 applicant cards/page, profile, grade, seven numeric D7 attributes, roots, visible profession grades, discovered-only special identities, UI feedback, capacity preflight, two-stage reject confirmation, paid order preflight, escape/close and live signal to parent.
2. \`godot/src/presentation/dan_tien_d7_radar.gd\`: one radar canvas with independently normalized Tam Căn triangle and Tứ Tính quadrilateral; read-only display. **Visual exactness must be verified with screenshot; not an HS09 chart replacement.**
3. Replaced narrow original candidate list in \`p3_2_landscape_sect.gd\` with a launch button and queue overview. Modal actions use existing \`RecruitmentSystem\` authority, returning roster map refresh to existing scene.
4. **Source A:** modal calls \`DiscipleSourceAVisualPool.scene_path_for_disciple\` / \`scene_for_disciple\` on an applicant-derived read-only DiscipleState and displays the verified scene's first \`stand\` frame. Per-scene cache avoids repeated sprite decoding. If registry entry, source asset or stand frame unavailable, the UI explicitly says no suitable Source A portrait; no AI/generated or unknown-license asset was added to repository.
5. \`p3_7_factory.gd\`: New Game initial applicant V2 birth layers are populated deterministically from existing \`profile_seed\` / generation index and validated BEFORE LiveGameRuntimeV2's V2 recruitment gate. No current D7 or applicant's existing identity fields rerolled; code works only when creating NEW state, not by automatically rewriting existing saves. Profession talent layer is synced after Workforce profile setup.
6. \`recruitment_system.gd\`: technical queue cap **30 candidate objects**; existing overflow retained, new free arrivals pause at cap; paid Chiêu Mộ Lệnh rejects BEFORE debit when full, including after new-day snapshot. No new pity, currency or quality rates introduced.
7. Guide assignment UI: choose main/assistant from roster with authority check for injury, busy work, timed recipe/plot, PvE and body reservations. \`RecruitmentSystem\` now owns this validation for new assignments. Main guide's Mị Lực/day-odds and assistant visitor bonus require continued eligibility on snapshot day; a working disciple is not automatically reassigned.

## Open balance/UX policy for owner

- **Candidate cap of 30 is a technical safety candidate, not final approved player balance.** Before merge, approve/change it with pacing data. When full, free day-scoped arrivals are skipped; already generated applicants, paid orders and existing overflow are never deleted. No retroactive or accumulated free daily backlog.
- New Game starter roster capacity remains 8 with 6 initial disciples; a third accepted applicant still needs expansion. Do not change cap without approval.
- Existing odds table (65/25/8/1.8/0.2; enhanced 35/25/20/15/5) is unchanged; no pity is inserted. Source-A mapping requires actual installed source pack.
- C1 six-dimensional legacy text is retained as historical; D7 proposal is not yet the master spec without owner balance decision.
- Existing saved legacy applicants with incomplete V2 identity remain untouched and may be un-recruitable pending a carefully audited, deterministic migration. This code repairs **fresh New Game**, not every historic save.
- Only already-revealed special identities are shown. This is a visibility implementation, not activation of latent Bloodline/Destiny/Physique consumer effects.
- UI is a full-screen modal reached via a real building button; not an offline HTML mock. No screenshot exists yet.

## Static source review

- New C2 scripts are self-contained, and integration refers to \`DanTienScreenV2\` by class_name.
- All roster changes, paid orders and assignment changes invoke existing \`RecruitmentSystem\`; no second SaveService, queue or inventory exists.
- No test result is asserted as PASS here. Godot editor import/parser, runtime smoke, unit regression, GUI screenshot and FPS all **NOT RUN** in this environment (Godot executable unavailable).

## QA gate that must run before code is accepted

Official Windows **Godot 4.7.2** isolated checkout (NOT the owner's dirty live worktree):
\`\`\`powershell
godot --headless --path . --editor --quit
godot --headless --path . --script res://tests/dan_tien_c2_smoke.gd
\`\`\`
(from the repository's \`godot\` directory, with the exact official executable path resolved locally).

The new \`dan_tien_c2_smoke.gd\` checks: initial candidate complete V2 birth, first acceptance preserves exact birth layer, 100 simulated days queue never exceeds cap, order at full does not debit, and Godot UI modal construction. It is **written but NOT RUN**. Follow with historical recruitment/State/SaveService, Injury120, Workforce, HS09 radar, 6-person PvE and Save/Return/Reload suites, using the exact implementation SHA.

Real GUI 1280 × 720 acceptance:
- Open New Game, select Dẫn Tiên, enter modal; confirm 3 initial candidates are recruitable (or record a precise failure).
- Inspect Source A texture for male/female candidates; frame looks authentic and properly cropped; no hidden trait leak or GUI clipping.
- Scroll/page 6 candidates, search/filter, inspect D7 root/profession, change Main/Assistant (eligible only), validate odds snapshot day delay.
- Accept one with exactly-once roster appearance; reject with 2-step confirmation; full queue prevents paid debit; locked capacity informs the player.
- Save/Return/Reload plus offline catch-up checks seed/IDs/birth, token count, candidate queue, main/assistants, receipt and day counters.
- Profile memory and FPS on Windows 8GB, with queue sizes 3/30 and combat underlay, not one idle sample.

**Status:** Feature candidate ready for compile/QA **only**, no runtime PASS, no release, no merge until exact source SHA and owner review.
