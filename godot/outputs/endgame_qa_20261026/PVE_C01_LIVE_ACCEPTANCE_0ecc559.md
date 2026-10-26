# Thanh Trúc Lâm C01 — acceptance evidence

Code SHA: `0ecc559cd84c460df9885ab56edc3607a405df0b`

Engine: official Godot 4.7.2 stable, Windows, 1280×720.

## PASS

- P3.2 creates a real, canonical V2 party of six recruited disciples and enters C01 against ten MonsterCatalogue actors. At the rendered GUI capture, Combat V2 had made 43 actions, moved actors, killed one monster, and all six disciples were still alive.
- The live Thanh Trúc Lâm map shows all 20 site positions; only C01 is active. Its fixed minimap reads the same Combat V2 snapshot for party, monsters, camps and camera. Panning and zooming are exercised by the integration test.
- The P3.2 live integration test passes SaveService save/reload with the active run, combat snapshot, kill journal and no reward receipt/claim duplication.
- Focused regression: `32/32 PASS`; the dedicated P3.2 live integration test also passes. Logs are under `logs/`.

## Pending / failed

- Per-monster loot remains `LOOT_PENDING`: no approved species drop table was found. No loot was fabricated. The existing region-clear reward is only eligible after a full C01 victory.
- Respawn timing and C02–C20 live combat are not implemented. The map displays these as locations, not active battles. Expansion to five teams and 200–400 live monsters is pending C01 owner QA.
- GUI harness capture passes, but the separate normal-game launcher smoke failed with a Windows `Application Error` (“The memory could not be written”). Its cause is not isolated, so no launcher is delivered. Manual mouse play in the normal game window remains pending.
- A later repeat capture used to try a separate demo-save copy failed the six-live-disciple timing assertion; it produced no save or image. The committed earlier frame on this same code SHA shows all six alive. This makes six-alive capture timing variable.
- No full/CI run, push, or merge was performed.

## Evidence files

- GUI frame: `gameplay/pve_multicamp_c01_live_1280x720_final.png`
- GUI capture and live integration: `logs/pve_multicamp_gui_capture_final_0ecc559_20261026.log`
- Dedicated Save/Load integration: `logs/pve_multicamp_p3_2_live_final_0ecc559_20261026.log`
- Focused suite result index: `logs/focused_32_final_0ecc559/results.csv`
