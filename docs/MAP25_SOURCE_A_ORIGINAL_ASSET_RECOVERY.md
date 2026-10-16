# MAP25 Source A asset recovery (exact original bytes only)

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
