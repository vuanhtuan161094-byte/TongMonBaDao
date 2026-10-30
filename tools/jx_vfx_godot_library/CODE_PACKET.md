# CODE packet — JX VFX Godot Library v1

- Base: `main` at `c0c1382f119599497b52d8ee8abd9e830a883f1e` (rechecked 2026-10-30).
- Additive path: `tools/jx_vfx_godot_library/**` only.
- Purpose: standalone local catalog/build/export tools, offline gallery, and a presentation-only Godot 4 player fixture.
- Authority: no game runtime wiring, combat collision, damage, healing, targeting, range, combo, or status mutation.
- Local payloads: source WebP binaries and machine-specific roots remain outside GitHub. The PR contains code, schema, evidence notes, and a five-record metadata fixture only.
- Validation: `python -m unittest discover -s tools/jx_vfx_godot_library/tests -v`; run the library's `static_qa.py` against the local output. Godot 4.7.2 is not installed, so parser/import/runtime QA remains `PENDING_ENGINE`.
- Exclusions: PR #52, PR #53, all gameplay changes for V6.3/V6.4, Source A files, JX binary assets, branches, saves, and any game integration.

