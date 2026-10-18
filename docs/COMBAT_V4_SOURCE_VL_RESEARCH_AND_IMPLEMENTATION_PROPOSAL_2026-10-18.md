# TÔNG MÔN BÁ ĐẠO — SOURCE VL → COMBAT V4 RESEARCH & PROPOSAL
Date: 2026-10-18. **READ-ONLY / DESIGN ONLY. NO CODE, NO ASSET IMPORT, NO CI/FULL/MERGE.**

## 0. Authority, user intent and references

- Repository: https://github.com/vuanhtuan161094-byte/TongMonBaDao ; audited main SHA **461caca1171462e0da092f21108c5c1733157ad9**.
- User-source Drive root: https://drive.google.com/drive/folders/19mdpwyTf2tzYblpfOg0CARi-JHdO70ZR . Source is the JavaScript browser community game **Giang Hồ Chi Chiến — Community Offline 0.1.0**, containing VLTK/JX1 converted/source-referenced materials. It is **NOT verified as the original JX1 complete client/server**, an asset redistribution license, a Godot codebase, or a mobile release.
- Read GitHub AGENTS.md, Master Character Schema, Combat Skill V2 and Cultivation Path V2 specs, live CombatSkillSystem, DiscipleCombatLoadoutV2, MapBattleV2, HuntingMapV2 and MapBattleWorldLayerV2. Existing scoped C4-01 branch SHA **4e2ca7db07c98a021977bbcb026b6be7c958bbff**, not part of main and no verified new Godot 4.7.2 runtime in this review.
- Owner's **C school model**: congenital martial inclination, freedom to select another school with moderate study compatibility, no permanent class hard-lock; JX1-inspired distinctive martial VFX. Real-time autonomous map battles, 6 disciples/team, 30/cluster, Android landscape 1280×720. **Source A**, PR20, Economy, Warehouse, Scheduler, Save, Injury, gameplay and balance must not change during this review.

## 1. Evidence ACTUALLY decoded/read in this turn

### 1A. Browser combat and presentation code

- [engine.js](https://drive.google.com/file/d/1OblApG13GpgVhGh1pkCvpjdliFVypSk4/view): source-player movement/combat, cast+cooldown, projectile, arc/line/circle hits, anti-CC/poison DoT/slow/stun, knockback, dash/leap, timed area zones, various skill kinds (slash, spin, thrust, dash, zigzag, projectile, beam, ground, nova, cone, aura, channel, parry). It owns simulation damage, and has different HP/MP/ST/cooldowns and player-control rules from our Godot game. **Never port all of it wholesale.**
- [native-presentation.js](https://drive.google.com/file/d/1HuMuCVX5waGCkC3J7mp0MJbESgXwDDEb/view): source graph display begin → launch → missile actor → collide/expire, event-child effect stages, real primary projectile binding, throttled SFX. Explicitly designates combat damage to the web survival engine. **Very useful separation-of-authority pattern for Godot.**
- [vfx.js](https://drive.google.com/file/d/1xAXh6daKUlMxQyGbwPM3eQXSaNwh6pIC/view): 3-stage precast/cast/impact, effects/projectile VFX, atlas rectangle and anchor, sprite per direction, blend mode, lazy per-manual art load, viewport culling.
- [sprites.js](https://drive.google.com/file/d/12V1FmRotOz21AkvMZsgN8B1JSFvvhJye/view): 8-direction characters, body/head/hair/hands/weapon compositing based on per-direction draw-order table, action/weapon timing, sprite sheet frames, source base VLTK_FPS=18 (not every effect FPS; individual SPR descriptors have frameMs).
- [auto-play.js](https://drive.google.com/file/d/1P2tQaUp2oDX7uXRcuL6dW_fNMys6UXsU/view): **automatic health-potion consumption only**, not full autonomous group skill AI. Source browser is an action-oriented player/bot game (WASD, J, Q/E/R/T, Space), NOT six-disciple automatic team combat.
- [data/vltk-fx.json](https://drive.google.com/file/d/15OeXBnaFKv5kX7MkWOyKYoh2jrQsHE1a/view) decoded from tieungao-json-gzip-v1 (gzip+base64) into 2,988,061-byte JSON: **270 skill source profile entries, 176 nativeSprites descriptors, 12 common FX, 2 common projectile FX, 11 VFX styles, 496 sound/event declarations** (not 496 sound files). Each source skill carries SkillId, raw name, group, source event chain, equipment requirements, original SPR/PAK path, original SHA-256, precast/cast/impact, frame rectangles, direction, frameMs, alpha/blend and optionally a multi-node fullLevel graph. This is a manifest of source refs, **not 270 playable Godot skills**.
- [data/sprites.json](https://drive.google.com/file/d/1f3CCXNoHV6qhsgUfpT8bnpWy96Y7soGD/view): **27** grouped archetype sheets with packed rectangle/anchor metadata for 8-direction creature and actor actions (idle, run, attack, hit, stun, die, etc).
- [data/animations.json](https://drive.google.com/file/d/1IAXUSph5CE6CEu2E8cjVWNOocMb88_oy/view): independent procedural figure authoring config (camera 35°, eight directions). Not an implementation of Godot art.
- [data/vltk/faction-coverage.json](https://drive.google.com/file/d/1Z214vl8lUFz85JcyebjQX9lSG0BBTh5D/view) has **260** unique source skill roots from **13** factions, including 118 marked playable in that other project, 63 passive excluded, 55 support pending, 3 hybrid pending, 21 attack pending; 270 effect mapping entries include other variants/mapping IDs. These are **not** 118 imported Godot skills.
- [docs/VERIFICATION.md](https://drive.google.com/file/d/1ACIt96SwzijJgSFvi-kmv90-Awtl21NH/view) **claims** 75/75 testable native effect kits and 100-fighter browser trials in a distinct source ZIP. Not reproduced here or on Godot; its Mac-only performance report explicitly does not prove real Android FPS/GPU memory. It identifies occasional ~185ms long rendering frames.
- [docs/ZIP-README.txt](https://drive.google.com/file/d/1pPic6E-pdyJn-19uOL8UJK3Rlp42qCYp/view) explicitly states copyright/redistribution permission of original VLTK assets is unverified.

### 1B. Binary source snapshot is PARTIAL — not enough to ship JX VFX

- Current Drive direct listings: **49 actual** WebP in data/vltk/fx while decoded full manifest references **100 distinct** vltk/fx WebP paths; **6 actual** WebP in data/vltk/native/assets while source graph references **173 distinct** native atlas WebP paths (176 descriptor records). Many true skill flight/hit stages are not in this upload.
- data/vltk/char has **one direct** file boss103_at02.webp; data/vltk/player yielded **100 direct items** but folder listings max out at 100, so actual count/completion unverified. data/vltk/sfx has 31 MP3 versus 496 sound/event *declarations* in manifest (not one-to-one).
- Source metadata exists for more artwork than the binary collection. Do not treat descriptor availability as binary readiness. No original raw JX1 PAK/SPR or original Skills.txt/Missiles.txt was found in the inspected Source VL root listing; manifests contain provenance strings, not the original PAK contents.
- Uploaded boar in chat ani018_wlk.webp has an exact identity match in sprites.json: boss-heorung.quyen uses the ani018 family for stand/walk/attack/hit/die. Its 8-direction walking atlas has 15 frames per direction. This does **not** mean it is in the current Source VL Drive.
- Source wolf mapping is finally traceable by metadata: boss-thanhlang.quyen → ani011_pst (idle 15f×8dir), ani011_wlk (run 15f×8), ani011_at (attack 14f×8), ani011_bat (hit 6f×8), ani011_die (die 10f×8). Also boss-soixam.quyen → ani009_* and boss-soido.quyen → ani010_*. **Exact binary files for ani011 are not in Source VL's one-file char listing.** Hắc Lang Vương remains a separate Godot species and a verified portrait/atlas match remains PENDING; do not relabel unrelated humanoid boss103/enemy109 by filename.

## 2. Specific source skill presentation examples (not balance to copy)

- Võ Đang Kiếm Phi Kinh Thiên: web source key vltk-skill-158, SkillId 158; precast 10 frames × 50ms, cast 17×50ms, impact 8×40ms; stages point to native asset IDs 3dfcabc2, aa93d577, 361b4525, **all absent from the direct six uploaded native pages**. Semantic inspiration for Godot Ngự Kiếm projectile.
- Ngũ Độc Độc Sa Chưởng: web source key vltk-skill-63, SkillId 63; cast 8 frames × 16 directions, 13-frame impact. Useful status-VFX inspiration; actual authoritative DoT has to be implemented in Combat V2 first.
- Source skill graph models child missiles and authored sound/impact conditions. Sprite direction **8** and individual FX directions often **16** are separate: preserve true rect/anchor/direction metadata, do not assume every clip shares one FPS.
- Source gameplay is a separate survival balance with independent MP and action geometry. **Do not** import its raw damage/stun, 75 skills, world units, drop system or free-class stats into Godot.

## 3. Godot Combat V2 authority already in place

- CombatStatsV2 and DiscipleCombatLoadoutV2 derive real gear, Realm/Luyện Thể and learned skills. MapBattleV2 implements **0.25s deterministic fixed steps**, a logical **36×20** arena, **90s** cap, **6 disciples per party / 30 per cluster**, up to 40 enemies, AoE cap3, target approach, generic role heal/guard, elite/Boss telegraph, basic attack and event journal. HuntingMapV2 has Thanh Trúc Lâm, Thanh Lang and Hắc Lang Vương typed species, PvE selection/rewards. PvE main-game integration still has specific gates.
- CombatSkillSystem defines 9 initial IDs. As of main above, learned dispatch only executes **two damage** skills Thanh Phong Trảm and Ngự Kiếm Thuật; Truy Phong Bộ dash plus Guard/Weaken/Burn/FireCombo remain deferred (seven). Generic frontline guard is NOT a learned Kim Cương skill. Sprite/HUD layer on main only displays schematic circles, HP, AoE; C4-01 fixes cast packet schema on a separate unmerged branch.
- Locked V2 soft active Chủ Đạo **Kiếm / Thể / Pháp**, optional branches; NO permanent fixed class, no extra level. Mature loadout **1 basic + 4 active + 6 combat passives** (design, not yet full runtime); shared seeded real-time AI; no universal Mana. Source VLTK schools are **authored training curricula/identities** layered onto actual V2 paths and learned skills, not a second all-school damage multiplier. Owner Model C remains: birth inclination ≠ forced school; mismatch affects proposed training investment only, no permanent power ceiling penalty.

## 4. One recommended Combat V4 architecture

1. **Keep simulation authority:** DiscipleState → DiscipleCombatLoadoutV2 → CombatSkillSystem + MapBattleV2 (fixed tick, HP, cooldowns, AI, RNG, projectile resolution, AoE, statuses). No native web engine port.
2. **One event-to-visual adapter:** consumes only actual typed event log/snapshot: cast-start, cast-release, projectile-progress, impact, real dash start/finish, status applied/expired, boss warning and AoE resolve. It maps canonical Godot skill IDs to optional source-art profiles; **external JX SkillId never becomes Godot damage authority**.
3. **One atlas/clip descriptor adapter:** asset hash, path, rects x/y/w/h/ax/ay, dirs, frameMs, draw layers, blend, SFX and missing-file fallback. Can produce Godot SpriteFrames/AnimationPlayer/pooled Node2D VFX only after explicit asset permissions. Actor can show selected 2-facing/mirror when user prefers; do not ask ImageGen to recreate hundreds of exact walk frames, which breaks animation consistency. Keep authored 8-way creature views where useful. FX may be 16 directions independent of actor sprites.
4. **Pure view:** overlay readable 1280×720 battlefield, HP/boss telegraphs, unambiguous damage/status, limited transient VFX and culling. Renderer interpolates positions between 0.25s authoritative ticks; never causes hit/loot/cast/damage.
5. **Performance/security:** exact encounter-use preload, no 7,203-image global eager load, atlas page size control, alpha preservation, status/FX budget, on-screen GPU memory measurement on a *real* Android device. Source web report's Mac FPS is not Android evidence.

## 5. Recommended SMALL implementation packets (require separate owner authorization)

**Gate 0 — Complete source inventory & rights, READ-ONLY NOW**
- Audit all folders with pagination; identify physical files for requested skills and actor clips, SHA-256 vs provenance manifest, original source PAK/SPR vs generated WebP, legal/redistribution status; report missing paths precisely. Priority actual Thanh Lang ani011 family, monster/boss mapping, desired four reference style families and VFX stages. Binaries currently insufficient to claim complete import.
- Rights unverified: NO asset binaries into public repo, build or GitHub. Owner may provide express license or cleared substitutes (separate Source A if authorized).

**Code Packet A — Combat skill completion, narrowly scoped**
- Finish existing 9 **in small event families**, not a one-shot rewrite: Truy Phong Bộ displacement/cancel/cooldown; true timed Guard/Weaken/Burn and FireCombo; equip and AI slot priority after compatibility rules. Each effect family separately authorized and benchmarked, with tests that prove real damage/status and no duplicate activation.
- For Model C, first derive congenital *recommendation* from already-stored birth data; allow school/curriculum choice but no runtime stat/class hard-lock or newly invented school-XP clock. Do not change core stats or Master Schema without gate.

**Code Packet B — Godot VFX registry/atlas adapter**
- Map 1 projectile, 1 melee, 1 status, 1 movement, 1 Boss telegraph from *actual code events* to scoped visual profiles, exact rects/anchors/dirs/frameMs and collision-time contract, missing-file fallback. C4-01 hotfix is an explicit dependency to verify. No game-calc owned by presentation.
- Focused test: asset checksum/rect bounds, frame direction, alpha, exact once visual event and status expiration, no hit before real impact, no RNG/HP changes when renderer enabled.

**Code Packet C — Visual pilot Thanh Trúc Lâm**
- Party6 with four distinct example build identities: Thiếu Lâm Kim Cương (tank), Võ Đang Ngự Kiếm (projectile), Ngũ Độc (real DoT), Nga Mi Y Đạo (real heal) plus two ordinary fighters; enemies Thanh Lang and a verified Hắc Lang Vương art candidate if allowed. Exact 6/party, boss warning, HP, cast and VFX. Art fallback must be openly marked placeholder when binary rights blocked; no fake wolf.
- Godot 4.7.2 focused battle and 1280×720 single actual gameplay pass if Windows runner exists; physical Android GPU/memory/touch still PENDING, no CI/FULL/merge unless separately authorized. Do not alter GP/G1/PR20/Economy/Scheduler/Save.

## 6. Decision and hard blocks

**Recommendation:** reuse source **metadata/presentation architecture**, not entire JavaScript battle game, and preserve canonical Combat V2. Distinguish source-data availability from actual downloaded WebP pages and from lawful license to ship. The small four-build pilot proves more than starting with ten classes and hundreds of untested VFX.

**Current blockers:**
1. Asset upload incomplete vs atlas manifest: 49/100 distinct FX references; 6/173 native image references; only 1 direct char sheet, while metadata points to many.
2. Art provenance and rights to copy/distribute JX1/VLTK VFX/sprites not established.
3. Godot full school runtime/effects and polished visual pilot not implemented; Windows/Android proof pending. No code changed during this study.

**Next user action:** finish/source missing directories, especially data/vltk/native/assets, data/vltk/char/ani011_*, data/vltk/fx, player full layers and applicable originals (Skills.txt, Missiles.txt, SPR, PAK); supply permission evidence if available. Keep original paths/hashes and omit __MACOSX. Then authorize one narrow packet at a time, starting with backend event truth and pilot import.
