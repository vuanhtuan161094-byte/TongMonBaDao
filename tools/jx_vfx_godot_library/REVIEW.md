# JX VFX Godot Library v1 — review

## Inventory evidence

- 889 WebP source records were checked individually against the existing v2 manifest by byte count and SHA-256.
- 793 unique SHA-256 payloads were retained; 96 byte-identical duplicate occurrences remain represented as separate source aliases in the catalog.
- Unique local WebP payload size: 73,072,062 bytes. Duplicate-inclusive source size: 78,147,850 bytes.
- Source counts: VLTK fx 49, JX fx collection 202, Đường Môn 46, Thúy Yên 4, VLTK native 588.
- 421 skill-to-layer metadata rows are attached to matching VFX records. Five raw SPR effects stay listed as NOT_DECODED; no decoder was installed.

## Metadata quality

- 384 records have frame geometry and explicit millisecond timing. These records were still checked individually for engine suitability; only the bounded selected pack received this Godot runtime pass.
- 14 records have frame rectangles but source interval timing whose unit is unverified. The player refuses timed playback for them.
- 37 records have no exact metadata join and remain static textures.
- 453 records have metadata that does not define complete frame geometry/timing; one separate grid record has a sheet dimension mismatch. The original payload is preserved and the limitation is explicit.
- The older jx-idle-main registry count of 191 exact metadata matches is stale: the focused fx.js cross-check linked all 202 inventoried sheets by exact filename and dimensions.

## Engine gate v1.1

- Godot 4.7.2 stable official was found at E:\Godot_v4.7.2-stable_win64_console.exe.
- The clean extracted three-record Selected Pack imported successfully: 18 resources, 3 WebP import sidecars, exit code 0, no parser/import/resource failures.
- Focused runtime: 14/14 checks passed, including grid, irregular rectangles, paging, true alpha, frame timing, direction 15, play/stop/loop, cache lifecycle and 1/3/10/30 instances.
- Actual OpenGL GUI playback changed frames for Đường Môn m38, Thúy Yên m146 and VLTK 01744d1a at tested 48/64/75/96 px sizes.
- m38 is sparse and difficult to read at 48–64 px in the capture; owner visual approval remains pending.
- Clean project-copy portability passed with 21/21 package checksums valid and no machine-absolute runtime resource paths.
- Exported PCK/EXE remains pending because the matching 4.7.2 export templates were absent. The full 793-unique-texture library was not re-imported because the sandbox could not write its external .godot cache.
- Python unit tests: 9 passed. Static QA on the selected records verified all 3 source payload hashes.
- Local reports and Godot captures are in the Asset Studio artifacts folder. The GitHub change contains no JX binary payloads or machine-specific source paths.

## Limit

This is a reusable local study library, not production-approved game art. The catalog records source metadata as evidence, while runtime signals only report visual lifecycle; combat authority remains external. A selected combat integration prototype can begin after owner review of scale/readability. The exported-pack gate remains separate and pending.
