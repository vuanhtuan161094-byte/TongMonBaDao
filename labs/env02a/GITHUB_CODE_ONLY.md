# ENV-02A — text-only GitHub mirror (NOT the runnable art pack)

Owner authorized isolated ENV-02A ONLY. This directory stores the real, versioned GDScript code, scenes, launchers, QA scripts and SHA manifests extracted from the local ENV-02A 192-world ZIP. All paths are confined to `labs/env02a/`; `godot/` production is unchanged.

**No Source A PNG/ZIP binary is committed:** per `docs/P3_ASSET_MAP_ENVIRONMENT.md`, the P3 registry and ADR-0002 transport constraints. A Git checkout of this directory **is not a playable/renderable complete project** without the matching 35 hashed PNGs from the archived owner-supplied ENV-02A ZIP (keep this ZIP intact). Restore all assets to the relative paths in `ENV02A_BASELINE_ASSET_SHA256.json` and run `tools/verify_env02a_static.py` before testing. Do not fabricate missing art or pull unverified files.

- `python3 labs/env02a/tools/verify_env02a_code_only.py` works on text-only checkout and checks source references and boundary invariants; **never a Godot PASS**.
- `tools/verify_env02a_static.py` needs the full asset pack; verifies all 35 PNG hashes and geometry (still NOT runtime).
- `RUN_ENV02A_WINDOWS.cmd` and the real Godot 4.7.2 gate need Windows + original PNGs; Godot import, 20×13 regression, ENV-02A 192×192/door/AStar/chunk runtime, interactive screenshot are PENDING USER.
- Android 1280×720 landscape touch/benchmark **PENDING USER**.

No FE-02, ENV-02B–E, free placement/unlock, new simulation authority, S3 art replacement, save change, or Spine integration was authorized. DV2-03 remains PAUSED NOT CLOSED. This mirror does not close ENV-02A.