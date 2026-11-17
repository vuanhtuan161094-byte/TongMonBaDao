# PAF04 R1 — Hộ Mệnh Lưu Văn: transparent glass energy VFX

Owner accepted PAF03 R3 provisionally and asked next Phù Tu skill to use crystalline luminous energy, light that feels like transparent glass with depth rather than solid colored sheets. Owner current VFX V4.3 explicitly forbids creating GIF by default, so produce actual Godot MP4 + native 1x screenshots only.

## Canonical contract
ID `tmb.skill.talisman.phong_an_phu.active_04.human`. Guard (mitigation), wind, single_target cap1, ai_profile=runtime_self_guard => **SELF only**, cast0.5s, guard duration4s, cooldown13.6s, range8.5, hit_count1 (catalogue), power0.16, projectile speed0, damage0. Actual CombatV2 guard receipt unknown.

## Art and clock
First-party original supersampled high-res true-RGBA 12 charge,16 glass-back,16 glass-front,14 lock,8 caustic fragments,8 tiny status badge key poses, 2 original master PNGs and the durable painter `tools/vfx/paf04_glass_guard_assets.py`. Shell is irregular faceted semi-transmissive color with restrained gold-white refraction edges; actor face remains unobstructed. Not a circular flat HUD shield, not a copied PNG, not rigged.

Three separate clocks: canonical cast0.5 and 4s guard, scene formation .55-.82, synthetic guard lock .82-1.30, full active light fade1.48 (shimmer to1.67), video 2.0s / 120 encoded frames at60 FPS. The four-second buff duration has separate temporal tests at .88/3.4/4.81/4.83; do not animate a stationary aura for 4s. This LAB demonstrates only a cosmetic simulated guard on moving SELF. No CombatV2/SaveService/PvE edits, no Codex/new branch/merge.

## QA contract
Native Godot 4.7.2 Compatibility at exact commit: source and V4 schema + atlas/alpha; actual moving-WALK self, G3.5 charge .30 / peak .72 / shield lock .99 at 1280x720, short MP4 with 16 checkpoint images, focused contract, exact SHA + missing-contact fail-closed. Visual score judged separately; do not claim owner approved art from CI PASS. PvE/V6.3 and physical Windows/Android performance QA on HOLD.

## R2 source correction after real R1 G3.5 art self FAIL
R1 technical run [#43994948917](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43994948917) PASS on commit `43f9f2e292efd70fdfff12e876f8561298c09775`, but real charge/peak/lock Godot 1x screenshots show rigid green transparent rectangles vertically hovering over caster. R1 self ART FAIL (not owner accepted). R2 replaces whole glass shell source shape with 13 curvilinear refractive feather panes, pearlescent lit edges, low alpha organic lens, freehand caustic streaks and independently animated 16 front+16 rear key frames around a WALK SELF target. No gameplay, cast, status timing, face layering, or copied external assets changed. R2 requires new exact SHA proof before technical or art acceptance.
