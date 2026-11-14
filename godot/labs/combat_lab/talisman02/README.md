# TAL02 — THIÊN LÔI DẪN NÉT / Human / ART QA PENDING

**Canonical:** `tmb.skill.talisman.loi_phu.active_02.human`; lightning, `damage`, `line`, target cap 3, cast 0.62s, range 9.5, cooldown 10.8s, projectile_speed 0. All source numbers read-only; this is a view-only LAB with three fake target actors, never gameplay events.

**Distinct original art:** ten independent 1024×256 transparent auroral ink-brush poses (`assets/ink_stroke_00..09.svg`). Progressive paint envelope, wavering feather contour, uneven microfilaments, violet-lavender layered lightning core, momentary gold ink sparks. This is a **long drawn calligraphic current** rather than TAL01's traveling physical talisman; the family nevertheless shares the painted talisman master and restrained caster underfoot ritual seal. A shared family base is not independent artistic approval of this skill.

**Choreography:** 0–0.62s inscribe and underfoot pulse → 0.62–1.39s moving 10-pose ink-line reveal → 1.39–1.76s demonstration only three line contact cues → 1.76–2.72s fading, no status/false AoE.

**Reference:** 2026-11-14 owner screenshot provided seven art-layer types; original independently authored SVG poses, not cropped or redistributed commercial pixels. Individual frame geometry and internal lines differ (not a recolored generic icon). Art QA at native Godot 1280×720 is mandatory; Godot success is not owner approval. In this LAB display, target visual cues are predetermined for preview only; eventual real PvE shall require explicit confirmed event receipts.

**Scope:** `talisman02/**`, `vfx_tal02_contract_test.gd`, `vfx-tal-02-thien-loi-dan-net.yml`; no rig, no Codex, no PvE integration/feature gates. `OWNER_VISUAL_PENDING / PVE_INTEGRATION_HOLD / WINDOWS_ANDROID_PHYSICAL_PENDING`.

## R2 self-review fix
R1 actual Godot still at 1.08s revealed a stiff three-line neon tube, rejected internally despite tech PASS. R2 lowers the opaque ribbon atlas to atmospheric ink (~28%) and creates one slender living white-violet primary arc with tapered luminance, precisely two optional short branches, tip bloom and few subordinated glints. Does **not** increase declared hits/targets. Must render and visually inspect R2 actual frames before proceeding.
