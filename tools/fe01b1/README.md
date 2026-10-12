# FE-01B1 — Portable verified-pack exporter

Scope: isolated candidate-pack transport tooling ONLY. No Source A binary is stored
in TongMonBaDao and no scene, gameplay, Git LFS or approved visual is modified.

Paths:
- tools/fe01b1/export_verified_pack.py (new standalone exporter)
- tools/fe01b1/test_export_verified_pack.py (19 synthetic fixture tests)
- .github/workflows/fe-01b1-asset-exporter.yml (official Godot 4.7.2 gate)

Windows READ-ONLY example (run from the TongMonBaDao repo root):

    $py = 'C:\Users\Admin\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
    & $py '.\tools\fe01b1\export_verified_pack.py' building.main_hall --catalog 'E:\TongMonIntegrationLab\TransferKit\Catalog\BUILDING_VISUAL_INDEX.csv' --source-root 'E:\GameAssetExtract' --source-prefix 'E:\GameAssetExtract' --output-root 'E:\TongMonIntegrationLab\TransferKit\GodotPacks' --dry-run

Expected: DRY_RUN ... files 4. Do NOT remove --dry-run without
independent FE-01B2 user authorization. The old TransferKit exporter previously
passed a Windows dry-run, but the NEW tool is not yet Windows-tested.

All roots are configurable. If --source-root is given, --source-prefix must
also identify the original absolute prefix stored in Source A catalog paths.
Without both, the exporter reads absolute paths directly from the catalog.
Catalog is an external CSV, not a bundled source binary.

Exporter contract:
1. Validate source file existence, byte length and SHA-256 before writing.
2. Reject unsafe logical IDs, duplicate/case-colliding names and escaped paths.
3. In write mode, acquire exclusive per-pack lock, create a private staging
   directory on same output filesystem, verify SHA during and after copying.
4. Publish a complete verified directory via rename only after final checks;
   never overwrite an existing pack. Return UNCHANGED only after verifying
   exact files and source hashes. Refuse invalid existing directories.
5. On failure, remove only the tool's staging directory and own lock.
   A stale lock left by a crash needs manual investigation.
6. The lock protects concurrent cooperating exporters, not arbitrary external
   writers deliberately racing the destination on all operating systems.

Fixture tests (no Source A data):

    & $py -m unittest discover -s '.\tools\fe01b1' -p 'test_*.py' -v

Rights policy: A_USER_AUTHORIZED_LAB does NOT establish redistribution
or commercial release permission. release_rights remains UNVERIFIED.
EXPORTED means checksum-correct lab copy, not imported Godot art, a rendered
building, Spine animation, recovered historical S3 image or publication right.

Status at official CI: Linux Godot 4.7.2 focused + regressions PASS at
https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38213775069
Windows new-tool CLI, Main Hall real-pack export, LFS push/pull, game
visual/click/APK and release rights: PENDING, separate authorization.
