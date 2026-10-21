# TÔNG MÔN BÁ ĐẠO — BỐN GÓI REVIEW / QUYẾT ĐỊNH TÍCH HỢP (22/10/2026)

**Trạng thái:** OWNER REVIEW / DESIGN-ONLY / NO CODE / NO MERGE / NO PUSH OTHER BRANCHES  
**Căn cứ:** Bốn ZIP do owner đính kèm cuộc hội thoại 22/10/2026, được kiểm tra trực tiếp nội dung. Không chạy Godot lại; không thể đọc trạng thái dirty worktree Windows hiện tại. Đặc tả B3 V2 ở nhánh `docs/b3-v2-architecture-redesign-20261022` là mục đích dùng tiếp, không phải giấy phép coding.

## 1. Integrity và tình trạng đáng tin

| Gói ZIP đã nhận | SHA-256 ZIP đã tính | Nội bộ ZIP | Kết luận đúng |
|---|---|---|---|
| `TMB_SALIB_OVERNIGHT_REVIEW.zip` | `6c17cfb99721be3a17537bfd5614a533d70895ade449f34aa94b30ffe7f951d0` | CRC PASS; **349/349** checksum nội bộ khớp | Converter fingerprint `54b0575661a2384e13595eefb3d327e2bc7b29d417329a29814ac481b25839b1`. 36 current PASS (35 FAST, 1 FULL), 1 current FAIL, 10 alias. |
| `TMB_B2_4_HUNT_LOOP_REVIEW.zip` | `29b2e6fa11932c94abac054b48cbd9440c63473079472dabcee0be2605fea422` | CRC PASS; **84/84** checksum đóng gói khớp | B2.4 sandbox focused QA báo PASS, demo opt-in 6 synthetic actors, cloned Warehouse, no SaveService. Không đồng nghĩa production. |
| `TMB_CHARACTER_STUDIO_V2_REVIEW.zip` | `719d1a00f844c87ccae0b26c56feab4cf3610bbe377a52904c2ea75ef7abe9d2` | CRC PASS; **49/49** checksum gói khớp | Addon Editor focused PASS. 6/7 rig verified, 22/42 rig×clip verified; female rig SHA mismatch chưa giải quyết. |
| `TMB_V5_1_VISUAL_FINAL_REVIEW.zip` | `9c57d930492343388594e0543aadd588793223b61ded285b506852219e5c7294` | CRC PASS; **216/216** file checksum đóng gói và **48/48** runtime asset checksum khớp | V5.1 official focused/capture evidence PASS, **owner visual PENDING**; 3 regressions có cùng FAIL signature trên base/V5, chưa xác thực tích hợp. |

**ZIP count caveat:** V5.1 ZIP có **234 entries gồm 17 directory placeholders, 216 payload file được hash và 1 SHA256SUMS.txt**. README nói 217 entries là đếm file, không phải bằng chứng mismatch.

### Status Source A thực tế
- 5.328 READY nguồn; **36** PASS current-fingerprint, **1** FAIL, 10 duplicate alias, **5.273 BLOCKED_RESOURCE_LIMIT chưa thử**, 8 historical ready chờ refresh; 9 historical QA của converter cũ không được cộng vào 36.
- 1.250 REVIEW nguồn, trong đó 1.248 pending phân loại exclusive **914 parser/161 atlas/group/173 texture/page**, có overlap flags. Không chạy bulk repair 914 parser trên máy 8 GB trước khi triage representative samples.
- Rig `2123019_10` crop ở 768; bản skin 12 lựa chọn **1536x1536 FULL PASS** (1024/768 FAIL crop). Không hạ canvas/tự sửa hash để ép xanh. Next READY candidate `1111204_1_s`; command recorded `sourcea_library.py --config library.local.json resume --limit 4 --qa-mode fast` với **resource gate** và single worker.
- Converter output HAS NO guarantee all 36 rigs include combat `stand/walk/attack/hit/dead`. 36 conversion PASS là kỹ thuật conversion, **không phải 36 actor ready gameplay**.

### Status B2.4 thực tế & nuance so với GitHub main
- **GitHub `main @ 461caca`** vẫn finite `MapBattleV2 MAX_SECONDS=90`, WIN-on-empty, 1-encounter snapshot v1 và reward per encounter.
- **B2.3/B2.4 ZIP source_snapshot** chứa **thay đổi CHƯA COMMIT/PUSH**: `MapBattleV2.continuous_mode` opt-in, spawn/remove individual monster, no WIN-on-empty/90s when continuous, external damage tick adapter, world-ish pilot SpawnDirector, per-kill ledger IDs, snapshot v2 reader also v1. Đây là **code cần kế thừa**, không viết lại từ số 0.
- Còn thiếu để thành B3 production: canonical world ownership/time/AI teams, save service transaction/schema, direct real per-kill loot table, personal growth/unique gear, runtime Map/Studio bridge, multiplayer-team Boss single HP/participation, official integrated compatibility tests.
- **Technical caution:** sandbox event tracking scans `battle.events` by cursor, compacts near MAX_EVENTS; production kill authority nên đọc immutable death transaction từ Combat V2 lifecycle, không phụ thuộc presentation ring-buffer. B2.4 runtime `run_steps` chỉ phục vụ demo, không phải 1-hour production.
- Test-only loot `100% linh_moc` in clone must **never** become live drop. Native Editor dock interaction QA PENDING. Synthetic DoT adapter != Combat V2 periodic DoT skill implemented.
- B2.4 local HEAD `461caca`, 5 dirty tracked inherited B2.3 + 32 untracked per report; do not cherry-pick FULL project or claim Git branch is remotely available. Preserve ZIP and patch before integration.

### Character Studio
- Local branch `feature/dev-character-studio-v2`, **commit `18bf8929...` LOCAL ONLY**; no push or merge. One separate dirty Verify-P3-6A script not part of task.
- 7 actor rig records, 6 verified, 1 UNVERIFIED `1113028_1`; `actor.tscn` and `animations.tres` SHA mismatch from V5 manifest, `asset.json`+atlases match. **Do not rewrite checksums to manufacture PASS**. Determine source provenance and regenerate/reconcile honestly with targeted evidence.
- Verified female combat `attack1/hit/dead` separate from base female `stand/walk` unverified; **no verified composite**. 42 combinations: 22 VERIFIED, 2 UNVERIFIED, 18 MISSING. No proven layerable Source A outfits. Skills active 4 slots, role modifiers, birth profile completeness, Accuracy/Evasion, visuals of gear remain **DESIGN-ONLY**.
- Studio independently supports sandbox preset v2, read-only stat preview, original verified rig playback, 8 real editor PNG evidence; not gameplay character birth integration.

### Combat V5.1 visual (inspected evidence PNG)
- Local branch `feature/v5-1-sourcea-visual-finalization`, HEAD `ae3f397...` **uncommitted/dirty**. Do not merge or push without owner instruction.
- Improvement: less dark diagonal tile edges, foot shadows, selected HUD/target feedback, pan+zoom+explicit follow/deselect/reset signal. Event-based damage/death/telegraph. V5 uses Source A actor slots and JX skill VFX.
- Open visual debt confirmed by real PNG: six disciples **overlap**, HP/nameplates tough to associate; Boss red telegraph overlaps actor silhouettes; repetitive bright stone pattern remains; `410041_1` is **unverified Boss identity**. GIF at 2fps cannot prove real motion smoothness; explicit button reset mouse click remains pending physical check.
- V5.1 QA 32 capture frames in 16s at 1280x720; measured average 14.655 ms/frame, p95 21.717ms **including capture**; final observed 20FPS is not a phone benchmark. No OWNER VISUAL PASS.
- Three regression failures **both base and V5 with same signature**: One Active Job, Hunting UI smoke, GP-02C1 T15_PLANT; cannot declare integrated PASS. B2.4 GP-02C1 PASS uses **different HEAD/test SHA**, so evidence is **NOT COMPARABLE** until identical test bytes and sandbox config.

## 2. Next-work priorities, independently scoped

### P0 — Preserve and freeze evidence; no merge
1. Keep all four ZIP intact with hash, patch/diff and local commit IDs; record that B2.4/V5.1 are dirty local modifications, Character Studio commit local only, Source A outputs live on E drive.
2. Get MAP workstream fresh named handoff when available. **No Map-specific ZIP was among these four**; V5.1 combat scene != confirmation MAP25 workstream is fully accepted.
3. No automatic marking PASS/closed, no deleting dirty or untracked files to clean Git, no overwriting `CURRENT_CHECKPOINT.md`/`NEXT_CHAT_HANDOFF.md` by copying entire ZIP.

### P1 — Highest return: B2.3/2.4 → B3 world production contract review
- Reuse *actual opt-in continuous mode* already present in B2.3 snapshot, not a new combat formula or totally separate world engine. Read `source_snapshot/godot/src/simulation/combat/{map_battle_v2.gd,map_battle_snapshot_v2.gd,spawn_loot_runtime_pilot_v1.gd,kill_receipt_ledger_v1.gd}`.
- Before any CODE, author one **integration packet** with parent SHA/current branch, detailed allowlist, current dirty diffs, one code writer, v1/v2 snapshot parser bridge, rollback, canonical SaveService, per-monster HP0 event, actual source ID, one packet focused tests.
- First production acceptance fixture: **one existing real canonical disciple/team + one real monster source** in a **persistent zone >90s**, no reset/wave, one kill receipt, zero synthetic loot, canonical save/reload; offline/backlog separately gated. Do not jump to 3 zones/5 recipes as product cap.
- Important technical issue: v2 snapshot parser old V5 may not read newer wrapper; ship reader/writer together. Union `project.godot` plugin arrays when integration authorized; do not replace whole file.
- Scope gate: B2.4 only informs B3, never promotes 100% synthetic `linh_moc` as actual table.

### P2 — Source A usable combat actors / Character Studio mapping
- Continue SA single-worker **small batch 1–4 READY** under RAM/CPU gate; FAST checksum/manifest default, 1 sample FULL/visual after code/converter changes; SKIP same fingerprint. If gate red, triage metadata only; never force RAM 8GB machine into unsafe bulk conversion or overwrite originals.
- More valuable than indiscriminately processing 5.273 ready: curate actual **male/female disciple (all essential clips), normal mob, Elite/Boss candidate** packs with stand/walk/attack/hit/dead, source provenance, canvas/pivot/foot, known mapping to Studio and Combat V5. Record source `rig_id, clip_id, actor_kind, verified_status, manifest hash, asset_pack_rev`.
- Resolve female `1113028_1` SHA conflict on two files by matching manifest to **approved reproducible source** after reviewing why scene/tres bytes changed; no blind hash update. Keep standalone known-good attack/hit/dead separate until composite proof exists.
- Do not spend effort creating outfit compositor without actual layerable source proof. Studio external catalog/pack tool is independent, should consume SA verified current packs on demand instead of opening all 6,578 assets.

### P3 — Visual review V5.1 (owner-facing UX)
- **Do not mark owner PASS yet.** Only targeted visual changes if owner requests: readable nameplate/HP anchored to actor and selective label suppression for crowding (without fake actor displacement); Boss telegraph under silhouettes/transparent enough to reveal actors, unchanged Combat V2 hazard; reduce repeating ground texture while keeping source style.
- Verify actual reset button input and more than 2fps motion capture; identify boss-slot asset source before calling it canonical Boss.
- Avoid changing battle kernel/respawn/payout to solve visual defects, and do not move sprites' gameplay foot XY to fake spacing.
- Native visual acceptance should wait on owner review of before/after frame and short high-fps recording; no need to reopen full suite now.

### P4 — Integration only after conflicts/gates resolved
- One clean isolated integration worktree/branch **after explicit owner CODE authorization**, one writer touching `SimulationState/SectState/SaveService/Workforce/Combat`.
- Reconcile: B2.3 finite-vs-continuous battle world kernel, snapshot v1/v2, V5 world-layer presentation, both addons' plugin registration, shared checkpoint docs manually, Character Studio rig manifest, Source A chosen pack versions.
- Run exact SHA/byte-identical focused tests across base and integrated checkout, map/background render and new continuous 90/180/3600s tests, save + ledger crash/restart/idempotence, One Active Job/GP-02C1/old PvE fixtures.
- If GP-02C1/T15_PLANT still fails in integration, record blocker or isolate with explicit accepted unrelated debt; never call it PASS based on different checkout evidence.

## 3. Critical path / no overlapping Codex edits

| Independent worker (when asked) | Allowed follow-up | Forbidden overlap |
|---|---|---|
| B3 design/QA researcher | Detailed integration plan and contract using real B2.4 ZIP, offline/AI/design only | No actual Save/Combat code until packet authorization |
| Source A converter | Continue safe conversion/categorize review, curated actor packs | No studio/V5/project files or forced conversion under low RAM |
| Character Studio maintainer | Rig SHA provenance, clip mapping, import proof/read-only GUI | No Source A raw converter or gameplay birth systems |
| V5 visual maintainer | Visual readibility/camera/UI/VFX evidence when owner chooses | No damage/loot/Save/AI or fixing regressions outside owned paths |
| Map owner | Existing Map stream according to its own handoff/approval | No B3 or Studio files until explicit integration owner |
| Future integration owner | Single writer on shared code after allowlist and verified parent | Never cherry-pick whole dirty branch/unverified zip or merge without owner |

## 4. Owner-facing plan

**Now:** Save all 4 artifacts and their status. B3 design on GitHub proceeds independently. **Next:** request one **read-only B2.3/B2.4-to-B3 integration packet**, not runtime patch, using B2.4 ZIP as source. Parallel: Source A curated 1–4 rigs when machine available, Character Studio SHA fix only with evidence, V5 visual review patch only after owner chooses. Keep Map separate. No merging until single-authority/legacy migration/visual gate.

**Do NOT confuse these:**
- Asset source READY (5,328) != converted current PASS (36) != full combat-ready rig/verified skin.
- B2.4 sandbox PASS != live production/SaveService PASS.
- V5 focused test PASS != OWNER VISUAL PASS.
- Character Studio addon PASS != fully usable composite female/outfit.
- B2 GP-02C1 PASS != V5 baseline repaired.

**This document is a design triage checkpoint, not authorization to start code.**
