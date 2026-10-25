# TÔNG MÔN BÁ ĐẠO — CHATGPT WORK ENTRYPOINT — CODE-R0

> **Owner checkpoint, 2026-10-25 (Asia/Bangkok).** Work item to execute, not a claim of green CI. The owner confirmed that **GitHub Actions quota/minutes are exhausted**. Treat that as the current operational blocker, not as a proven software regression. **Do not rerun GitHub-hosted Actions** while quota remains unavailable.

## 0. Authority / scope / identity
- Repo: [vuanhtuan161094-byte/TongMonBaDao](https://github.com/vuanhtuan161094-byte/TongMonBaDao) (private). Requires authorized GitHub access.
- **Working branch**: `qa/code-r0-finite-world-20261025`, diverged exactly from **CODE-CLEAN BASE** `5fbdbc6309c3f1386f0d8b619831e007c5a52824`.
- **Pre-handoff reviewed SHA**: `a9ad9c8a4bf30656f4f7372335bb977f8ce67e0e` (the last exact SHA before creating this Work handoff). **Start from the latest HEAD of the named branch**, verify it descends from this checkpoint, and record its full SHA; do not silently switch to `main`.
- Scope: **CODE-R0 only** — audit `git grep` all text extensions; reproduce **21 official Godot 4.7.2** focused tests (finite/continuous, Combat V2, GP-02C1 Injury120, Body gate materials, save, Warehouse, reward isolation). Repair only reproducible issues on this branch and only in CODE-CLEAN relevant allowlist; supply fail assertion, raw log, before/after repro and new exact SHA.
- **Not authorized**: R1–R6; delete finite gameplay; migrate saves; rebalance combat; change Source A, UI, map, PR #28/#29/#31; merge to main; make repo public; change billing; create further hosted CI load.
- Keep legacy save readers, existing finite reward claimant compatibility, canonical warehouse exactly-once, `CombatSystem.commit_v2_direct_hit`, Injury `0/1` with `120` ticks, and Combat V2 damage math intact.

## 1. Read before action (from GitHub directly, no message/chat handoff required)
1. This file (Work entrypoint).
2. [R0 execution evidence](docs/handoffs/TMB_CODE_R0_BASELINE_QA_EXECUTION_EVIDENCE_2026-10-25.md) in this branch. Read sections 1–8; sections 7–8 contain the latest runner diagnostics.
3. [Full caller inventory](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/docs/combat-finite-retirement-full-caller-save-migration-20261025/docs/research/TMB_COMBAT_FINITE_RETIREMENT_EXHAUSTIVE_CALLER_INVENTORY_2026-10-25.md).
4. [Save and earned entitlement migration contract](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/docs/combat-finite-retirement-full-caller-save-migration-20261025/docs/design/TMB_COMBAT_FINITE_TO_CONTINUOUS_SAVE_ENTITLEMENT_MIGRATION_CONTRACT_2026-10-25.md) (design only; do not implement R4).
5. [Codex R0–R6 sequencing packet](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/docs/combat-finite-retirement-full-caller-save-migration-20261025/docs/handoffs/TMB_CODEX_COMBAT_FINITE_RETIREMENT_IMPLEMENTATION_PACKET_2026-10-25.md) (execute only R0).
6. `AGENTS.md`, current `godot/project.godot`, actual simulation/tests and `tools/qa/Invoke-CodeR0-Focused.ps1`.

## 2. Confirmed state at freeze
- GitHub REST scanned **273/273 .gd**, **43/43 .tscn/.tres**, **272/272 .ps1/.cmd/.py/.yml/.yaml/.json/.md** at CODE-CLEAN fixed SHA (**588 of 588** files in defined extension list). That is static read-only content inspection, **NOT** a local native `git grep` invocation.
- Three overlapping combat paths: legacy `CombatSystem.resolve_encounter` (20 rounds or 45 seconds), legacy finite `MapBattleV2/HuntingPveRunV2` 90-second bounded session/claim, and B3 World `continuous_mode` per-kill Warehouse receipt pilot. Do not assume finite code is unused or safe to delete; GP-02C1 historic save and Body four-win materials remain dependent.
- R0 QA workflow: `.github/workflows/code-r0-finite-world-gate.yml`, installed **in branch only**. Two GitHub-hosted jobs repeatedly failed **before checkout / before runner assigned** (`runner_id=0`, `steps=[]`, log `BlobNotFound`), across R0 and unrelated workflows. Runs **40163016429**, **40163116780**, **40163463959** (rerun attempt 2), **40168233503**. The owner has now provided the missing operational diagnosis: **Actions usage/quota exhausted**. No further hosted retry needed.
- Existing workflow is restricted so *docs-only commits do not launch more failing CI*. The current CI failure is NOT a failed Godot assertion.
- **21 focused Godot cases configured; 0 executed on the baseline QA branch as of this handoff. R0 status: QA BLOCKED / NOT PASS.**
- Already committed QA infra: `tools/qa/Invoke-CodeR0-Focused.ps1` (Windows, stdout/stderr/exit logs) and GH workflow as reproducible test manifest. **No existing gameplay or test file was modified compared to CODE-CLEAN baseline** when this Work entrypoint was written.

## 3. Work mode execution — no GitHub Actions minutes
**First choice:** use Work's own supported cloud computer / terminal, if actual code checkout and engine execution are available. If Work has only web browsing without a terminal or cannot authenticate the private repo, record the limitation and do not fabricate local execution. GitHub connected access may be used to read/write existing project files.

1. Fetch exact branch and verify ancestry:
```bash
git fetch origin qa/code-r0-finite-world-20261025
git switch qa/code-r0-finite-world-20261025 || git switch --track origin/qa/code-r0-finite-world-20261025
git rev-parse HEAD
git merge-base --is-ancestor 5fbdbc6309c3f1386f0d8b619831e007c5a52824 HEAD
git status --short
```
2. Native read-only `git grep` (safe/no Actions usage):
```bash
mkdir -p artifacts/qa/code_r0/work
git rev-parse HEAD > artifacts/qa/code_r0/work/sha.txt
git grep -n -E 'MAX_SECONDS|LEGACY_FINITE_MAX_SECONDS|MAX_REALTIME_SECONDS|timeout_retreat|HuntingPveRunV2|HuntingMapV2|claim_reward|v2_pve_active_runs|v2_pve_reward_claims|v2_pve_settlement_receipts|active_pve_encounter_id|MapBattleSnapshotV2|MapBattleV2|CombatSystem|resolve_encounter' -- '*.gd' '*.tscn' '*.tres' '*.ps1' '*.cmd' '*.py' '*.yml' '*.yaml' '*.json' '*.md' > artifacts/qa/code_r0/work/git-grep.txt
```
If grep returns 1 due to no matches, record it honestly; do not ignore any other exit code. Source-code and historical documentation hits must be distinguished.
3. **Godot 4.7.2 official binary only**, not whatever version is preinstalled. `godot --version` must start with `4.7.2`. The preexisting CI locks Linux archive:
   - `https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_linux.x86_64.zip`
   - expected SHA256 `cadd3204e728a35d3f13adb7fd0d7902636b79f6b95c40c265eb73b6c35329e4`.
   Verify actual release/binary and checksum before use; if unavailable stop with an exact runtime blocker. Asset imports may require the canonical female Stage A pack restoration (see `.github/workflows/gp-02c1-injury-settlement.yml`) before a presentation test, but **do not modify game art or tests** to work around missing assets.
4. Import: `godot --headless --path godot --editor --quit`. Run each existing test `godot --headless --path godot -s res://tests/simulation/<name>.gd` from actual present `.gd` paths; **verify filenames and reconcile stale manifest before testing**. The exact 21-case list is in the R0 evidence document and `.github/workflows/code-r0-finite-world-gate.yml`. Never claim PASS from workflow metadata. Windows may instead run:
```powershell
pwsh -NoProfile -File tools/qa/Invoke-CodeR0-Focused.ps1 -GodotBin "<absolute path to VERIFIED Godot 4.7.2 console executable>"
```
   All **21 tests** need individual stdout/stderr and process exit code; baseline grep+import separately captured. Run real focused QA: cross-mode reward isolation, continuous/finite combat, GP-02C1, early Body gate, SAFE-01/02 Warehouse/Save.
5. If a test actually fails, read exact assertion and source; apply the *smallest* R0-only correction with test evidence, rerun affected + relevant regressions; do not expand into R1–R6. Never hide skipped cases or override success codes.

## 4. Evidence, GitHub update, and acceptance
- Work should store audit evidence **in GitHub on this same QA branch**, not just a chat text reply: `docs/qa/CODE_R0_WORK_EXECUTION_RESULT_2026-10-25.md` (create when Work runs), including start/end SHA, environment, Godot binary version+archive checksum, native grep total/hash and caller classifications, **21 individual exit codes**, QA summaries, exact known FAIL/BLOCKED, raw log locations/artifacts with checksum, and changed-file compare.
- Attach/upload small sanitized raw logs under `docs/qa/logs/code-r0/` if size permits. **Do not commit secrets, authentication tokens, platform-specific personal directories or huge binary assets**. For large logs, link a Work-delivered artifact and manifest SHA256, identifying its actual location.
- `git diff --name-status <BASE_SHA> HEAD` must not show any modification to unrelated PR28/29/31 or game systems outside a logged R0 repro.
- **Success requires** 21/21 actually executed PASS plus the grep recorded and source safeguards verified. Otherwise mark **BLOCKED** or explicit FAIL with reproducible evidence. No merge.
- Work may read/write GitHub project through connected GitHub if authorized; if Work can neither execute code nor publish evidence, save a truthful blocker report on the QA branch and stop.

## 5. Project authority to keep intact
- Godot 4.7.2; Android landscape target 1280 × 720; Source A art style; no renderer reboot.
- Combat V2 authority math; One Active Job; Injury state 0/1 and recover 120 ticks; warehouse exactly-once; canonical SaveService old reader.
- **Legacy entitlement**: historical finite terminal WIN unclaimed survives save/load and grants loot only once; old in-flight PvE and Body materials/four-win `linh_tuy` must not disappear. World per-kill receipts and Warehouse save barrier protect continuous encounters.
- Keep separation from JX Web MOD and CMP, other repositories/tasks.

## 6. Ready-to-run Work task (single sentence, no pasted multi-page prompt)
**“Open my connected private GitHub repository `vuanhtuan161094-byte/TongMonBaDao`, branch `qa/code-r0-finite-world-20261025`, and execute `WORK_START_HERE_CODE_R0_20261025.md` end-to-end using Work's own execution environment rather than GitHub Actions. Push only CODE-R0 QA results and evidence to the same branch, never merge.”**

If Work's cloud computer cannot access a real terminal/engine, say precisely what it could perform and which acceptance gates remain blocked. **No simulated test output.**
