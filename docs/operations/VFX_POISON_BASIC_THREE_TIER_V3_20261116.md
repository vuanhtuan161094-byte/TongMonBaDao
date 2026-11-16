# Độc Châm Thường Thức V3 — direct VFX Godot, NO GIF

Owner 16 November 2026 explicitly cancelled GIF-first production. **Do not make more GIFs** by default. Delivery is actual Godot MP4 1280×720, charge/peak/contact screenshots and exact-SHA V4 proof. Existing accepted POI11 R9 remains untouched. PR #72 Draft, no merge.

## Canonical three normal attacks
| Tier | ID | Ratio | Range | Speed | Cooldown | Cast / status |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| Nhân | tmb.skill.poison.basic.human | 1.00 | 6 | 12 | 1.60s | 0 / 0 |
| Tiên BASE | tmb.skill.poison.basic.immortal.base | 1.18 | 6.24 | 13.44 | 1.54s | 0 / 0 |
| Thần BASE | tmb.skill.poison.basic.divine.base | 1.34 | 6.42 | 13.44 | 1.47s | 0 / 0 |

All three: element metal, damage, single target cap 1, no poisoned status; hit_count undeclared and never invented. V6.3 OFF.

## Painted visual progression (not palette-only)
**Nhân:** straight slender jade poison needle, pale core, short violet halo, compact five-ray local hit.
**Tiên:** needle becomes dual-echo cyan-jade lance with two symmetric translucent afterimage trails and seven-spoke broken ripple at hit, still one gameplay target/hit.
**Thần:** stronger jade needle with finely articulated warm-gold tip, two golden side glints and nine-spoke bright local contact plus five subtle gold motes, still one target/hit.

Never make the tail squirm like a snake. Each tier uses new original RGB-alpha source art, with light-pure saturated pigments independent of transparency. 6 charge + 8 flight + 8 contact alpha sprite poses per tier = 66 authored poses total. Three atlases and three preserved master key poses per tier. No actual GIF generated or used. Original Python source: `tools/vfx/generate_poison_basic_tiers_v3.py`.

## Live Godot LAB only
Scene `godot/labs/combat_lab/poison_basic_tiers_v3/poison_basic_tiers.tscn` and focused Godot contract test under `godot/tests/labs/combat_lab/vfx_poison_basic_tiers_v3_contract_test.gd`. Three tiers display sequentially in a 3.78 sec native clip (Human [0,1.26), Immortal [1.26,2.52), Divine [2.52,3.78)); user sees true VFX in Godot on existing frozen caster and actual WALK monster. Screen-space projectile aims toward locked moving target by rotating a single atlas. Each tier's G3.5 images at local t=.08/.42/.80. Native video 234 encoded 60fps frames is NOT 234 source sprite poses and is NOT physical device FPS.

**Pending:** G3.5 native exact-SHA technical QA, human 1× art review, owner visual approval, physical QA, runtime event integration. Keep PvE OFF, V6.3 OFF. No rig, Codex, new branch, merge or Combat V2/SaveService changes.

## V3.1 native QA — stronger Tiên/Thần silhouette after real 1x self review (2026-11-16)

**Evidence at exact source SHA `6a4f846bca65663d23cd36ea319e3d6bfc343710`**, [GitHub Actions #43897820393](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43897820393), **SUCCESS**, downloadable artifact #14239932211 (`poison-basic-tiers-v3-6a4f846bca65663d23cd36ea319e3d6bfc343710`). Independent packets for Human, Immortal BASE and Divine BASE each report **`v4_preflight_technical=PASS`** with three genuine Godot Compatibility 1280×720 frame proofs per tier. Godot import/parse/focused contract PASS, one MOVING WALK monster, four-way screen-space aim, V6.3 OFF, no real Combat V2 hit authority. 3-tier VFX-only film **3.900 s, 234 encoded frames at exactly 60 recording fps**, NOT physical device FPS, NOT 234 authored sprite poses, and **no GIF generated**.

**Source:** 66 truly independent authored RGB+alpha key poses: 22 each from 3 transparent atlas types and retained original PNG masters/first-party deterministic source `tools/vfx/generate_poison_basic_tiers_v3.py`. Total uncompressed nine atlas RGBA8 memory **14,254,080 bytes (13.594 MiB)**; actual compressed on-device GPU footprint, loading/pooling and simultaneous multi-player impact remain unmeasured. Separate skill tiers are not just palette remaps. Automatic CI stores 9 atlases and 9 original master PNGs on existing draft branch under `godot/labs/combat_lab/poison_basic_tiers_v3/assets/`.

**Visual native review:** initial V3 native source `640de00b983e3f5c6d002205cd14b57cdc07381e`, [Actions #43896730181](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43896730181) SUCCESS but Tiên/Thần difference too subtle. V3.1 strengthens Immortal's two cyan afterimage trails and broadens its seven-spoke contact, plus Divine's symmetrical gold light tip and stronger nine-spoke impact. Viewed 3×3 actual Godot native footage (each charge, in-flight, moving-target contact). Human remains a small straight needle; Tiên reads as a wider cyan straight beam; Thần has a broader green-gold arrow and pronounced localized golden-jade contact. No smoky square matte and no oscillating snake trail; 1× actor remains readable, but some forms still depend on viewing size and the owner's preference. We do not call the work owner-art PASS without their actual approval.

**Three-clock truth:** catalogue all three `cast_time=0` and `duration=0`; .15s display-only charging, demo contact .70s, fade through 1.03s per tier, 1.26s per-tier slot. No automatic DoT/status, no extra hit, no canonical Combat V2 3.9 second cooldown/attack. All three basic-tier catalogues retain `v63...` gated keys; LAB does not enable them.

**Final technical gates:** `V4_NATIVE_GODOT_TECH_PASS_EXACT_SHA`, `ORIGINAL_RGBA_SOURCE_COMMITTED`, `HUMAN_ART_SELF_REVIEW_READY_FOR_OWNER`, `OWNER_VISUAL_PENDING_THREE_TIERS`, `RUNTIME_MAPPING_PENDING`, `PVE_INTEGRATION_HOLD`, `V63_OFF`, `PHYSICAL_WINDOWS_ANDROID_QA_PENDING`. No rig, CodeX, merge, branch, or unrelated gameplay modifications.


## Owner decision 2026-11-16 — V3.1 THREE TIERS **TEMPORARILY ACCEPTED, NOT FINAL**

Owner response after viewing native Godot V3.1 comparison of Human / Immortal / Divine: **“chưa ok lắm nhỉ. nhưng thôi tạm vậy”**. This is consent to **keep V3.1 provisionally and proceed**, not final visual acceptance of quality. Do not incorrectly mark these three sprites OWNER_VISUAL_APPROVED. Existing Godot technical PASS and source SHA/evidence remain valid for the same V3.1 assets; user still finds the artwork not quite satisfactory. Freeze the current three-tier V3.1 assets and preserve their history, do **not** redo immediately or silently upgrade versions.

**Future optional polish backlog (subject to later owner direction):** improve vivid layered transparency and material sophistication inspired by the luminous clarity of Võ Lâm / Kiếm Thế without copying pixels, stronger distinct Human→Immortal→Divine silhouettes and local contact patterns, keep needles straight and avoid snake-like wobbling, maintain tiny basic-attack readability at 1× while limiting target occlusion. No need for a GIF or GIF-based workflow. Previous native MP4/9 screenshots are evidence, not a playable PvE integration.

**Current gate for all 3:** `GODOT_V4_TECH_PASS_V3_1`, `OWNER_PROVISIONAL_ACCEPTED_NOT_FINAL`, `POLISH_BACKLOG_OPEN`, `PVE_INTEGRATION_HOLD`, `V6.3_OFF`, `PHYSICAL_QA_PENDING`. No rig, Codex, branch/merge, new gameplay effect or unsanctioned V6.3 enabling.
