# Fist Factory batch 1

Data-driven Factory adapters for 11 existing Human Fist LAB source scenes. The batch reuses their first-party SVG, WebP and PNG source masters; nine encoded WebP masters are losslessly decoded from the tracked `.b64` sources. It adds no drawn or recolored art.

Run `python3 godot/labs/combat_lab/fist_factory_batch1_20261125/build_batch.py` from the repository root to regenerate the decoded source copies, registry rows, Web Review rows and manifest.

All rows remain candidate-only: the ledger source gate is preserved, art approval is pending, and shared native capture passed for 11 skills (41 accepted MapBattle fixture events, 0 synthetic) at 1280×720/20 FPS. The combined H.264 movie, receipt-timed contact sheet and index are in `review/native/`. Owner visual review remains pending; PvE remains HOLD. Fist14 uses its R5 source package only; the R7 and R8 G3 failures remain untouched. Six other Fist master IDs remain blocked in `batch_config.json` because their source LAB/art is absent or unavailable.
