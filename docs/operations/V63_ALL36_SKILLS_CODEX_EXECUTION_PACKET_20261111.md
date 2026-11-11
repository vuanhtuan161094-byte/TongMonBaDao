# V6.3 ALL36 — GÓI THỰC THI CODEX: 12 TRƯỜNG PHÁI / 36 NHÁNH / KỸ NĂNG–LINH CĂN–VFX–PK
Ngày: 2026-11-11  
Status: **OWNER AUTHORIZED EXECUTION SCOPE; IMPLEMENTATION/RELEASE NOT YET COMPLETE**  
Repository: vuanhtuan161094-byte/TongMonBaDao; ONLY PR #72; ONLY branch integration/pve-p0-playable-ui-20261103.

## 0. Mệnh lệnh và ranh giới

Owner đã chốt định hướng V6.3 12 trường phái, 36 nhánh; luật **trường phái quyết định lối đánh, kỹ năng quyết định hiệu ứng, Linh Căn quyết định tương hợp và sức mạnh nguyên tố**. Chủ dự án yêu cầu Codex hoàn thiện mọi kỹ năng, gameplay AI, VFX và nền PK liên phái theo các cổng dưới đây, **không dừng ở JSON/thiết kế**. Chín hệ trước đây đánh dấu CANDIDATE ngày 06/11 nay được owner phê duyệt **phạm vi triển khai**, KHÔNG phải phê duyệt tự động mọi chỉ số ứng viên, VFX hoặc bật feature gate.

Bắt buộc đọc AGENTS.md, docs/GAME_SYSTEM_ARCHITECTURE.md, CURRENT_CHECKPOINT.md, NEXT_CHAT_HANDOFF.md, docs/design/TMB_SKILL_DESIGN_AND_DEFERRED_20261106.md, docs/design/SKILL_ALL_EVOLUTION_BALANCE_MASTER_20261111.md, docs/qa/SKILL_ALL_QA_EVIDENCE_20261111.md, docs/SPIRITUAL_ROOT_V2_SPEC.md, docs/COMBAT_SKILLS_V2_SPEC.md và live source HEAD trước khi sửa. Đọc cả Issue #75 để kế thừa PASS/PENDING; tránh code lại phần đã có bằng chứng.

**Git rule:** chỉ cập nhật branch hiện hữu PR #72; không tạo branch/PR khác, không merge/main/rebase/force push/reset/clean worktree, không sửa SaveService hoặc save người chơi, không tạo loot/EXP/vật phẩm giả, không tự bật V63FeatureGates. Mỗi đợt code có một writer cho file/subsystem trùng nhau; việc economy/GP-PLAY01 đang đồng thời hoạt động nên không chạm Warehouse, Building, Economy, GP và scene ngoài scope. Nếu Codex Cloud bắt buộc tạo branch riêng, báo BLOCKED_SAME_BRANCH, không lách. Không tự đổi AGENTS/Owner contract.

**Bằng chứng ban đầu:** 549 V6.3 IDs (3 phái Cung/Quyền/Độc), 105 family, 9 nhánh. 564 inventory entry là 549 skill + 9 combat legacy + 6 TechniqueSystem; 6 technique không phải skill cast. Official Godot 4.7.2 headless focused đã đạt trong SKILL-ALL-01→05, còn CI status, cold-process active-PVB1 Save, full mastery/gameplay và GUI/Android PENDING. Không gọi chúng là FULL PASS.

## 1. Danh mục đích và hợp đồng đếm

| School slug | Trường phái | Nhánh 1 | Nhánh 2 | Nhánh 3 | Existing |
|---|---|---|---|---|---|
| bow | Cung | Liệp Ảnh (liep_anh) | Linh Tiễn (linh_tien) | Thiên Vũ (thien_vu) | 183 node source |
| fist | Quyền | Bá Quyền (ba_quyen) | Kim Cang (kim_cang) | Huyết Quyền (huyet_quyen) | 183 |
| poison | Độc | Độc Châm (doc_cham) | Cổ Độc (co_doc) | Dược Độc (duoc_doc) | 183 |
| sword | Kiếm | Ngự Kiếm | Sát Kiếm | Hộ Kiếm | proposed |
| blade | Đao | Cuồng Đao | Trảm Phách Đao | Trấn Đao | proposed |
| dual_blade | Song Đao | Ảnh Nhẫn | Liên Hoàn | Huyết Nguyệt | proposed |
| spear | Thương | Phá Trận Thương | Long Thương | Hộ Quân Thương | proposed |
| palm | Chưởng | Liệt Dương Chưởng | Hàn Ngọc Chưởng | Hồi Phong Chưởng | proposed |
| formation | Trận | Tụ Linh Trận | Phong Tỏa Trận | Sát Phạt Trận | proposed |
| summon | Triệu Hồi | Kiếm Linh | Linh Thú | Khôi Lỗi Hộ Pháp | proposed |
| curse | Chú | Trấn Hồn Chú | Phệ Linh Chú | Hộ Mệnh Chú | proposed |
| talisman | Phù | Lôi Phù | Hỏa Phù | Phong Ấn Phù | proposed |

**Target budget, not shipped coverage:** 12 schools × 3 branches = 36; 35 human/foundational families × 12 = 420; 183 evolution nodes per school (35 human + 68 immortal + 80 divine) × 12 = **2,196**. Existing 549 nodes; nine other schools **1,647 candidate nodes**. Nine proposed schools were described in a prior chat artifact (315 families, 1,647 candidates), **not fully imported as per-skill GitHub rows**; recover actual source if available, or author new canonical tables with provenance and no fabricated claim of recovered historical rows.

Per school: shared Basic + Mobility, 3 branches × (4 Active + 1 Ultimate + 5 slottable Passive + 1 Innate) = 35 foundational family slots. Named A/B successors and rare replacements through Tiên/Thần use mutually exclusive family chains. Keep ID/name/parent/replaces graph stable, do not overwrite old skill ownership and preserve prior mastery/history. Runtime max 12 equipped skill IDs and derived innate must follow the **actual** V6.3 contract; never blindly import old V2 loadout count.

**Differentiation:** Quyền = cận chiến nặng/phá giáp; Chưởng = chưởng lực/khống chế/nguyên tố; Đao = nặng/chém; Song Đao = nhanh/combo; Trận = vùng tồn tại/hữu hạn; Chú = dấu ấn/hiệu ứng có khắc chế; Phù = thi triển phù văn/ấn và người sở hữu; Triệu Hồi = một ngân sách actor/AI/summon riêng bị cap. Distinct mechanics, not 183 cloned numbers.

## 2. V63-ROOT — luật chung bắt buộc trước khi nhân skill

- Ngũ hành cơ bản Kim/Mộc/Thủy/Hỏa/Thổ; Dị Linh Căn Lôi/Phong/Băng/Dương/U Minh có nguồn và quan hệ rõ, KHÔNG tự ánh xạ Lôi=Kim hay U Minh=Mộc, KHÔNG áp đồng thời thưởng hai root nếu chưa có luật multi-element.
- Skill khai báo element(s) và allowed scalable fields; Linh Căn không biến bắn thường thành độc/hỏa, không tự tăng cast range, cooldown, status duration, AoE radius, target cap, stacks, CC, proc; passive đặc thù mới cho phép.
- Đánh thường Cung Tiễn Thức Căn Bản và Độc Độc Châm Thường Thức hiện **cùng tagged metal**, damage đơn, không poison mặc định. Nếu Tẩm Độc Châm có proc phải có authored proc chance, owner, ICD, resist/cap, receipt; không chèn poison tự do vào basic.
- V2 Spiritual Root spec: 1–5 base elements và per-root purity 1..100, matching_skill_effect_bonus = P×0.30%×resonance; matching learning 0.15%, matching resist 0.15%. Thông số thiết kế là **starting candidates**; owner chốt nguyên lý, chưa duyệt balance cuối.
- Counter cycle: Kim>Mộc>Thổ>Thủy>Hỏa>Kim; intended ×1.25 thuận khắc, ×0.85 nghịch khắc, ×1.0 trung tính; chỉ áp dụng khi quái/đối thủ có elemental identity thật. Hiện MapBattleV2 đang truyền elemental_matchup_factor 1.0; cần sửa core một lần và test proof.
- Source hiện tại: legacy spiritual_root_system.gd (mô hình cũ), DiscipleState.spiritual_root_elements, CombatStatsV2 ELEMENTS 10, V6.3 single element tag, MapBattleV2 resolution. **Không tạo 2 authority Linh Căn**: migration/versioning, deterministic save, derived source registry, no double-dipping, no fake target resistances. Root V2 design chưa production complete.
- Actor snapshot cần mang source root buffs/element thuộc canonical discipline; các skill trực tiếp, DoT (snapshot), heal, shield và valid passive dùng đúng consumer; preserve HP ratio when root buffs max_hp; proof no 0HP revive by ordinary heal.
- VFX reads combat events and final element; Dị element can tint/overlay bounded VFX but cannot fabricate extra damage or status.

## 3. Cổng triển khai; CODEx làm tuần tự, không dừng ở DESIGN

### G0 — Inventory & technical design freeze (first mandatory gate)
Fetch latest PR HEAD; compare with Issue #75, existing 549 IDs, current CI, manifest and other writers. Build authoritative 36-branch ledger by branch/school/family/skill/generation/lineage/element/root compatibility/effect/shape/range/CD/target cap/CC/AI/VFX/owner source/status. Recover earlier detailed 1,647 candidate artifact only if actually accessible, otherwise recreate as NEW content. Document 9 candidates becoming owner-authorized execution scope, distinguish numbers still BALANCE_CANDIDATE. Identify near-identical mechanics and redesign to distinct; no new gameplay gate ON.

**Exit:** 36/36 branch contracts and 2,196 unique planned ID slots with per-record provenance; no pretending the candidate slots are already code. Resolve overcount of non-cast passives/innates/legacy and mutually exclusive successors.

### G1 — V63-ROOT-01→04 shared core
Implement pure affinity evaluator and bounded element matchup once, per-root purity/derived buff & deterministic mutation eligibility with compatibility bridge, provenance, save migration scope; apply to basic, actives, DoT, heal, shield, passive (only scalable fields), and legacy cross-check. Tests: 5 base roots, 0/1/80/100 purity, single/multi-root, 10 element tags, counter/reversal/neutral, no-affinity, independent sources, boss, snapshot DoT, 0HP, quit/start cold-process save where tool access permits, old save backward. Root 80 → +24% candidate matching magnitude (before resonance) must not compound into stacks or speed by default.

**Exit:** real engine tests show two otherwise identical disciples yield distinct numbers for compatible vs incompatible skill; no fake root/monster attributes; no duplicate damage modifiers; feature gates OFF by default.

### G2 — Close original three schools
For **Cung/Quyền/Độc × 183 = 549 IDs**, verify skill learn/equip/cast/target/AI/status/passive/lineage/ultimate/motion/proc/element/VFX ownership. Repair only evidenced defects. Poison PVB1 26 pending design effects, Kim Cang 90s lethal recipient ICD, bounded shields, committed-damage reflection, etc. Maintain 168 fixture baseline but add real PvE population and combat receipts. No softlock; V63 gates OFF until later release.

**Exit:** each of 9 branches demonstrably usable in gameplay and traceable VFX; 549 individual audit rows marked truthfully TESTED, FIXED, CANDIDATE or BLOCKED (never blanket PASS from parse).

### G3 — Golden vertical slice and weapon schools
Build **Kiếm** first: all 3 branches 183 nodes, including Ngự Kiếm flying swords/range, Sát Kiếm execution single target, Hộ Kiếm defensive parry, with visible skill name/tooltip, ownership learning, AI and distinct master VFX. Validate one real vertical slice (1v1, 6v8, 30/40 benchmark, GUI where access exists). Use its authoring/qa system to build **Đao** and **Thương**; each 183 nodes with differentiated hits and weapon requirements. Do not create branch-shaped generic skill names without mechanics.

### G4 — Style/support schools
Build **Song Đao, Chưởng, Phù** at 183 nodes/school. Song Đao combo/dual timing must not multiply actor count; Chưởng's AoE/element/status must differ from Quyền; Phù uses authored rune spell events and item/consumable economy only when verified real source, do not invent talisman inventory.

### G5 — Heavy-mechanic schools
Build **Chú, Trận, Triệu Hồi** at 183 nodes/school. Implement debuff resistance/cleanse budget/ICD, bounded persistent AoE zones, summon budget/lifecycle/targeting/expiration/death/save and no duplicate rewards or independent loot. Hard control vs bosses capped; AI/CPU safe at 30 disciples/40 active monsters. Scope freeze if source state or save-owned rules conflict with live production writer; report exact blocker, continue non-overlapping parts.

### G6 — Full VFX and cross-school PK/gameplay
For each of 420 foundational families and every successor, map visible cue(s): cast/telegraph/projectile/hit/area/status/end; master asset reuse allowed but no unmatched null VFX for visible cast. Produce 12 visual identities, 36 signature ultimates, authored 3-generation evolution and readable HUD/range/cast bars. Use actual art/atlas/vector assets with attribution/hash/manifest, not placeholder name claims, and no per-level asset rewrite. Fast AoE/DoT rendering bounded, no hit animation restart on each tick.
Create **offline tactical sparring/PK lab**, not network PvP, with 36×36 ordered branch matchups = **1,296** scenario slots (same-branch mirrors included), diverse fixed seeds; add 1v1/3v3/6v6 skill-AI/autobattle, combat logs, victory/injury/skill cooldown. Optional online/direct PvP is NOT authorized by this packet and must not be silently activated. Respect no PvP in existing live release; sparring belongs to isolated gated test mode until owner separately accepts player-facing PK.

### G7 — QA, release and playable handoff
Official Godot 4.7.2 import, parse, focused school regression, cumulative exact SHA with logs, source/hashes; test 2,196 skill ID coverage and graph uniqueness; per-skill cast or justified passive trigger; 36 branch real combat, cross-school counter consistency, root edge cases, 30 disciple/40 monsters sustained, performance frame pacing, memory, SaveService cold-process active state, offline 60–180m not faked, warehouse/health/injury invariants. Windows real mouse 1280×720 and Android device explicitly PENDING USER unless actually executed, owner visual acceptance separate. If GitHub Actions returns zero runs, report CI PENDING not PASS. Feature gates stay OFF and PR stays Draft until all authorized release gates pass and owner approves public activation.

## 4. Definition of DONE per skill and per school

A skill is **GAMEPLAY DONE** only when: stable unique ID/name, source/learning/unlock, valid equip/successor, complete numeric formula and caps, no duplicated proc/DoT, event ownership, AI target/range/CD/cast, root/element path, test for its *actual effect* including failure/edge cases, and valid UI cue/tooltip. Passive and innate need proof of modifier/trigger, not a fake cast. Mobility, heal, cleanse, guard and zones need distinct test or justified noncombat exclusion. VFX DONE requires real render artifact and mapped cue, not merely catalogue element tag.

A school is **ACCEPTED** only when all its branch major actions, passives, rare successor and boss/counter/AI mechanics have tests; 183/183 IDs tracked; 3 distinct branches visible and tactically meaningful; base/higher realm progression and comparative balance measured; image/animation visual QA and regression on exact SHA; no hidden gate switches.

Deliver/update:
- docs/qa/V63_ALL36_ID_AND_EFFECT_MATRIX.csv — authoritative 2,196 row coverage, each implementation/status/QA evidence and signature;
- docs/design/V63_ALL36_BRANCH_AND_ELEMENT_RULES.md — 36 branch identities, root/mutation skill scalability, unique mechanics & numerical candidates;
- docs/qa/V63_ALL36_BALANCE_AND_PK_MATRIX.csv — seeded matchups, measurable DPS/DoT/HPS/CC/win etc, no artificial balance verdict;
- docs/qa/V63_ALL36_QA_EVIDENCE.md — exact SHA engine, CI/logs, visual evidence and true pending;
- actual VFX assets/manifest/source proof plus VFX runtime tests, no fabricated files;
- CURRENT_CHECKPOINT.md and NEXT_CHAT_HANDOFF.md **only when integration owner confirms safe to edit them**, otherwise handoff issue comment with exact status.

## 5. Execution control and safety

Path allowlist starts with `godot/data/combat/v63_*.json`, `godot/src/simulation/combat/v63_*.gd`, `godot/src/simulation/cultivation/` for root adapter, `godot/src/simulation/technique/v63_learning_system.gd`, `godot/tests/simulation/v63_*.gd`, scoped combat visuals/assets/manifest/tests and `docs/{design,operations,qa}/`. `map_battle_v2.gd`, `combat_stats_v2.gd`, `disciple_state.gd`, legacy root migration and GUI combat lab are **shared high-risk single-writer files**, editable only after confirming file ownership, isolated regression and save safety. Do NOT edit SaveService, Warehouse, economy, production, main scene / noncombat UI without separately confirmed integration ownership. Never weaken tests. Do not write invented physical device QA.

Commits SMALL and atomic; after each G0–G7 post on linked issue: latest HEAD and code SHA, touched files, tested commands, exact outputs/return codes, supported features, known BLOCKED/PENDING, next gate. Do not stop at 549 IDs, at generic renders, or at a pretty mockup. Do not claim background Codex task launched merely because this packet/issue exists.
