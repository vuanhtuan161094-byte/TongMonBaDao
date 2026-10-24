# TÔNG MÔN BÁ ĐẠO — Codex Packet G1: Original JX Source Skill Forensic

**Date:** 2026-10-24. **Operation:** original Windows JX source READ-ONLY inspection and docs-only result commit.
**Repository:** https://github.com/vuanhtuan161094-byte/TongMonBaDao
**Designated docs branch:** docs/jx-original-skill-readonly-source-audit-packet-20261024 — started at verified main SHA 29b5fba448b0178cb520a4ada44b375b4b934e31.
**Codex writer scope:** docs/audits/JX_ORIGINAL_SOURCE_FORENSIC_RESULTS_2026-10-24.md and sanitized small evidence manifests under docs/audits/JX_ORIGINAL_SOURCE_G1_*.csv or .json, plus an update to the existing docs/audits/JX_ORIGINAL_SOURCE_EVIDENCE_BASELINE_2026-10-24.md.
**Absolute prohibitions:** no modifying source archives or files, no JX binaries/server/client, no Godot gameplay, no PR29 changes, no Source A, UI, CI, workflows, save, merge, or gameplay code. No PR creation.

## Codex: execute these exact directions

You have owner authorization to perform a forensic STATIC READ-ONLY audit of the *original* JX client/server source materials on this Windows PC. Your task is to locate verified JX1 Võ Lâm Truyền Kỳ source, JX2 **Online** and Kiếm Thế **Online** if available; list and cross-check actual raw skill definitions, missile and status tables, level curves, skill learning prerequisites, events/procs and animation/sound associations. Report real evidence and uncertainties. Do not port source or modify the Tông Môn Bá Đạo game.

### 0. Read current authorities and previous audit

1. Read repository AGENTS.md, docs/GAME_SYSTEM_ARCHITECTURE.md, CURRENT_CHECKPOINT.md, NEXT_CHAT_HANDOFF.md, canonical combat skill and technique specs (read-only). Before commit verify live main HEAD, preserve the designated branch and writer isolation.
2. Read previous audit: https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/docs/combat-v3-jx-real-source-forensic-skill-audit-20261024/docs/research/TMB_JX_REAL_SOURCE_SKILL_MISSILE_EFFECT_ANIMATION_AUDIT_2026-10-24.md
3. Read the companion baseline report on this branch: docs/audits/JX_ORIGINAL_SOURCE_EVIDENCE_BASELINE_2026-10-24.md. It is **NOT a substitute for physical PC source inspection**.
4. PR #29 Combat V3-S1 currently draft at head 9522812e91b7ca5bc0cc108eb92e000e930fe850; Godot 4.7.2 focused QA pending in known checkpoint. **Do not touch PR29 or reinterpret audit as S1 PASS.**

### 1. PC host roots: discover first, do not guess contents

Confirmed owner-supplied candidate roots from prior conversation:
- E:\Source
- E:\Tool JX

Previously discussed possible outputs (verify with Test-Path; not guaranteed):
- E:\codex\2026-10-21\jx-web-mod-th-c-thi\outputs\G0C_AUDIT_2026-10-21
- E:\TongMonBaDao_AssetVault\06_reports\JX1_Combat_Intake — planned vault, may not exist.

Start with Test-Path -LiteralPath, Get-Item, directory metadata and bounded shallow listing for each root, then gradually narrow to candidate skill/asset folders. Do not recurse through entire E:\ or C:\, don't enumerate unrelated private directories, no access elevation/ACL/registry changes. For large data do **sequential, streaming/bounded** parsing with progress and memory limits; host previously has 8 GB RAM and system instability. Do not read 11GB archives fully into RAM or run full drive hashes.

A past separate G0C audit mentioned client 21,511 files and server 315 files; **these are previous claimed counts, not this run's measured evidence**. Measure current scoped counts, label discrepancies and archives separately; never copy prior totals into "new PASS". If client/server originals cannot be accessed, mark source_missing and continue with honest scoped report rather than pretending.

### 2. Classify the genuine game family and source role

For every discovered candidate folder/file, record:
- claimed title versus actual verifiable family: **JX1 Online, JX2 Online, Kiếm Thế Online, JXQY2 single-player, web derivative, tool/asset mirror, or UNKNOWN**;
- client/server/patch/editor/mod/data/scripts/resource archive;
- version/build clue with actual source path and row; archive name alone insufficient;
- plain text table vs packed container vs binary-only; ability to read original rows and confidence level.

**IMPORTANT** JXQY2/Jianxia Qingyuan II asset INI repository is **not evidence of JX2 Online MMO**. Fan-made Võ Lâm Idle and Giang Hồ Sinh Tồn browser code is **not the original JX1 client/server**, even if carrying source-derived IDs.

Search candidate filenames based on actual directory existence (not presumed files):
- skills.txt, skill.txt, skill*.txt, magic*.txt, missles.txt (**missle** spelling), missiles.txt, missile*.txt, char/npc/monster/goods/item/sect/weapon learning tables;
- Lua config/readable skill scripts only to **inspect text**, no execute; .ini, .cfg, .xml, .json, .csv, .tsv, .txt with GBK, GB18030, Big5, UTF-8/UTF-16 detection;
- .pak/.spr/.mpc/.asf resource manifests, animation reference indexes, scene/character attack/magic/cast/hurt/death actions; metadata only if container packed. No decompress/extract from archives in this audit.

### 3. Minimal mandatory schema and joins

Record source register:
game_family | source_role | physical_path | bytes | modified_time | encoding | sha256 | hash_status | row_count | build_id_evidence | evidence_level

**SHA-256**: compute for **selected relevant small original config/skill/missile/script sources**, with file size and provenance. For huge PAK/binary archives skip full hash if CPU/RAM/disk risk; say SKIPPED_LARGE, preserve filesize/mtime and archive entry metadata/CRC if safely available. Never derive a whole-file SHA from header hash. Do not alter input file timestamps or contents.

Record skill rows:
game_family | original_file | SHA256 | row | raw_skill_id | name | skill_level | branch | element | weapon | prerequisite_id | prerequisite_level | learning_item/manual | direct_damage_fields_raw | resource_cost_fields_raw | speed/cast/cooldown_raw | target_shape/cap_raw | status_raw | triggered_proc_raw | child_skill_id | missile_id | animation_ref | confidence

Record missile/event rows:
game_family | original_file | SHA256 | row | missile_id | skill_id | move_kind_raw | form_raw | generate_raw | generation_gap_raw | speed_raw | life_raw | collision_raw | start_event_raw | hit_event_raw | vanish_event_raw | impact_anim_ref | audio_ref | decoded | target_existence

Record dependency edges: origin id/path + target id/path + edge type + source field + source hash/row + exact target-found boolean. Required links when fields exist:
skill→prerequisite skill, skill→child skill, skill→missile, skill→buff/debuff, missile→onhit/status/proc, skill→actor cast animation, missile→flight sprite, missile→impact sprite/sound.

For effects, **do not invent meanings of raw keys**: separate raw field and consumer/resolver actually proving the mechanic. Search specifically seriesdamage_p, poisondamage_v, ignoredefense_p, skill_eventskilllevel, skill_collideevent, skill_misslenum_v and control/slow/stun/burn/DoT/shield/heal fields, *if actually present*. Absence of a consumer means **RAW_FIELD_ONLY**, not numeric proc rate. For each formula cite resolved implementation path + function + lines and confidence, or explicitly UNKNOWN.

Differentiate **learned prerequisites** from **combo prerequisites during battle**; skill level EXP from disciple realm requirements; skill effect scalar from attack ratio; missile count from number of valid hits; animation visuals from authoritative actual damage. Mark missing/broken original ID and asset refs.

### 4. Actual sample audits: work from verified file rows

Target **at least 12 distinct representative original skills, if actually available**: basic, passive, ranged, fan/multi-missile, piercing line, AoE, child/proc, Fire/Burn, Water/slow, Poison/DoT, guard/shield, control. If not enough, never fabricate categories; show verified subset and gaps.

Cross-check previous **derived web catalog** for cases:
- Nhân Kiếm Hợp Nhất derived SkillId 368, MissileId 175
- Bá Vương Tạm Kim SkillId 1060, MissileId 350, derived chain 1060→1088
- Truy Tinh Trục Nguyệt SkillId 323, MissileId 139, derived chain 323→327
- Phá Thiên Trảm SkillId 322, MissileId 138, derived chain 322→326
- Huyết Đao Độc Sát SkillId 65, MissileId 31

For each, mark RAW TABLE MATCH, MISMATCH or ORIGINAL TABLE UNAVAILABLE, with raw file, hash and row if matched. The 270 records in web vltk-books.js and its 75 playable skills are **DERIVATIVE COUNTS**, not independently verified original JX1 gameplay coverage. Browser data.js explicitly labels all balancing numbers as hypotheses; never copy cooldown/damage/range from it as authentic JX values.

Compare if available JXQY2 INI actual record:
https://github.com/Upwinded/jxqy2-assets/blob/main/ini/magic/player-magic-天意剑诀.ini
This has fields effect, manacost, level1..level10, movekind, waitframe, lifeframe and sprite references; **effect=562 at level1 does not establish 562% ATK**. Separate family. Do not call this JX2 Online proof.

### 5. Actor animations and references — file presence vs tested visuals

For a sampled skill, assemble a joined trace with real source keys:
skill file and row → child/missile id + effect field → cast clip/action (e.g. magic vs attack) → missile/flight descriptor → impact descriptor → sound → status/event source.
Verify each link exists in the same source family and distinguish:
- REFERENCE_ONLY (text field)
- FILE_PRESENT_UNDECODED (binary resource found, frame count unknown)
- DECODED_METADATA (frame/direction/pivot parsed by known safe static reader)
- RUNTIME_PROVEN (requires authorized client execution; **out of scope here**)
- BROKEN_REFERENCE / UNKNOWN_ARCHIVE_ENTRY.

Document at least three diagrams or line-by-line mapping examples if original sources allow; if no originals, one or more derivative/linkage examples clearly labeled. **No screenshots or playable asset imports are authorized**.

### 6. TMB V3 comparison, design only

Read directly the Godot 4.7.2 CombatSkillSystem.SKILLS, DiscipleCombatLoadoutV2, MapBattleV2, MapBattleSnapshotV2, CombatStatsV2 at known PR29 SHA and official master specs. Report verified code behavior and missing mechanics.

Respect:
- Combat V2 authority; no new combat owner, no new universal Mana.
- 1 basic / 4 active / 6 combat passive equip limits (not total learned catalogue).
- 5 locked personal skill mastery stages and 30x10 TuVi + Body cultivation, not raw JX ten levels or MMO level cap.
- Original Source A presentation; no JX renderer rewrite.
- save/offline exactly-once, no duplicate reward; DEV users create fresh disciple/world when changing versions, **do not delete real user save in this audit**.
- No S1, S2, balance/skill code changes without future owner packet.

Create an evidence-backed gap table: skill registry, family, prerequisites, damage/stat channels, status/proc, child hit, missile geometry, AI action and visual integration; mark REUSE CONCEPT vs NEEDS NEW DESIGN vs CAN'T VALIDATE.

### 7. Safe execution constraints

**Original JX roots are READ-ONLY.** No untrusted source code execution (exe, DLL, Java, node, powershell scripts from source, Lua, game/server, conversion tools), no PAK extraction, no copying copyrighted bulk asset or binaries; no network transfer of private source/archive; no registry/UAC/Defender/ACL changes; no recursive full drive crawl; no overwrite, edit, rename, delete, move, even temporary files under the source roots.
Analysis can use **your own** bounded commands and built-in safe text/data parsers on copied-in-memory bytes. Local audit outputs may go only to a **new isolated** workspace outside sources, preferably E:\codex\2026-10-24\jx-skill-source-audit\outputs if user permissions allow (no elevation), not to Source or Tool JX. No public upload of raw original full tables, copyrighted assets, credentials or game binaries. Summaries + row references + hash + limited non-sensitive samples only.

**GitHub:** DO NOT checkout/mutate any working tree owned by Codex currently repairing PR29. Use connected GitHub connector or an isolated docs-only clone/worktree; do not create/update pull requests, alter PR29 or merge. Commit only the specified report and evidence index file(s) on this docs branch. Never git add -A or git add .; explicitly stage only allowlist. Do not modify AGENTS, CURRENT_CHECKPOINT, NEXT_CHAT_HANDOFF or any existing game/test files. 

### 8. Mandatory report: write, verify, commit

Write docs/audits/JX_ORIGINAL_SOURCE_FORENSIC_RESULTS_2026-10-24.md with sections:
1. Audit state, actual inspected roots + time + PC conditions and safe scan scope.
2. Game-family discovery matrix: JX1/JX2 Online/Kiếm Thế/JXQY2/web derivative, found/path/identity evidence + SOURCE_NOT_FOUND vs inaccessible.
3. Counts by subtree, bytes by extension, hashes coverage, prior 21,511/315 comparison with scope notes; exclusions.
4. Real skill table row snippets/IDs, learn prerequisites, level data, damage raw fields and resolver confidence; tables with source SHA/row.
5. Missile/child/status/buff/proc link graph, collision/missile formation, resource links, broken references and animation confidence.
6. TMB V3 actual code-gap matrix, canonical-preserving suggested dependencies **DESIGN ONLY**.
7. Unverified fields, data anomalies, blockers, reproducible read-only commands and top follow-up choices.
8. GitHub HEAD proof and compare from main with **only docs/audits/JX_ORIGINAL_*** paths.

If original source missing/blocked, **still commit a truthful incomplete report**, do not claim original JX formula extraction. No PASS label on original gameplay, runtime or Godot tests. Verify report readback from GitHub and changed paths; preserve PR29 state. Finish with actual branch SHA and report link.

### 9. Return summary for owner

G1 original JX skill source audit status: COMPLETE WITH GAPS | PARTIAL | BLOCKED
Actual roots examined (exact): ...
JX1 original table: FOUND and hashed / NOT FOUND ...
JX2 Online: FOUND or NOT FOUND IN SCOPED ROOTS ...
Kiếm Thế Online: FOUND or NOT FOUND IN SCOPED ROOTS ...
JXQY2: separately labeled ...
Sample SkillId / missile / status / animation edges: ... with row/hash ...
Authoritative original damage formula: VERIFIED symbol/path/units or UNKNOWN ...
Files changed: docs/audits/JX_ORIGINAL_* only.
GitHub branch/HEAD/report: ...
Confirmed no games/servers were executed and no game code/UI/PR29 touched or merged.
