# Fist Factory batch 1

Data-driven Factory adapters for 11 existing Human Fist LAB source scenes. The batch reuses their first-party SVG, WebP and PNG source masters; nine encoded WebP masters are losslessly decoded from the tracked `.b64` sources. It adds no drawn or recolored art.

Run `python3 godot/labs/combat_lab/fist_factory_batch1_20261125/build_batch.py` from the repository root to regenerate the decoded source copies, registry rows, Web Review rows and manifest.

All rows remain candidate-only: the ledger source gate is preserved, art approval is pending, and native capture is pending until the shared receipt runner succeeds. Fist14 uses its R5 source package only; the R7 and R8 G3 failures remain untouched. Six other Fist master IDs remain blocked in `batch_config.json` because their source LAB/art is absent or unavailable.
