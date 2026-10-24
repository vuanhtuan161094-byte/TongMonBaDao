# TÔNG MÔN BÁ ĐẠO — JX G1 Original Source Evidence Baseline

**Date:** 2026-10-24
**Status:** BASELINE EVIDENCE/PACKET COMMITTED — PC ORIGINAL-SOURCE AUDIT **NOT YET EXECUTED**.
**IMPORTANT:** this file is a truthful source register / unfinished report scaffold. It is NOT the requested future Codex read-only Windows run log, and it provides no certification of JX original game formulas, original runtime parity, TMB S1 QA or animation decoding.

## 1. Environment and authority

| Scope | Status / evidence | What it means |
|---|---|---|
| User-supplied original local source candidate 1 | E:\Source — EXISTENCE **NOT PROBED THIS TURN** | Codex must verify using Test-Path on user's Windows |
| User-supplied original local source candidate 2 | E:\Tool JX — EXISTENCE **NOT PROBED THIS TURN** | Codex must verify using Test-Path |
| Prior JX G0C | Former source audit claimed 21,511 client files and 315 server files; **not re-enumerated this turn** | Historical checkpoint only; not a new count |
| Prior local QA output candidate | E:\codex\2026-10-21\jx-web-mod-th-c-thi\outputs\G0C_AUDIT_2026-10-21 — NOT PROBED | Check actual path/variants and hashes, do not silently rely |
| Planned AssetVault report folder | E:\TongMonBaDao_AssetVault\06_reports\JX1_Combat_Intake — UNVERIFIED PLAN | Not guaranteed to exist; no write there |
| GitHub TMB current main | 29b5fba448b0178cb520a4ada44b375b4b934e31 (authenticated branch check) | docs branch parent |
| Combat V3 S1 | PR29 head 9522812e91b7ca5bc0cc108eb92e000e930fe850; OPEN DRAFT QA PENDING on latest known check | No gameplay/test edits in this packet |

**Source types MUST remain distinct:** JX1 original client/server ≠ Source VL authored browser survival catalog; JXQY2 original single-player config ≠ JX2 **Online** skill backend; original Kiếm Thế Online source not yet located in these known sources.

## 2. Existing external static evidence (READ in prior source audit, NOT from local Windows today)

| Evidence | Actually obtained previously | Confidence | Limitation |
|---|---|---|---|
| Source VL generated martial arts catalog | [Drive vltk-books.js](https://drive.google.com/file/d/1fXuZZAa4brAJ5OgTtDq2S6VMXPsLMk1D/view) | E1 read derivative, E2 original-source references | 270 records; 203 active, 64 internal/support, 3 mobility; 185 nonnull missile refs; 153 distinct; 31 chain references; no raw VLTK1 table cross-check |
| Source VL playable rules | [Drive data.js](https://drive.google.com/file/d/1slFnLRn1F6KI2jW7rpUNuvflvI_Ljt6m/view) | E1 derivative | Its own comment: every numeric value first balancing hypothesis; survival filters 75 skills, cooldown rewritten; not JX1 original formula |
| Source VL projectile handling | [Drive projectile-motion.js](https://drive.google.com/file/d/1hqDReQ55-sdIOO_1ah8NbLjVEvR4vA7Z/view) | E1 derivative | Values MisslesForm, MslsGenerate and 18 tick/s are web interpretation, not frame-perfect JX1 proof |
| Source VL visual refs | [Drive skill-visuals.js](https://drive.google.com/file/d/1TBOCRX4EYlmJWAGb9bKKHGCbvE3GlEsy/view), [vfx.js](https://drive.google.com/file/d/1xAXh6daKUlMxQyGbwPM3eQXSaNwh6pIC/view) | E1 derivative | SOURCE images and FX graph referenced, not decoded/visually accepted in TMB |
| JXQY2 actual INI fields | [GitHub ini/magic](https://github.com/Upwinded/jxqy2-assets/tree/main/ini/magic) | E1 direct text files | ~50 directory entries including a non-skill; individual levels effect, cast/life frames, graphics, sound; formula consumer unknown |
| JXQY2 actor animation | [GitHub Nam Cung Phi Vân](https://github.com/Upwinded/jxqy2-assets/blob/main/ini/npcres/npc-a01-南宫飞云.ini) | E1 direct ini | Separate stand/walk/attack/magic/run/hurt/death MPC and shade file refs; animation frames/pivots not decoded |
| JXQY2 native assets | [GitHub mpc/magic](https://github.com/Upwinded/jxqy2-assets/tree/main/mpc/magic) | E1 directory filename | Existence shown for named skill sprites/icons, not proven whole missile/impact graph |
| Prior source audit report | [GitHub previous forensic audit](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/docs/combat-v3-jx-real-source-forensic-skill-audit-20261024/docs/research/TMB_JX_REAL_SOURCE_SKILL_MISSILE_EFFECT_ANIMATION_AUDIT_2026-10-24.md) | E1 docs backed by sources | Basis for rechecking, not replaced by original source proof |

## 3. Known source-derived ID candidates to cross-check

These are reference **claims from derivative catalog**, explicitly NOT 100% proven raw VLTK client or server rows.

| Name (derivative) | Source-derived SkillId | Source-derived MissileId | Derived linked SkillId | Original readback | Missing original items |
|---|---:|---:|---|---|---|
| Nhân Kiếm Hợp Nhất | 368 | 175 | — | PENDING | Raw Skill/ Missile rows + hash, resolver/hit flags |
| Bá Vương Tạm Kim | 1060 | 350 | 1088 | PENDING | Raw skill-to-child trigger and damage units |
| Truy Tinh Trục Nguyệt | 323 | 139 | 327 | PENDING | Raw geometry/target count and asset paths |
| Phá Thiên Trảm | 322 | 138 | 326 | PENDING | Raw hit event and child behavior |
| Huyết Đao Độc Sát | 65 | 31 | — | PENDING | Original poison duration/DoT/resist data |

JXQY2 example [Thiên Ý Kiếm Quyết](https://github.com/Upwinded/jxqy2-assets/blob/main/ini/magic/player-magic-天意剑诀.ini) **raw file** lists effect=562 at level 1 and 3000 at level 10, manacost, levelupexp, movekind, cast/flight/impact asset links. **Effect unit UNKNOWN**. [Bách Bộ Định Thân](https://github.com/Upwinded/jxqy2-assets/blob/main/ini/magic/player-magic-定身法.ini) includes non-monotone effect values level9=190 and level10=100; preserve source and report anomaly without guessing intended value.

## 4. PC source audit completion table — intentionally unfilled

| Gate | Status | Evidence required by Codex to fill |
|---|---|---|
| G1-00 Access E:\Source / E:\Tool JX | PENDING PC ACCESS | Path tests, exact scope, safe scan logs |
| G1-01 JX1 original raw table inventory | PENDING PC ACCESS | Real physical paths, bytes, counts, SHA256, encoding, version and authoritative source |
| G1-02 JX2 Online source inventory | PENDING PC ACCESS | Separate game identity, actual raw skill/script table or not found |
| G1-03 Kiếm Thế Online source inventory | PENDING PC ACCESS | Separate game identity, actual raw skill/script table or not found |
| G1-04 SkillId→MissileId→child joins | PENDING PC ACCESS | Join output, representative original rows, hash/line/provenance, broken references |
| G1-05 Damage, status/proc interpreter | PENDING PC ACCESS | Raw fields, typed consumer/resolver path and code excerpts; unknown if binary only |
| G1-06 Actor cast/flight/impact assets | PENDING PC ACCESS | File reference resolution, presence/decode status, explicit unmatched resources |
| G1-07 TMB V3 mapping | PARTIAL DESIGN BASELINE | Compare directly to source of PR29 and V2 specs; no runtime edits |
| G1-08 GitHub docs-only evidence report | PENDING CODEX EXECUTION | New results.md on docs branch plus manifest and compare; no game code |

**No actual local Windows source was scanned, hashed or executed as part of creating this baseline.**

## 5. Report acceptance and next action

The instructions for Codex are in [G1 Codex packet](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/docs/jx-original-skill-readonly-source-audit-packet-20261024/docs/audits/JX_ORIGINAL_CLIENT_SERVER_SKILL_FORENSIC_CODEX_PACKET_2026-10-24.md).

On completion, Codex must update this table and publish a NEW file named docs/audits/JX_ORIGINAL_SOURCE_FORENSIC_RESULTS_2026-10-24.md with actual Windows root probes, source hashes, raw row/index evidence, join gaps and GitHub changed-file verification. If PC originals are unavailable, commit an explicitly PARTIAL/BLOCKED report rather than fabricated original facts.

**Completion in this chat:** docs branch and initial evidence baseline only. No Codex Windows execution has occurred; no gameplay/renderer/save/canonical changes. GitHub branch remains **UNMERGED**.
