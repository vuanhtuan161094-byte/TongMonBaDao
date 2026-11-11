# V6.3 ALL36 — SKILL DESCRIPTION + VFX PRODUCTION CONTRACT
Owner approval 2026-11-11 · execution companion to Issue #76 · PR #72 single active branch.

## 0. Hard obligation

Every one of the **2,196 target skill nodes** (12 schools × 183) must have a unique canonical ID and an **honest Vietnamese display name, understandable player-facing short/long descriptions, exact gameplay tooltip, and VFX/animation production specification**, even if the node is a passive, innate, mobility, healing, buff or rare successor. All descriptions must match the IMPLEMENTED behavior and the current values of the authoritatively loaded catalogue; generation alone never means GAMEPLAY_PASS.

Count contract: three preexisting schools Cung/Quyền/Độc = 549 catalog nodes; nine extra schools = 1,647 NOT_AUTHORED planning slots. A skill *node* is not necessarily a different basic visual asset, independent cast, or extra equipped slot. Keep 420 Human/foundational families distinct; preserve mutually exclusive successor lineage and existing 549 IDs. Never rename existing save identifiers to improve prose. Existing catalogue elements like bow Basic = metal and poison Basic = metal direct-only remain truthful; no automatic poison proc just because the class is poison.

Do not treat this document as permission to turn on V6.3, alter player SaveService, create fake Warehouse/codex material/drops, or implement internet/network PvP. Draft PR #72, branch integration/pve-p0-playable-ui-20261103 only. Respect one writer per shared runtime file. The status of G1B already achieved on code SHA ed813ab157fd8c814f8d6b88ebf46aa69b6a58f2 (Godot official Actions #42960950171); G1 full/mutations and G0's 1,647 payloads remain open.

## 1. Design truth and data layering (no duplicated authorities)

A. Runtime skill catalogue (existing Human, Immortal, Divine plus new source files on same V6.3 registry) is the **single source** for mechanics, coefficients, dimensions, cooldown, range, element, targets, caps, source ownership, cast behavior and learn/equip rules. The current source JSON already includes id, family_id, name, school, branch, slot, tier, effect, damage_ratio, range, cast_time, cooldown, projectile_speed, element, shape, radius, target_limit, power, duration, passive_modifiers, animation_key, vfx_key.

B. Write an additive **authoring manifest** keyed by the same canonical runtime ID for localized narrative + visual direction + QA provenance (e.g. under godot/data/combat/v63_skill_presentations_*.json or similarly clear path). It MUST reference runtime IDs; must not create a parallel skill balance table, duplicate source of truth or implicitly unlock/learn anything. Choose the fewest additive files compatible with existing registry/loader; author a validator that joins runtime and display metadata 1:1.

C. Human-facing NUMERICAL tooltip must be computed or mechanically checked against runtime definition (format duration, range, percentages, target count, CD, cap, proc chance) so every balance revision cannot leave a stale claim. An authored fantasy/flavor sentence may be static; quantitative facts must be derived from authoritative fields. A data-only balance candidate can carry a candidate label in internal QA, never pretend user-facing live behavior works.

D. Skills may be taught via an archived manual only if a canonical codex/manual and earning path exist. Tier successors keep stable parent_skill_id/family_id/replaces/lineage without destroying old mastery; no fabricated unlock paths. If sourcing is unresolved, keep SOURCE_PENDING and block learning in live gameplay, but continue authoring, tests and other schools.

## 2. Required authoring fields for EACH node (no null-filled template accepted as complete)

**Identity / UX**
- skill_id (stable exact runtime id); family_id; school; branch (or shared); slot=basic/mobility/active/ultimate/passive/innate; tier=human/immortal/divine; lineage=base/a/b; variant=normal/rare; parent_skill_id, replaces where applicable; availability/source ID and known realm/unlock requirements.
- display_name_vi: distinct, wuxia/xianxia register; existing names preserved; successor names should say what changed and not merely append 'Tiên Giai' 1,647 times. Full name + unambiguous visible tier badge separate from name if necessary.
- short_description_vi: 1 concise line about action/role for compact mobile UI, NOT just 'gây sát thương lớn'.
- long_description_vi: 2–4 helpful sentences: physical/magical action, target/area, effect and trigger, what differentiates this from same-branch actions, limitation/conditional requirement; avoid unsupported claims.
- mechanics_tooltip_template: per-effect clauses pulled from canonical fields, clearly showing **range, cast_time, cooldown, target_limit, damage/heal/shield/DoT, tick, status and caps** only if actually implemented. Passive shows affected stat and triggering condition, not a fake cooldown; innate likewise. Basic displays attack interval as actually derived. Units in grid-cell/seconds and % where known; label ATTACK multiplier explicitly, not flat damage. If a value is conditional, use actual linked status/source. Include how Root element matches and whether Dị root is PENDING, never hardcode a universal 24% bonus.
- role_tags and counterplay_vi: distinct tactical role (single-target, piercing, line, area, buff, cleanse, setup, execution, mobility, parry, defense etc), counter or limitation (break line, dodge, cleanse, armor, resistance, cast interrupt) only when engine permits.

**Behavioral runtime / AI contract**
- existing element, advanced_element (only with proper spec support, never invented aliases), shape geometry, actual target cap, ownership, timing, cooldown, cast release event, projectile collision, hit timing, proc chance/ICD, DoT owner and snapshot, heal/absorb/reflection source, PvE/Boss CC resist, resource/cost if real. Define each skill's AI eligibility/priority/distance/target selection/retreat behavior and expected state/events (active may not release if interrupted).
- clarity on passive: continuous modifier = no repeated visible explosions; event-trigger passive = only emit cue on actual proc receipt. No automatic burning, poisoning, stun, slowing or extra arrows from element alone.
- explicit generation_delta for Human → Tiên A/B → Thần I/II/III where relevant: numeric evolution and **qualitative** differences (new trajectory/retarget/guard/interaction/rare replacement) only when authorized and implemented. Keep 2 mutually exclusive A/B successors with real tactical contrast; Divine rare successors must remain rare, not duplicate base ultimates.

**VFX production per node**
- vfx_intent: one sentence describing what user sees and why (not 'cool particles').
- motif & silhouette: sword arcs/flying blades/spear lines/talisman glyphs/poison needles/lotus/formation circle/summon silhouettes; distinguish from nearby branches with color-independent shape.
- palette_primary/secondary/highlight and element tag; use readable golden-grey Kim, green jade Mộc, azure Thủy, ember-red Hỏa, ochre Thổ; Lôi violet/white, Phong aqua/white, Nether deep-violet/green, etc only as suggested art directions, not mutation gameplay.
- animation_key/vfx_key existing keys retained; requested master_vfx_family + variant_id + lineage/realm tier. A shared master effect with meaningful per-node composition is good; a single color-swap for all 36 ultimates is not acceptable.
- cue_phase: windup/telegraph, release, travel (if projectile), impact, active/DoT/status/heal, fade. For each: relative timeline or event trigger; anchor (caster hand/weapon tip/body, target actor, contact point, ground), travel type/speed from runtime, shape/radius from runtime, facing/motion relationship, lifetime bounded. Cosmetic timings cannot change hit registration.
- projectile: count from combat truth (not a random display hit count), arc/line/beam/cone, impact and trail; AoE uses actual target cap and area, not a visual explosion that implies 20 hits when only 3 were resolved.
- render layers & blend: character below/above, ground decal, silhouette visibility, alpha/readability on crowded 1280×720 Android/Windows, pooled particles and low-detail LOD. Avoid fullscreen white flashes, endless looping particles, arbitrary shake or repeated hit-stun on every DoT tick.
- audio cue description OPTIONAL (no generated audio required); icon concept and telegraph readability; camera feedback bounded; whether an asset already EXISTS or is PLANNED; actual atlas/shader/scene/renderer path and hash ONLY after artifact creation. VFX can be drawn programmatically when superior and tested; no fake image assets or 'render PASS' from a manifest key.
- vfx_test: associated event IDs, actual screenshot/short capture or QA render hash where feasible; manual/GUI visual PENDING if inaccessible.

**Per-node QA/provenance**
- implementation_status = NOT_AUTHORED / DESIGN_READY / RUNTIME_CODED / MECHANIC_TESTED / VFX_MAPPED / RENDER_TESTED / GUI_ACCEPTED / RELEASE_READY; choose independent booleans/status fields if a single enum loses distinctions. 2,196 rows should NOT all be 'PASS' because 2,196 JSON objects parse.
- code_path, test_id, exact SHA, tested behavior, bug/owner issue link, source authority; a fake 'PASS' or test filename not executed is disallowed. Unique design-family mechanic ID must be attached to each of 420 families; descendants can share family mechanics with true evolution deltas.

## 3. Sample: real source-grounded entries (illustrative production briefs, NOT game balance changes)

### Example A — Cung basic, EXACT existing data
ID = tmb.skill.bow.basic.human; name = Tiễn Thức Căn Bản; element=metal; effect=damage; range=9; damage_ratio=1.0; cooldown=1.6; projectile_speed=12; single target. Short: 'Bắn một mũi tên Kim chính xác vào mục tiêu ở tầm xa.' Long: 'Đệ tử giương cung và bắn một mũi tên thẳng tới một kẻ địch. Đòn thường gây sát thương trực tiếp, không tự thêm Thiêu Đốt, Độc hay khống chế; Kim Linh Căn chỉ tăng hiệu quả nếu hệ tương hợp đang hoạt động.' These are design-text suggestions and the final text must match runtime UI and gear/haste-derived basic interval. Visual: small silver-gold arrow, crisp shot line, brief thin impact sparks, no AoE, no poison cloud; bow draw anchor → projectile tip → target; no repeated hit animation.

### Example B — Cung active, EXACT existing data
ID = tmb.skill.bow.liep_anh.active_01.human; name = Xuyên Tâm Tiễn; element=metal; damage_ratio=1.35; range=10; cast_time=0.45; cooldown=8; projectile_speed=8; single target. Short: 'Tụ lực bắn một mũi tên xuyên phá vào một mục tiêu.' Long: 'Liệp Ảnh ngắm chuẩn, tụ khí Kim vào đầu tên và bắn một phát uy lực đơn mục tiêu. Kỹ năng gây sát thương trực tiếp; không tự xuyên nhiều kẻ địch, không gây chí mạng bảo đảm và không gây hiệu ứng phụ nếu chưa được khai báo.' VFX: fast needle-straight silver shaft, circular aim glint while casting, piercing linear afterimage, precise tiny metallic bloom at actual hit; high impact without AoE falsehood. In successor A/B, art direction must track authored variant not generic brighter arrow.

### Example C — Độc active, EXACT existing data
ID = tmb.skill.poison.co_doc.active_02.human; name = Xà Ảnh Quấn Mạch; element=wood; effect=poison; direct damage ratio=1.05; poison power=0.022; duration=8 seconds; stack=1; range=7.5; cast_time=0.45; cooldown=9; target_limit=1. Short: 'Phóng cổ độc hình rắn, làm mục tiêu trúng độc trong 8 giây.' Long: 'Một luồng cổ khí hóa hình rắn xanh bám vào mục tiêu, gây đòn đánh đầu tiên và để lại độc theo thời gian. Mức độc/tick, giới hạn tầng và cơ chế thanh tẩy phải lấy từ runtime; Mộc Linh Căn không tự tăng số tầng hoặc thời lượng.' VFX: narrow translucent serpent trace along projectile, one jade bite flash on impact, a restrained green skin-rune icon during DoT, low-intensity tick pulses; NO repeated hit-stun or separate extra hits caused by visual coils.

### Example D — Độc offensive NAME IS NOT AN EFFECT
ID = tmb.skill.poison.doc_cham.active_01.human; name = Xuyên Cốt Độc Châm; element=nether; actual effect=damage; ratio=1.45; range=7.5; cooldown=9, cast=0.45, projectile speed=8. Short: 'Phóng một độc châm U Minh gây sát thương trực tiếp.' Do NOT say 'gây độc 8 giây' simply because the name includes Độc. VFX: deep-violet slim cursed needle, a single sharp impact flare, no DoT indicator unless later real mechanics adds it.

### Example E — passive / Trận / healing / ultimate contracts (NONNUMERIC until coded)
Passive example: 'Tẩm Độc Châm' can visually coat future needle on **confirmed proc only**, but cannot invent a proc or alter Basic damage merely from a design name. Phù skill: glyph appears at the hand then travels as authored spell, glyph must not imply consumable talisman debit without real inventory. Trận skill: rune circle remains tied to finite zone owner/duration/radius; status/DoT tick visuals react to *actual* zone events. Heal: lotus/green light pulse occurs only when a genuine heal event raises HP; no resurrection or injury clearing without authority. Summon: silhouette has bounded actor ID/lifetime and no separate drops. Ultimates: each of 36 branches must have a recognizable authored signature motif and a clear windup+release+impact+residue sequence, with PvE target cap truthfully represented.

## 4. 36-branch visual grammar and mechanical silhouettes (direction, not fabricated skills)

| School | Branch 1 | Branch 2 | Branch 3 | What MUST be distinguishable |
|---|---|---|---|---|
| Cung | Liệp Ảnh | Linh Tiễn | Thiên Vũ | precision sniper vs thunder/arcane projectile vs volleys/formation |
| Quyền | Bá Quyền | Kim Cang | Huyết Quyền | heavy melee shock vs protective fist/guard vs bounded blood tradeoff |
| Độc | Độc Châm | Cổ Độc | Dược Độc | lethal narrow needles vs persistent serpent/gu DoT vs lotus medicinal poison/heal |
| Kiếm | Ngự Kiếm | Sát Kiếm | Hộ Kiếm | remote flying blade formations vs single execute arcs vs parry/barrier |
| Đao | Cuồng Đao | Trảm Phách Đao | Trấn Đao | multi-swing heavy blade vs armor-breaking cleave vs defending frontal cut |
| Song Đao | Ảnh Nhẫn | Liên Hoàn | Huyết Nguyệt | evasive afterimage (cosmetic only) vs short capped dual combo vs blood-moon burst |
| Thương | Phá Trận Thương | Long Thương | Hộ Quân Thương | disciplined straight-line pierce vs dragon-shaped thrust vs protective spear wall |
| Chưởng | Liệt Dương Chưởng | Hàn Ngọc Chưởng | Hồi Phong Chưởng | hot palm AoE vs frost/slow with Boss guard vs flowing heal/support palm |
| Trận | Tụ Linh Trận | Phong Tỏa Trận | Sát Phạt Trận | buff circle vs bounded seal zone vs damage formation |
| Triệu Hồi | Kiếm Linh | Linh Thú | Khôi Lỗi Hộ Pháp | hovering blade spirit vs beast silhouette vs shielded puppet |
| Chú | Trấn Hồn Chú | Phệ Linh Chú | Hộ Mệnh Chú | timed ward/seal vs siphon curse vs protective talisman/sigil |
| Phù | Lôi Phù | Hỏa Phù | Phong Ấn Phù | lightning bolt glyph vs fire seal burst vs binding rune circle |

Three Chủ Đạo (Kiếm Tu / Thể Tu / Pháp Tu) are a different cultivation taxonomy; none of these 12 technical schools silently replaces them. Element is an attribute, not a separate school.

## 5. Acceptance automations — content, behavior and visual

1. Validator enumerates **exactly 2,196 target node IDs**, no duplicates, 12×183, 36 branch assignments and 420 foundational family chains. Existing 549 IDs must match original canonical IDs. Each authored node must have localized short/long description, correctly typed core fields and linked visual profile. For 1,647 NOT_AUTHORED slots, preserve explicit planning status until data actually exists; validator reports counts by stage and never silently accepts null as authored.
2. Static validation compares every explicit number/tag in tooltip to the runtime/formatter, catches dangling effect terms (e.g. named poison skill with no DoT code), nonexistent VFX keys, broken successor lineage, conflicting replacement, passive trigger with no event.
3. Behavioral tests take representative **per-family** scenarios plus all ID load/learn/equip/event/AI checks; passive/innate must prove actual modifier/trigger and need NOT make fake cast events. Human/Immortal/Divine effect behavior and unique mechanic deltas proven. Basic/one-target/AoE/DoT/guard/heal/cleanse/mobility/summon/zone/CC must each have real integration coverage.
4. VFX acceptance separates VFX_META_COMPLETE (design spec), VFX_ASSET_PRESENT (actual art or renderer), VFX_EVENT_MAPPED (proper simulation cue), VFX_RENDER_CAPTURED (real output), VISUAL_ACCEPTED (human/device). No fast-forward these labels. Render tests for single-target, 3-target AoE, 6v8 and 30 disciples/40 monsters; long-range caster stands at maximum authored range; layered visuals avoid flicker and hit-stun restart on DoT. Performance only PASS with frame timing and RAM numbers from real runner.
5. QA output must give every node's current status/provenance, summary table per school/branch and sampled screenshots/atlases on same SHA. CI import+focused+cumulative official Godot 4.7.2, version/source SHA/log paths; cold-process save and Windows/Android explicitly PENDING until actually run.

## 6. Order of work without artificial bottlenecks

- **Author 35 foundational families per school first**, with full mechanic/descriptions/VFX direction; validate; immediately expand successors through explicit lineage/variant deltas and named ultimate/rare replacements. Do not write 183 copies with only a coefficient and 'Tiên/Thần' suffix. Existing 549 are audited/enriched without renaming identifiers; additional 1,647 are original authoring, not recovered previous workbook.
- Produce code/tests/low-cost renderer foundation in vertical slices **per school**, rather than waiting for the whole 2,196 metadata book to finish. Start golden Kiếm as in Issue #76 while honoring G1B pass and separate G1C root/mutation ownership.
- The Codex executor may autonomously batch as many non-overlapping schools/commits as convenient, refactor shared visual code when owning that subsystem, generate validation and quick focused QA repeatedly, and continue through the entire preapproved G0–G7 without waiting for owner after each school. Only pause for actual shared-code writer conflict, unsafe save/economy change, unsourced item/monster loot, external device acceptance, or release gate activation. A design candidate balance number is not blanket approval for production.
- Update Issue #76 with exact code SHA, authored count, behavior coverage, VFX spec/asset/renderer coverage, official QA PASS/PENDING and next execution slice. Do not put 'DONE' solely because all 2,196 descriptions exist.

This contract is subordinate to current owner instruction, AGENTS.md, canonical architecture and the committed Issue #76 execution packet.