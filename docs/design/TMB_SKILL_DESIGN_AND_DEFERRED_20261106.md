# TMB SKILL DESIGN & DEFERRED — Owner checkpoint 2026-11-06

**PR #72**, branch `integration/pve-p0-playable-ui-20261103`. This file preserves owner's scope decisions. **DESIGN-ONLY**, no gameplay/Save edits, no Godot PASS claim, no merge.

## A. Owner explicitly DEFERRED Quyền/Độc work until later
1. Quyền / Kim Cang: finite shield capacity, one-hit lethal-save with recipient **90-second ICD**, reflection tied to *committed actual damage absorbed* require a bounded authored balance contract. Existing handoff scratch QA does not equal live exact-PR72 acceptance.
2. Độc Divine: **26 DESIGN_PENDING** rules: 13 `single_spread_poison` and 13 `removed_debuff_counter`. Do not turn them on or label PASS without owner-approved mechanics.
3. Test matrices exist on PR #72: `tmb_quyen_183_combat_handoff_test.gd`, `v65_poison_combat_contract_test.gd`, `v63_doc_full_combat_matrix_test.gd`. This is NOT proof that every distinct behavior passed integrated QA. Exact-HEAD Godot, GUI/VFX and Save/Reload remain independent gates. CI recently failed with zero executed steps (environment, not demonstrated skill failure).
4. **Machine safety:** owner's Windows 10/8-GB PC has had `ig11icd64.dll` crash / concurrent Godot resource issues. Do not launch any extra Godot if one is active or free RAM <3 GiB; do not terminate unfamiliar PID, force-reset a dirty QA checkout, touch owner saves or promise that a QA run is safe. A dedicated Windows matrix runner with these preflights is `tools/windows/qa/Run-V63QuyenDocMatrix.ps1`.
5. Owner has Codex combat working on separate Combat Lab, and Codex production on economy/SX. Preserve source ownership; no overlapping production edits, no new branch, no main merge.

## B. NEW task for this conversation: design skills for other technical disciplines, not implement yet
**Three Chủ Đạo:** Kiếm Tu / Thể Tu / Pháp Tu (with their canonical 9 original pathways). A technical discipline is NOT a new Chủ Đạo. Heritage/môn phái is the transmission layer; Ngũ Hành and Lôi/Băng/Phong are affinity elements rather than classes.

**Nine proposed additional technical schools** beyond implemented Cung/Quyền/Độc: Kiếm, Đao, Song Đao, Thương, Chưởng, Trận, Triệu Hồi, Chú, Phù. All are **CANDIDATES pending owner approval**.

| Discipline | Proposed branches and signature ultimates |
| --- | --- |
| Kiếm | Ngự Kiếm — Vạn Kiếm Quy Tông; Sát Kiếm — Nhất Kiếm Đoạn Thiên; Hộ Kiếm — Thiên Cương Kiếm Giới |
| Đao | Cuồng Đao — Cửu Trùng Cuồng Đao; Trảm Phách Đao — Trảm Phách Đoạn Thiên; Trấn Đao — Thiên Sơn Trấn Đao |
| Song Đao | Ảnh Nhẫn — Thiên Ảnh Phân Sát; Liên Hoàn — Thập Nhị Liên Hoàn Trảm; Huyết Nguyệt — Huyết Nguyệt Táng Thiên |
| Thương | Phá Trận Thương — Nhất Thương Phá Vạn Quân; Long Thương — Cửu Long Liệt Không; Hộ Quân Thương — Vạn Quân Thương Bích |
| Chưởng | Liệt Dương Chưởng — Thái Dương Phần Thiên; Hàn Ngọc Chưởng — Cửu Hàn Phong Nguyệt; Hồi Phong Chưởng — Thái Thanh Hồi Thiên Chưởng |
| Trận | Tụ Linh Trận — Thái Sơ Vạn Linh Trận; Phong Tỏa Trận — Cửu Cung Phong Tuyệt Trận; Sát Phạt Trận — Vạn Tượng Tru Tiên Trận |
| Triệu Hồi | Kiếm Linh — Thần Kiếm Linh Hợp Nhất; Linh Thú — Vạn Thú Linh Khế; Khôi Lỗi Hộ Pháp — Đại Thiên Cơ Hộ Pháp |
| Chú | Trấn Hồn Chú — Cửu U Trấn Hồn Đại Chú; Phệ Linh Chú — Vạn Hồn Phệ Linh; Hộ Mệnh Chú — Thái Thượng Hộ Mệnh Chú |
| Phù | Lôi Phù — Cửu Thiên Vạn Lôi Phù; Hỏa Phù — Vạn Phù Phần Thiên; Phong Ấn Phù — Thái Huyền Phong Giới Phù |

### Candidate catalogue proposal (generated in chat)
- **27 branches** and **315 unique foundational skill families**: each discipline has shared 1 Basic + 1 Mobility; each of three branches has 4 Active, 1 Ultimate, 5 equipped Passive, 1 Innate.
- **1,647 candidate evolution nodes**, 183 per discipline: 35 Human, 68 Immortal (A/B lineage), 80 Divine (A/B + rare replacements). This is a *data proposal*; not 1,647 coded skills, finished animations, distinct tested mechanics, or approved manual drops.
- One successor within mutually exclusive family can be equipped; mastery/history preserved. No universal Mana bar, no infinite pet/reflect, no uncontrolled Boss hard CC, no fake damage/loot; CombatStatsV2 remains authority.
- Stage coefficients and passive strengths remain **balance candidates**, to be simulated and reviewed with owner before any feature gating or code implementation. New pet/zone/seal mechanics need source adapter, deterministic events and caps.
- The full 315-skill human catalogue with per-skill names, effects, ATK multipliers, CD, range, AI/VFX, 27 lineage signatures, and all 1,647 proposal variants was created as a user-downloadable Excel/Markdown artifact in this conversation. **Those attached files have not been imported into GitHub.** Do not claim this summary alone contains 1,647 detailed records.

**Do next only when Owner selects implementation.** Read `docs/COMBAT_SKILLS_V2_SPEC.md`, `godot/data/combat/v63_content_registry.json`, current PR #72 HEAD and this checkpoint. Design review first; Codex combat owns implementation after approval. Do not occupy the user's machine just to generate candidate skill content.
