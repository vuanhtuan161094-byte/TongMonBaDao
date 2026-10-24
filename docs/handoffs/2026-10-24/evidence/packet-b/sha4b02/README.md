# Packet B exact-SHA evidence — 4b02a0c

- Code/test SHA: `4b02a0c61a2771d9d4638129d96b68ad292270dc`; tree `352700b65d3cd0ef7039df22a1153d81b2fd7b82`.
- Official Godot: `4.7.2.stable.official.ed1daf0bf`.
- Focused suite: 28/28 PASS; edge contract 56 checks PASS; O9 PASS.
- Integrated GUI: 19 real P3.2 frames at 1280×720; captured burn, Weaken, learned guard active/expired, committed loot, same-world respawn, return and SaveService reload.
- `capture_state_manifest.json` contains scene, runtime world/events, actors, status records, receipts, save/load values and per-frame samples.
- `source_manifest.json` lists code/asset/screenshot hashes and portable package hash.
- `focused_results.csv` and `logs/focused/` contain exact commands/results and per-test Godot logs. `run_focused_suite.ps1` is the runner used for the final focused pass.
- `logs/p3_2_packet_b_capture_sha4b02.log` is the actual Godot capture log.
- Portable project launcher and Vietnamese instructions are copied under `windows_candidate/`; ZIP is a local artifact, not checked into Git due its 48 MB size.
- Human Windows, Android, sustained performance and Owner Visual remain PENDING.
