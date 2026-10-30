# Godot runtime contract

`JXVfxPlayer` is a presentation-only view. Callers supply the effect id, parent node, local position, and optional presentation parameters. The library does not resolve combat outcomes.

## API

- `set_catalog(catalog)` installs a parsed `JXVfxCatalog`.
- `preload_effects(ids)` loads selected textures through the SHA-keyed cache and returns a failure count.
- `play(effect_id, parent, position, options)` creates one `Sprite2D` and returns a handle; zero means it rejected the request and emitted `effect_failed`.
- `stop(handle)` removes a visual instance.
- `release_unused(ids)` drops cached textures outside a caller-supplied keep set.
- Signals `effect_finished` and `effect_failed` describe visual lifecycle only.

Supported metadata: exact `n/d/w/h/ax/ay/ms` grids and in-bounds six-value frame rectangles with an explicit `frameMs`. Direction rows remain raw zero-based source indices. The source index's `interval` is retained as unverified and is never converted into milliseconds. Incomplete geometry and absent timing are not animated by the player.

Options are presentation parameters: `direction`, `loop`, `scale`, `rotation`, `alpha`, and `blend` (`MIX`, `ADD`, `SUB`, or `MUL`). The default is a one-shot. The caller owns the event timing, placement, and lifetime decision.

## Authority boundary

No callback or signal applies damage, healing, collision, target selection, range, combo, or status. A production combat system must provide authoritative positions and presentation events. Image regions are never hitboxes.

## Current evidence

Python static tests can validate the index and exporter. They cannot prove Godot parser compatibility, import results, playback timing, or runtime memory. Until opened and exercised in Godot 4.7.2, engine status remains `PENDING_ENGINE`.

