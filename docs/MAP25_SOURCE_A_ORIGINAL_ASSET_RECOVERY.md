# MAP25 Source A asset recovery (exact original bytes only)

## 2026-10-17 — MAP25 Source A archive recheck; Python restore contract 4/4 PASS; genuine art BLOCKED

**PR #18 starting HEAD:** `8ec1079681733fbb1f458620f81044111cfc3c78` (DRAFT, base PR #9). `main` was independently checked at `461caca1171462e0da092f21108c5c1733157ad9` and was not targeted for edits. This is a **docs-only evidence update**; source/renderer/gameplay binaries were not changed.

**Byte-access attempts, current session:** No conversation-mounted files. Library records include `TongMonBaDao_ENV02A_192World_Lab.zip` (3,425,000 bytes), `TongMonBaDao_ENV01_SourceA_Map_Lab(1).zip` (3,403,950 bytes), and `SourceA_Map_Prep_20261012.zip` (28,000,430 bytes); attempts to materialize `raw_file` from each failed with **"This Project file does not have an authorized raw-byte materialization path."** Archive filenames/sizes are metadata only; no actual ZIP or PNG bytes were obtained. GitHub PR #18 recursive tree (617 entries) has **0 PNG/ZIP files**; Source Knowledge main recursive tree (26,256 entries) has **0 PNG/ZIP files**; game repo releases returned none. Workflow artifacts could not be enumerated via the available approved GitHub read endpoint (not evidence that none exist).

**Hash/provenance boundary:** live ENV-02A baseline has 35 entries; the production allowlist has **32/32 matching SHA-256 strings and exact destination paths**: PV01 buildings 3, terrain 4, roads 6, vegetation 19; the other 3 baseline entries are previews/evidence excluded on purpose. This is **manifest-to-manifest textual verification**, not a hash of recovered image bytes. Actual original PNGs verified `0/32`, imported `0/32`, visibly Source A sprites in main map `0/32`; procedural fallback stays active.

**New actual focused Python test evidence:** retrieved GitHub files `tools/assets/restore_map25_env02a_art.py` (Git blob SHA-1 `de03d2d6e1c1c8da3605d6e7b5d89a9d25570cec`) and `tools/assets/test_restore_map25_env02a_art.py` (Git blob SHA-1 `5fb4a569a2317f7c79f39b99e71fd4f501895483`). Both local test copies were independently confirmed `git hash-object` byte-for-byte identical to the GitHub blobs. Ran `python3 -m unittest -v test_restore_map25_env02a_art.py`: **4 tests, 4 PASS, 0 FAIL, 0.012 s**. Cases: SHA match independent of archive name and idempotence, missing image fail-closed, modified image rejection, refusal to overwrite unrelated existing content. Tests use synthetic PNG-named byte fixtures and do **not** prove real 32 PNG provenance, valid Godot texture decoding, or atomic recovery from an interrupted OS move.

**Status / gate:** Original art recovery BLOCKED BY AUTHORIZED RAW-BYTE ACCESS, not CLOSED. `SectMap25SourceArt` / `SectIsometricWorldV1` previous map code is unchanged. Godot 4.7.2 parser/import/scene runtime, visual Y-sort/footprint/camera/hitbox, Windows screenshot, Android touch/performance, SaveService/O6==4/O8/One Active Job/SAFE/full cumulative regressions are **PENDING/NOT RUN at this PR HEAD**. No CI was invoked; no merge/force-push/main edit. Next action remains obtaining the original authorized ZIP **as accessible raw bytes**, then executing the existing read-only SHA gate before 32/32 import; never substitute preview/fake Source A assets or open gameplay/paid construction.

---

## Repository checkpoint 2026-10-16

Original ENV-02A zip was discovered as metadata in the owner's Library
(`TongMonBaDao_ENV02A_192World_Lab.zip`, 3,425,000 bytes), but its raw
content was **not retrievable** through the authorized file-copy operation.
Actual original PNGs validated/imported: **0/32**. Archive identity by name
does not prove content identity or original file SHA-256.

Automated restore tool `tools/assets/restore_map25_env02a_art.py` and four
contract regression tests `tools/assets/test_restore_map25_env02a_art.py`
committed at SHA `5748bdc26ef91585e42d2ee73719b0ace6428a14`. Both Python test and Godot runtime gate remain
**NOT RUN**. No source art PNG, fake asset or gameplay file changed.
**Repository PR #18 still contains no source art PNGs.** This folder houses
only an optional restoration script, not replacements for the original art.

Archive evidence: the file `TongMonBaDao_ENV02A_192World_Lab.zip` was
located in the user's ChatGPT Library (3,425,000 bytes), but Library raw-byte
materialization failed with *"This Project file does not have an authorized
raw-byte materialization path"*. Merely locating its metadata does NOT
establish access to any contents, any verified PNG hash, or successful import.

Once an authorized copy becomes accessible as a local file in a future
environment, use the one-shot validation/import script (Python 3 standard lib):

```bash
python tools/assets/restore_map25_env02a_art.py --archive /path/to/TongMonBaDao_ENV02A_192World_Lab.zip
python tools/assets/restore_map25_env02a_art.py --archive /path/to/TongMonBaDao_ENV02A_192World_Lab.zip --import
```

- Default run is read-only.
- All 32 curated PNGs must SHA-256 match **both** the canonical ENV02A
  manifest and the MAP25 runtime index. Source archive entry names are not
  trusted; the original bytes are matched cryptographically.
- Missing, corrupt or renamed-with-changed-bytes artwork fails closed, with
  a list of exactly which originals are unavailable. Existing unverified
  destination files are never overwritten.
- `--import` restores only the accepted images to
  `godot/art/source_a_env02a/{env01_assets,pv01_assets}/...`.
- This source-root path is read by `SectMap25SourceArt`; true art only appears
  after original PNG bytes are available and the Godot art gate is tested.
- There is no independent map/layout scheduler, currency or save authority.

Godot 4.7.2 importer, live 1280×720 visuals, Android touch, performance,
art provenance/redistribution checks and full regression remain **PENDING**.
No CI/merge main was requested or performed.
