# JX VFX Godot Library v1 — review

## Inventory evidence

- 889 WebP source records were checked individually against the existing v2 manifest by byte count and SHA-256.
- 793 unique SHA-256 payloads were retained; 96 byte-identical duplicate occurrences remain represented as separate source aliases in the catalog.
- Unique local WebP payload size: 73,072,062 bytes. Duplicate-inclusive source size: 78,147,850 bytes.
- Source counts: VLTK fx 49, JX fx collection 202, Đường Môn 46, Thúy Yên 4, VLTK native 588.
- 421 skill-to-layer metadata rows are attached to matching VFX records. Five raw SPR effects stay listed as `NOT_DECODED`; no decoder was installed.

## Metadata quality

- 384 records have frame geometry and explicit millisecond timing. They remain `ANIMATION_DATA_COMPLETE_ENGINE_PENDING` until a real Godot import/playback check.
- 14 records have frame rectangles but source `interval` timing whose unit is unverified. The player refuses timed playback for them.
- 37 records have no exact metadata join and remain static textures.
- 453 records have metadata that does not define complete frame geometry/timing; one separate grid record has a sheet dimension mismatch. The original payload is preserved and the limitation is explicit.
- The older `jx-idle-main` registry count of 191 exact metadata matches is stale: the focused `fx.js` cross-check linked all 202 inventoried sheets by exact filename and dimensions.

## Deliverables and QA

- Local SHA-deduplicated texture pool, portable metadata catalog, offline HTML gallery, Godot 4 project/gallery fixture, shared cached VFX player, selected-pack exporter, and a five-record sample pack.
- Four pre-existing v2 pilot conversions are included as reference fixtures without altering v2.
- Python unit tests: 9 passed. Full static payload/catalog QA: `STATIC_PASS_PENDING_ENGINE`, 793/793 payload hashes verified.
- Godot executable was not available. Godot import/playback and visual review are `PENDING_ENGINE` / `PENDING_VISUAL`; no engine PASS is claimed.
- Source material stays local for authorized experimental research; GitHub contains tools/schema/docs and metadata only, with zero image binaries.

## Limit

This is a reusable local study library, not production-approved game art. The catalog records source metadata as evidence, while runtime signals only report visual lifecycle; combat authority remains external.

