# TÔNG MÔN BÁ ĐẠO — SOURCE A checkpoint 04:05Z: review & B3 handoff

**Report date:** 2026-10-22 · **Source:** owner-supplied `CAMPAIGN_STATUS_vi.md`, `CHECKPOINT_CURRENT.json`, `usable_assets.csv`, `SHA256SUMS`. Uploaded copies locally inspected, SHA-256 for those 3 files matches the owner-supplied SHA256SUMS. **Docs-only checkpoint**: no Source A repo/workspace changes, no conversion, no code/merge.

## 1. Reliable state

- Full input/source inventory: **184,888 files**, **17,341,500,030 bytes** (**16.15 GiB**), **0 read errors**; 57,727 SHA aliases; all 184,888 source file hashes inventoried. 20,507 Spine canonical input hashes match.
- Spine catalog: **6,578/6,578 parser PASS** after overlay fixes (signed draw order, weighted deform length); **6,243 READY**, **335 REVIEW** (162 atlas, 173 texture/page), no formally UNSUPPORTED rig. Earlier parser REVIEW grouping should **not** continue as 914 broken rigs.
- **62 output QA PASS rows**, composition: 36 `UNCHANGED_SKIPPED`, 17 `CONVERTED`, 8 `BLOCKED_RESOURCE_LIMIT_REFRESH`, 1 `HISTORICAL_QA_PASS`. This is mixed evidence vintage/status; output row PASS does not equate to freshly fully captured QA for all.
- **6,171 READY not PASS** (includes 2 failures held under same config); **6,169 eligible unpassed excluding held failures** plus **9 QA refresher candidates** = **6,178 resume entries**. Next source ID `11123003_1`.
- Source `1111204_1_s`: native Godot capture TIMEOUT **3,600 sec**, no output published, verified native child stopped; **not proof corrupt rig**. Source `2123019_10`: prior canvas-edge crop at 768. Do not automatically rerun held failures in same profile.
- Parser SHA `38aa64d2c70c385c39019d605fdeef3c038b8d9173e74cd30184817adfa23d02`; converter bundle SHA `54b0575661a2384e13595eefb3d327e2bc7b29d417329a29814ac481b25839b1`. Focused tests 12/12 PASS **as reported by external Codex**, not rerun here.
- Non-Spine PNG/WAV/OBJ import one sample each under Godot 4.7.2; this is **sample evidence** only; **MP4 loader unavailable** in Godot import pilot. UnityFS, binary, assets with no verified consumer remain REVIEW/unknown.
- `usable_assets.csv` has 62 PASS rows but **60 distinct source_id values**: `1110903_1` and `1110903_1_s` each appear twice with different `asset_id`; never dedupe by `source_id` alone or assume duplicate hash. **47 rows** have an actual catalog clip-name set `stand, walk, attack1, hit, dead`; there are **0 rows** with a literal clip named `attack`. Clip-name coverage only, **NOT** verified character role/animation composite/Owner Visual PASS.
- Source A remains at `E:\TongMonBaDaoWorkspace\03_AssetLibrary\SourceA`; raw input under `02_SourceA` must stay immutable.

## 2. Safety gate before next long conversion

**Critical:** report explicitly notes `RAM gate = 0` in campaign config following a change, and rig capture stalled for 3,600 seconds. On 8GB Windows development machine with past BSOD, a zero memory gate is **NOT** a verified safe operating configuration. Codex should diagnose semantics of 0 (disabled/bypass?) and restore a measured safe guard without overwriting owner's intentional settings silently; report the precise config change proposal/evidence.

Sequence:
1. Inspect `conversion_campaign.log`, timeout-specific timestamps, stderr, PID process tree and native capture stage for `1111204_1_s`; determine whether spend was parser, atlas, frame bake, import or capture wait, and whether it is reproducible in **limited stage-by-stage diagnostics**. Do **not** repeat 3,600 sec blind retry.
2. Add separate phase timeouts, per-rig watchdog, real RAM/free-disk checks, monotonic progress log, cancellation/cleanup and idempotent checkpoint. Do not automatically kill unrelated Godot/Windows processes, and do not run heavy Source A converter concurrently with Godot/Studio/V5 workers.
3. Compare `FAST QA` throughput: parser/static extraction versus expensive native Godot screenshot. If converter forces full native capture every rig, propose a **two-tier QA model** `STATIC_VALIDATED` vs `GODOT_CAPTURE_PASS` with different evidence/status; do not silently downgrade previous QA semantics or mark capture-free outputs PASS. Gate any change to output schema and fingerprint.
4. Resume **one** different already eligible READY source (`11123003_1` as checkpoint), if and only if preflight safe, using the exact command in `CHECKPOINT_CURRENT.json`; verify no duplicate DB writer, no new hang, output hash and isolated process exit. Then 1–4 batch increments, checkpoint every batch. Two HELD failures stay held until explicit targeted diagnosis.
5. Separate bounded triage for 162 atlas + 173 texture cases by common fault signature, not entire 335 unchecked retries.
6. Keep all non-Spine categories in the single catalog; prioritize B3-ready actor candidates (not all 62 row PASS prove role). Distinguish `asset_id` unique from `source_id` alias.

**Do not claim 100% conversion**: 100% source inventory + parser is true, but only 62 PASS rows of READY population and non-Spine content still needs supported import/semantic linking.

## 3. B3 dependency interface only — NO SOURCE A EDIT BY B3

B3 World/Monster/Boss/Team AI should refer to future `asset_pack_id`, `asset_id`, verified `source_id`, clip IDs, `manifest_sha`, pivot/foot reference, species/actor role evidence and content version; it must **not** interpret rig names as boss identity or gameplay loot source. Use clip `attack1` name mapping only after explicit V5/Studio presentation adapter. **Combat V2 remains owner of HP/damage/skills/loot receipt**, Source A solely visuals and metadata. B3 design can continue while Source A finishes, without running Godot or touching E: files.

## 4. Source A Codex next action (scoped)

Read checkpoint and investigate the specific native capture timeout and zero RAM gate; write a resource-safe, resumable conversion plan. Resume `11123003_1` only after safe preflight, one worker, source fingerprints and no double writer. On success continue bounded READY batch; on failure checkpoint and diagnose, do not spin 3,600s repeatedly. Review atlas/texture faults as second independent metadata task. Do not modify B3, Map, Studio, V5, game save or raw Source A.

**No implementation authorization for B3 gameplay is conveyed by this document.**
