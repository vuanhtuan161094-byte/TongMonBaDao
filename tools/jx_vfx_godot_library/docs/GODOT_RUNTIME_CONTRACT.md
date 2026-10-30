# Godot runtime contract

`JXVfxPlayer` is a presentation-only view. Callers supply the effect id, parent node, local position, and optional presentation parameters. The library does not resolve combat outcomes.

## API

- `set_catalog(catalog)` installs a parsed `JXVfxCatalog`.
- `preload_effects(ids)` loads runtime frame textures through a `res://` resource-path cache and returns a failure count.
- `play(effect_id, parent, position, options)` creates one `Sprite2D` and returns a handle; zero means it rejected the request and emitted `effect_failed`.
- `stop(handle)` removes a visual instance.
- `release_unused(ids)` drops cached textures outside a caller-supplied keep set.
- Signals `effect_finished` and `effect_failed` describe visual lifecycle only.

Supported metadata: exact `n/d/w/h/ax/ay/ms` grids, in-bounds six-value frame rectangles with explicit `frameMs`, and frame-preserving `paged_rects` created for texture-size limits. Direction rows remain raw zero-based source indices. The source index's `interval` is retained as unverified and is never converted into milliseconds. Incomplete geometry and absent timing are not animated by the player. Optional transparent edge padding must be explicitly requested for a selected record and is recorded as a runtime transform; the source record dimensions and SHA-256 remain provenance fields.

Options are presentation parameters: `direction`, `loop`, `scale`, `rotation`, `alpha`, and `blend` (`MIX`, `ADD`, `SUB`, or `MUL`). The default is a one-shot. The caller owns the event timing, placement, and lifetime decision.

## Authority boundary

No callback or signal applies damage, healing, collision, target selection, range, combo, or status. A production combat system must provide authoritative positions and presentation events. Image regions are never hitboxes.

## Resource loading and packaging

The player loads imported textures with `ResourceLoader.load("res://...")`, not by opening an absolute source path or constructing an `ImageTexture` from a disk file. A selected-pack export generates `godot/scripts/jx_vfx_resource_manifest.gd` with static `preload()` references for every source/runtime resource that the gallery/player addresses dynamically. This lets Godot include those dependencies in an exported PCK. Import and project-copy tests alone do not prove an exported build; export templates, a preset, and a successful launch from the built package are still required for that claim.

## Current evidence

Python static tests can validate the index and exporter. They cannot prove Godot parser compatibility, import results, playback timing, or runtime memory. Record import, focused runtime, GUI playback, and exported-PCK evidence separately; do not infer one gate from another.

## Engine gate evidence, 2026-10-30

Selected-pack results: Godot 4.7.2 import PASS; 14 focused runtime checks PASS; actual OpenGL GUI playback PASS for three effects. A clean extracted project copy passed with all listed package hashes verified. This does not claim full-library re-import, exported PCK validation, owner visual approval, or combat integration. See ENGINE_GATE_V1_1.md and ENGINE_GATE_EVIDENCE_V1_1.json.
