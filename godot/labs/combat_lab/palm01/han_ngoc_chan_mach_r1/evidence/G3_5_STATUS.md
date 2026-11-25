# Hàn Ngọc Chấn Mạch R1 — G3.5 native preview status

**Focused receipt test:** `PASS`, 15 checks, exact Human skill ID.
**Native G3.5 technical preview:** `PASS` on Godot 4.7.2 / Xvfb / ffmpeg.
**Source art / owner review:** `G3 source self-review PASS`; `OWNER_VISUAL_PENDING`.
**PvE / V6.3:** `HOLD_V63_OFF`; no game gate was enabled.

The native workflow ran on exact source SHA `2d5629b9011f216de1d169133632d7040636ae16`: [run 45570479105](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/45570479105). Strict import and parse, the focused contract, native scene marker, and V4 evidence validation passed. The local headless dummy renderer had blocked viewport capture earlier; the Xvfb workflow produced the native 1280×720 proof and cleared that technical blocker.

The archived phase frames show the AS60 body-only candidate with the walking V5 Source A monster actor. Charge is visible at the caster palm during windup, the broad pressure wave appears after the actual one-target release receipt, and one compact contact glint appears on the target. The focused test and LAB each record one positive `v63_skill_hit` (`damage=40.8`) on the moving target, with no status, heal, cleanse, or slow event. `MapBattleV2` is only an isolated in-memory preview fixture: there is no SaveService, live PvE, or persistent game write.

Persistent native evidence is stored beside this status file:

- `G3_5_NATIVE_R1_2d5629b9.mp4` — short 1280×720 clip.
- `G3_5_NATIVE_CHARGE_2d5629b9.png`, `G3_5_NATIVE_PEAK_2d5629b9.png`, and `G3_5_NATIVE_CONTACT_2d5629b9.png` — exact phase frames.
- `G3_5_V4_MANIFEST_2d5629b9.json` — exact-SHA machine-readable evidence manifest.

The 3D/monster species-to-art link and AS60 body art remain candidate/pending. This G3.5 technical and visual preview does not approve source art, grant owner approval, establish four-direction support, or replace physical device QA.
