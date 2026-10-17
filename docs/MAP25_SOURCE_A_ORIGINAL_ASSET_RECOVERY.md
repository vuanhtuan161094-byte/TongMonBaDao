# MAP25 Source A asset recovery (exact original bytes only)

## 2026-10-17 — MAP25 ORIGINAL SOURCE A ART IMPORTED TO GITHUB (32/32) — Godot runtime/visual PENDING

**Direct GitHub confirmation (not merely owner transcript):** the owner's Windows FIX4 import completed with process exit 0 and remote fast-forward success. Draft [PR #18](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/18) HEAD immediately after the asset commit was [`10c85e80067a81be98a29a97a5d30c434997b7bf`](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/10c85e80067a81be98a29a97a5d30c434997b7bf), parent `4806ec8c3312a362184293c1bb9d3da4de86a27a`; GitHub compare confirmed exactly **1 commit / 32 added files / zero other files**, all under `godot/art/source_a_env02a/`. GitHub recursive tree confirmed 32 physical PNG entries: **3 PV01 buildings, 4 terrain, 6 roads, 19 vegetation**. Draft not merged; main not touched by the tool. Source transport SHA-256 `8b3976e2f7400063798fbac88ced5d85c24beee9aa057e369fdbfc937cf3f920`, 32/32 actual PNG SHA-256 matched both source manifests per Windows transcript; owner-supplied log `MAP25_IMPORT_RESULT_20261017_094701.log` shows successful non-force push. Existing PNG byte hashes match original verified source archive, not invented art. **The prior binary-access and GitHub-import blockers are CLOSED.**

**Strict QA boundary:** launcher output `WARNING: Godot 4.7.2 not confirmed; ... Found: 4.7.2.stable.official.ed1daf0bf` was a detection/validation issue in the launcher, **not** evidence of an engine installation failure. It did not run official Godot importer/three focused tests before pushing. **Godot 4.7.2 import/parser, asset-gate accepted=32, isometric projection, real main scene/workforce, Windows 1280×720 screenshots, Android mobile gestures/performance and cumulative O6/O8/SAFE/One Active Job regressions remain PENDING**. Do NOT mark MAP25 visual/runtime PASS based on a successful upload or JPEG/PNG integrity alone. Art changes only; no gameplay/renderer code edits, no manual CI, no merge.

**Next required step:** official Godot 4.7.2 Windows QA in a disposable clone of PR #18 (keep user:// save namespace isolated), run `sect_map25_verified_art_gate_test.gd`, `sect_iso_projection_contract_test.gd`, and `sect_iso_main_integration_test.gd`; collect per-test stdout/stderr/exit code, and inspect a genuine 1280×720 scene screenshot. Once runtime gate and visual are clean, pilot one existing Batch-01 `1113028_1` female rig (`stand/walk`) in the genuine scene; do not reconvert the entire batch or pretend Android PASS. When these docs are committed after the art commit, **always use the new live PR HEAD**, not the old art commit, for the QA checkout.

---

## 2026-10-17 — Source A ORIGINAL PNG BYTES RECOVERED 32/32 from owner upload; repo import pending

**Authorized raw source now available:** owner attached `SourceA_Map_Prep_20261012(1).zip`, size **28,000,430 bytes**, full ZIP SHA-256 `c453ef9e0a2762be0c6d17599d5736cb6b7e250ba11b6c9753efc8c1fd70f1a4`; ZIP enumerated with Python (`428` members). This **supersedes only the earlier missing-raw-file blocker**; original Library `TongMonBaDao_ENV02A_192World_Lab.zip` remains inaccessible but is no longer needed.

**Actual original PNG SHA-256 verification:** scanned each PNG member by decompressed-byte digest, ignoring untrusted filename. Against `godot/data/presentation/map25_source_a_verified.json` (which is 32/32 equal to `labs/env02a/ENV02A_BASELINE_ASSET_SHA256.json`), found exact original PNG bytes for **3/3 PV01 buildings, 4/4 terrain, 6/6 roads, 19/19 vegetation = 32/32 PASS**, **0 missing / 0 tampered**. Pillow loaded/decoded all 32 PNGs as RGBA with nonzero dimensions; untouched original bytes retained. Owner-source metadata + crypto hashes demonstrate pack integrity; this is **not Godot runtime acceptance**.

**Prepared verified transport archive:** `MAP25_VERIFIED_32_SOURCE_A.zip`, 32 original PNGs in proper curated `source_a_env02a/...` destinations, size `2,172,522` bytes, SHA-256 `8b3976e2f7400063798fbac88ced5d85c24beee9aa057e369fdbfc937cf3f920`. This is NOT fabricated artwork and is NOT a PR file yet.

**Delivery boundary:** current sandbox can verify uploaded binary but cannot send the resulting binary directly into authenticated GitHub writes from its byte store. **Do not state that assets have been committed or Godot has displayed them.** Instead, a separately packaged, protected one-click Windows import/commit tool will use the existing repo `tools/assets/restore_map25_env02a_art.py`, check the exact draft PR head, stage only 32 art paths on a **fresh isolated clone** and fast-forward push with no CI invocation. If clone credentials/runner are unavailable, remain BLOCKED ON BINARY PUSH; do not overwrite the user's working repository, do not merge main, and do not claim runtime PASS.

**Actual local evidence:** ZIP byte access PASS, 32/32 image hash PASS, 32/32 Pillow PNG decoder PASS, curated transport zip 32 members. Official Godot 4.7.2 importer, SHA-gate focused test, 2.5D projection, main scene/headless + Windows GUI/screenshot, mobile gestures and cumulative backend regression are **NOT RUN/PENDING** at the inspected PR HEAD. Previous 4 synthetic Python tests PASS remain independent historical proof.

---

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
