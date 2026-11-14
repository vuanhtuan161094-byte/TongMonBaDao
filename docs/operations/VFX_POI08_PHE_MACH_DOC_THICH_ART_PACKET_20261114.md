# POI08 — Phệ Mạch Độc Thích · Human — Art-first isolated Godot Combat Lab
Date: 2026-11-14 | PR #72 Draft | branch integration/pve-p0-playable-ui-20261103

## G0: Canonical contract
- Skill: `tmb.skill.poison.doc_cham.active_02.human`; name Phệ Mạch Độc Thích; poison school, Độc Châm branch, Human active_02.
- Exact canonical `godot/data/combat/v63_human_combat_catalog.json`: effect poison, element nether, shape single_target, radius 0, cap 1, range 7.5, cast 0.45, projectile speed 8, cooldown 9, duration 8, poison_stacks 1, damage_ratio 1.1. Metadata only. Do not invent extra hits/DoT/status authority.
- `V63FeatureGates` remains OFF. Combat V2/SaveService/PvE untouched. Skill scene is VIEW-ONLY with illustrative timed placement rather than real receipts.

## G1–G3: Original source art
- First-party Pillow source `tools/vfx/generate_poi08_phe_mach_thorn.py`; no copying or reskinning POI07, Source A, JX, Võ Lâm or Source VL pixels.
- 12 authored twin-braided thorn sprites `phe_mach_thorn_12.png` (4x3, 384x192 per frame, 1536x576); separate 8-pose five-droplet venom convergence `phe_mach_charge_08.png` (4x2, 256x256, 1024x512); independent 12-pose living vessel/vein body imprint `phe_mach_vein_12.png` (4x3, 320x320, 1280x960). Three original material silhouettes are distinct from POI07.
- Render independent alpha masks / violet-jade ink / creamy focal reflection. Four-cell-edge alpha must be zero; all frames nonempty.
- Storyboard: t=0–.45 palm charge; .45–1.39 **STRAIGHT** constant-speed thorn from palm to one chest; 1.39–9.39 one stationary local 8-second venom imprint at exactly one target; 9.39–9.72 fade; 9.72–10.15 no VFX. Never represent eight visual seconds as eight damage ticks.

## G4–G7: Native Godot and art assessment
- Scene `res://labs/combat_lab/poison08/phe_mach_doc_thich.tscn`, script `.gd`, contract `res://tests/labs/combat_lab/vfx_poi08_contract_test.gd`.
- Workflow `.github/workflows/vfx-poi-08-phe-mach-doc-thich.yml`: official SHA256-pinned Godot 4.7.2 GL Compatibility, Stage A actor restored, generator, alpha gate, strict import, GDScript parse, focused test, authentic 1280×720 609-frame fixed-clock native movie, H264 MP4, 14 temporal frames, GIF, checksums.
- POI08 R1 source SHA `4ecd092cee68f80be011fdc1ed062bcbd068642f`: [native run #43622610895](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43622610895) SUCCESS; binary assets subsequently committed safely to current PR branch in `30d4a9d1f1f43011d2ceed1f6e843ffcfb59f9e8`, with [same-SHA run #43622776552](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43622776552) SUCCESS.
- R1 native stills at 1.58 and 4.00 revealed local poison-imprint opacity too weak at 1×. R2 polish code commit `ddc06215fa2f0d1f5085933070f21011bdbbac6a` makes transient puncture clearer, enlarges persistent local vein to 0.72 scale and lowers it 6 pixels from face. This does not add another target, damage event or status application.
- R2 exact-SHA QA and native visual review: **PENDING until workflow completion**; never inherit R1 PASS for R2.
- Owner visual gate: **PENDING**; separate physical Windows/Android QA **PENDING**, PvE integration **HOLD**, V6.3 OFF. User may review video and request art iteration. No rig, Codex, new branch or merge.


## POI08 R2 native proof — 2026-11-14
- Exact R2 tested code SHA `ddc06215fa2f0d1f5085933070f21011bdbbac6a`: [official Actions #43623064599](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43623064599) **SUCCESS**, [native artifact #14125246358](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43623064599/artifacts/14125246358).
- SHA256-pinned official Godot 4.7.2 GL Compatibility; strict project import, GDScript parse, focused `VFX_POI08_RESULT=PASS failures=0`; real native 1280×720 609 frames, 10.15s, fixed 60fps encode, H264 MP4, GIF, 14 native stills with checkpoints including t=4.00, 8.60 and 9.76, logs and media hashes. Downloaded artifact independently and confirmed **16/16 SHA256 media checksums**. Encoding FPS is not measured Android/Windows performance.
- R1 inspection revealed faint sustained chest vein; R2 enlarged/brightened original baked imprint while moving center +6 pixels down and preserving actor-face legibility. Actual R2 1×/zoom stills inspected; distinct braided flight, single localized vein target and no other target affected. Do not call the illustrative 8s visual a real status receipt.
- POI08 artwork remains `OWNER_VISUAL_PENDING`, live `PVE_HOLD`, V63 OFF and device QA PENDING. The original POI06 R11, POI07 and gameplay authority files are protected.
