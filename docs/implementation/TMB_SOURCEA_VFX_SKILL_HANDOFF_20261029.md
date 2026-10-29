# TMB — Source A & VFX handoff to V6.3/V6.4 skill development

**Date:** 2026-10-29 (Asia/Bangkok)  
**Scope:** documentation and proposed visual adapter contract only; **NO GAMEPLAY/ASSET CODE, NO MERGE**.  
**Base:** `feature/v63-d1-content-registry-20261029` at `6e4012d7a9e3a7efa56df349a176f9491d550742`.  
**Status:** `ART_INVENTORY_EVIDENCED / OWNER_MELEE_SAMPLE_APPROVED / LIVE_SKILL_VFX_UNWIRED`.  
**Purpose:** allow the skill/Codex implementation team to reuse real Source A disciples and researched JX/Cethiel VFX rather than authoring placeholder characters or new geometric effects.

## 1. Evidence and confidence separation

- **GH-VERIFIED:** this branch contains `godot/assets/combat_v5_source_a/visual_manifest.json`; prior recovery documentation `docs/architecture/TMB_CURRENT_IMPLEMENTATION_AUTHORITY_PROVISIONAL.md` records verified actor identities and clip routing. D1 docs at `docs/implementation/V63_D1_CONTENT_REGISTRY_HANDOFF.md` and `V63_D1_VALIDATION_EVIDENCE_20261029.md` establish 105 skill-family IDs, 531 progression records and nine Boss definitions as **read-only, feature gates OFF, gameplay unwired**. Structural registry audit passed; Godot tests remain `PENDING_ENGINE`.
- **LOCAL-CODEX-REPORTED (not re-run here):** owner-provided 2026-10-27 inventory of local E: sources and Asset Studio experiments, detailed below. Do not relabel those numbers as a fresh GitHub/runtime test.
- **OWNER-VISUAL-APPROVED (scoped):** owner viewed the newer melee pilot and explicitly said its VFX looked very good and aligned well. This acceptance covers **the specific viewed melee sample**, not every asset in the ZIP, not Godot runtime, not the older melee v001.
- **REJECTED/REVIEW:** Buff team aura v003 rejected by owner; v004 still visually unsatisfactory. Older procedural melee v001 is not the art baseline. Cethiel/JX references are candidates until viewed in the intended scene.
- **PENDING:** accurate weapon-hand socket and actor identity beyond confirmed asset IDs; continuous playback, full 6/30-actor Godot presentation, Android device and frame-time/memory/overdraw measurements.

Do not confuse file validity, playback preview, owner art approval and in-engine acceptance.

## 2. Source A — actors already available; DO NOT generate replacements

### Local source paths (from local Codex inventory; machine-only, not in GitHub)

- Master Spine: `E:\TongMonBaDaoWorkspace\02_SourceA\GameAssetExtract\Assets\Characters\AndroidData_character\spinelib`
- Duplicate archive: `E:\GameAssetExtract\Assets\Characters\AndroidData_character\spinelib`
- Converted Godot assets: `E:\TongMonBaDaoWorkspace\03_AssetLibrary\SourceA\GodotAssets`
- Known attack pilot: `E:\TongMonBaDaoWorkspace\03_AssetLibrary\SourceA\GodotAssets\1113028_1`
- Machine index: `E:\TMBD_Asset_Studio_v1\libraries\local_sources\LOCAL_ASSET_SOURCE_REGISTRY.json`

Previous inventory reported **6,578 Spine groups / 20,507 files**; actor `1113028_1` bake **18 clips / 453 frames**, and `attack1` **29 frames at 30 fps**. These are inventory assertions, **not** evidence that every rig can run/ship. Its `attack1` duration at native frame rate is about 0.97 s; the precise release frame must be measured from pose/weapon motion, not assumed.

### Existing in-repo visual identity

`godot/assets/combat_v5_source_a/visual_manifest.json`:

| Visual key | Source A identity | Combat scale in manifest | Status |
| --- | --- | ---: | --- |
| `disciple_female` | `1113028_1` | 0.34 | prior authentic active pilot |
| `disciple_male` | `1110201` | 0.42 | manifest/atlas, live route needs recheck |
| `monster_1113031_1` | `1113031_1` (Thanh Lang) | 0.42 | prior pilot enemy |
| `boss_slot_410041_1` | `410041_1` | 0.30 | asset/clip slot; no real boss authority yet |

Existing Source A actor clips `stand/run/attack1/hit/dead` have historically mapped to `idle/walk/attack/hit/die` in the V5 presentation. **Do not assume** every gender/weapon/skill variant has a bespoke cast, bow draw, dagger throw, fist punch or spell pose. Validate per actor/clip/weapon before binding a skill. If missing, mark `ANIMATION_GAP`, and reuse an actually verified compatible pose/overlay only as a **labelled candidate**, not a false perfect match.

Canonical project preference: Source A chibi actor and production/PvE world art; JX research is for skill mechanics and experimental VFX, with **separate owner visual approval before any shipped integration**. Existing asset authorization policy: `AGENTS.md` §14; do not re-query the owner for previously confirmed Source A/JX sources.

## 3. External VFX asset inventory and art decisions

### Curated CC0 2D sources

Local Codex audit reported Cethiel Weapon Slash, Light, Nature, Pure Projectile: **202 PNG** total (194 frames, 34 animation groups, eight previews), ZIPs successfully downloaded and structurally verified. Three selected candidate animations: **curved blue slash 6 frames; star-shaped hit impact 5; cross-shaped block spark 5**. These are useful **reusable action effects**, not a new actor. The subsequent Source A actor + Cethiel impact demo exists and was viewed by owner as part of the newer melee effort; retain exact manifest/checksums on E:.

### Võ Lâm/JX references

Local discovered roots:
- `E:\GFTU\data\vltk\fx` (reported 49 WebP);
- `E:\GFTU\jx-idle-main\fx` (reported 202 WebP; `fx.js` gives frame grid metadata for 191 entries);
- Đường Môn pack (reported 46 WebP in discovered directory; earlier archive had 65 WebP inclusive of extra actor/UI resources);
- Thúy Yên pack (reported four WebP);
- `E:\Tool JX\Client_VLTK\spr\effect` (five SPR, converter not verified).

Owner-supplied archives `skillduongmon.zip`, `thien-vuong-bang-skills.zip`, `thuyyendao90.zip`, `fx.rar` contain researchable VFX/metadata. Earlier `fx.rar` inventory: 202 WebP / 126 unique SHA-256, with distinct variants of some same-named clips. Keep source/version plus checksum; do not overwrite by basename. Examined sample effects included m38 and m146. **No successful general SPR/MPC conversion claim.** Do not confuse 8 verified JXQY2 INI records / 15 referenced VFX filenames with the much larger local JX/WebP libraries.

JX content is **research/visual candidate**; no automatic live import. Preserve exact provenance and separate source copies, not a license review loop. New release requires visual/performance gates.

### Studio paths

- `E:\TMBD_Asset_Studio_v1\artifacts\curated_melee_pilot_v1`
- `E:\TMBD_Asset_Studio_v1\artifacts\jx_vfx_master_pilot_v1`
- `E:\TMBD_Asset_Studio_v1\artifacts\local_asset_recovery_v1`
- `E:\TMBD_Asset_Studio_v1\libraries\local_sources\LOCAL_ASSET_SOURCE_REGISTRY.json`
- Legacy: `artifacts\buff_team_aura_v003`, `buff_team_aura_v004`, `melee_combat_vfx_v001`; their art is NOT approved.

**These E: paths are not repository paths and cannot be fetched by GitHub CI/Work Cloud.** Before future Godot integration, a narrowly selected, permitted-to-ship converted asset pack must be placed under a versioned game asset root with an import manifest. Never point runtime to `E:\...`.

## 4. Skill architecture compatibility — absolutely no implicit gameplay wiring

The new design files are under `docs/design/v63_v64_20261028/`. D1's `godot/data/combat/v63_content_registry.json` defines additive schools `bow`, `fist`, `poison` and nine branch paths (3 each). The legacy `sword/body/spell` paths must not be silently overwritten. D1 is a **read-only registry**; all new gates are OFF; numeric effects are candidates.

The design proposes family IDs `tmb.skill.<school>.<branch>.<slot>` and generation variants `<family>.human/.immortal.a/.immortal.b/.divine.a/.divine.b`. Visual binding must resolve **family + generation + event/variant**; do NOT match display name strings or invent one permanent VFX for all Divine branches. A passive/innate may require only an icon or short on-proc FX; static passive does NOT merit a looping particle effect. New loadout/ultimate/mobility and sixth passive authority disputes are outside visual adapter scope.

### Presentation event boundary (proposal; confirm actual live journal events before coding)

Authoritative combat state determines: eligible skill, targeting, range, damage/hit, miss/block, heal, absorb, status application, cooldown, boss telegraph geometry, hit recipients, and save. **Only** presentation decides textures, frames, opacity, position, facing, playback rate and LOD. No cosmetic event may re-trigger gameplay.

Suggested event mappings:
1. `cast_start` -> actor cast/attack clip + optional one-shot symbol;
2. `release` -> weapon slash/punch or projectile spawn, respecting the real attack frame/event;
3. `projectile_motion` -> movement only from authoritative trajectory/positions (no fake hit);
4. `hit_confirmed` -> impact on the actual impacted target; `miss` -> no impact; `block` -> block spark;
5. `status_applied` -> short apply marker; `status_triggered` -> reactive flash; `status_expired` -> remove persistent indicator;
6. `boss_telegraph_start/resolve` -> ground/sweep warning visible BEFORE authoritative damage, no false telegraph.

Names above are proposed adapter vocabulary, **not an assertion that the current Combat V2 journal already emits every field**. Map to actual existing event kinds as a first implementation step. Preserve determinism, pause/reload/Return behavior and exactly-once damage/reward settlement.

### Visual binding schema (candidate only)

The companion file `TMB_SOURCEA_VFX_VISUAL_PROFILE_CANDIDATES_V1.json` is a **planning map**, not production content and must never be auto-loaded as a combat authority. A future runtime-safe profile should reference:
`family_id`, `generation_variant`, `actor_visual_key` (selected by actual disciple identity), `weapon_tag`, `verified_clip`, `release_marker`, `source_asset_id`, `vfx_cast/travel/impact/block/persistent`, `direction_mode`, `anchor_ref`, `z_policy`, `lod_policy`, `missing_asset_fallback`, `visual_qa_status`.

Do not map a female actor to every disciple just because it is the only pilot verified. Verify male/female, equipped weapon and actual skill family, including new bow/fist/poison. Source A animation controls actor appearance; VFX overlays do not replace an actor.

## 5. Art direction for nine new branches

| New branch | Actor movement to verify | VFX candidate family | Avoid |
| --- | --- | --- | --- |
| Cung / Liệp Ảnh | real bow stance/draw/release | narrow arrow + target impact + weak trail | free-floating arrows from bare hand |
| Cung / Linh Tiễn | bow/cast compatible pose | luminous elemental arrow, small shock/spark | oversized explosion on every ordinary shot |
| Cung / Thiên Vũ | bow shot and spread/repeated release | controlled volley/multi-arrow | full-screen rain for every basic attack |
| Quyền / Bá Quyền | hand/arm contact punch | punch arc, impact/shockwave | sword-swing arc attached to empty fist |
| Quyền / Kim Cang | guard/stance and counter hit | short defensive sigil, block spark, counter flash | persistent giant bubble/rune |
| Quyền / Huyết Quyền | hand combo and contact | compact red hit/absorbed energy cue | opaque red overlay hiding pose |
| Độc / Độc Châm | throw/cast hand release | needle flight, tiny poison status glyph | Poison=large green cloud for each basic hit |
| Độc / Cổ Độc | cast/gesture and target effect | insect/mark/sigil, bounded infestation status | constant swarm on 30 actors |
| Độc / Dược Độc | cast/support hand cue | heal-cleanse sigil or toxic splash as authored | mixing healing and poison events blindly |

Old Kiếm/Thể/Pháp families retain their locked behavior and current visuals. Existing approved curved slash/hit/block is a reusable **melee presentation baseline**; do not silently attach it to fist, bow, poison or unrelated Boss casts. Main actor style remains Source A and 2D/2.5D, Android 1280×720.

## 6. Implementation handoff — prioritized without disrupting current skill D1

**P0 — reconciliation & asset identity (docs + isolated Studio):**
1. Read source registry and check exact local files exist; verify Sha/clip/frame/atlas and owner-approved sample identity (do not guess which artifact from a vague “melee” approval).
2. Map actual real Combat V2 and planned V6.3 events; find where actor visual key is selected. Enumerate current actor/weapon/clip gaps, especially bow draw, fist strike and poison throw. First build `ANIMATION_GAP_MATRIX`.
3. Resolve any disagreement between existing V5 manifestation and current PR #52 presentation before touching runtime.

**P1 — adapter proof using existing Source A + approved melee VFX (Asset Studio first):**
- Run sample for 1v1 and 6vN on the actual Source A actor, validate correct animation frame/anchor/facing/depth, hit/miss/block, snapshot load no reapply.
- Include a bow/fist/poison **readiness preview**, but if actor clips are absent mark `BLOCKED_BY_ANIMATION`; never substitute fake actor art silently.
- Collect real GIF contact sheet/video and a short QA matrix; owner reviews new presentation variants individually.

**P2 — safe Godot visual-only integration, separate feature branch after D1 engine focused tests:**
- Small versioned PNG/atlas pack with sha source manifest + optional visual adapter; explicit visual gate OFF default. Reuse existing `CombatV5` presenter/data pipeline rather than a second battle engine; no journal/sim/gameplay/save writes.
- Test exact Godot 4.7.2 import, no missing resources, resolution 1280×720, actor gender/weapon, 1v1, 6v10, 30 actors, Boss telegraph, hit/miss/block, Return/Reload; check minimal/reduced VFX LOD and FPS/RAM. Do not claim mobile PASS without Android run.
- No unauthorized source copy, base gameplay edit, PR #52 mutation or merge. Numeric skill effects remain D1 feature-gated.

**P3 — broaden VFX only after skill behaviors stabilize:** iterate a family-based catalog for 9 new branches plus old Kiếm/Thể/Pháp; select by event and real animation, not “one VFX per skill” or random huge spell art. Prefer existing JX/Cethiel clips over procedural VFX, but accept only when visuals fit Source A.

## 7. QA / release gates

| Gate | Must prove |
| --- | --- |
| SOURCE | exact path and checksum, stable copied export, duplicate handling |
| ACTOR | authentic Source A for actual disciple identity/gender; weapon/pose/clip verified |
| SYNC | release-frame and attack anchor grounded in actual animation; hit/miss/block honest |
| VISUAL | owner review at 48/64/75/96 px and 1280x720 scene; buff symbols short, readable |
| DENSITY | 1/6/30 actors, no opaque clutter, boss warnings visible |
| ENGINE | Godot 4.7.2 import + focused test log + real playback |
| PERFORMANCE | measured frame time/FPS/RAM and LOD comparisons on representative hardware |
| SAVE | no duplicate VFX application/status/damage after Return/Reload; visual replay is non-authoritative |
| SCOPE | no simulation code/save/warehouse or numeric balance mutation from visual branch |

Status vocabulary: `SOURCE_VERIFIED`, `ART_CANDIDATE`, `OWNER_VISUAL_APPROVED_FOR_REVIEWED_SAMPLE`, `ANIMATION_GAP`, `ENGINE_PENDING`, `GAMEPLAY_UNWIRED`, `GODOT_VISUAL_PASS`. Never promote any other asset just because a sample looked good.

## 8. Next concrete Codex job

Start with **P0 plus one P1 melee demo**; output in `E:\TMBD_Asset_Studio_v1\artifacts\sourcea_vfx_v63_bridge_p1\`:
- verified actor inventory incl. exact clip/frame/weapon anchor per actor;
- asset provenance and chosen sample SHA;
- `VISUAL_PROFILE_MAP.json` candidates keyed by stable V6 family ID + legacy ID;
- 1 Source A melee hit/miss/block GIF with exact timing, one 6vN visual density capture;
- explicit animation-gap list for Bow/Fist/Poison;
- static QA vs visual QA vs Godot 4.7.2 separately.

No new animation-generation spree, no VFX redesign of approved melee, no 105-family mass implementation, no background Godot run claim. Skill D1 (read-only) stays untouched.

## Reference links

- [D1 handoff](../implementation/V63_D1_CONTENT_REGISTRY_HANDOFF.md)
- [D1 evidence](../implementation/V63_D1_VALIDATION_EVIDENCE_20261029.md)
- [V6.3/6.4 authority matrix](../design/v63_v64_20261028/01_AUTHORITY_AND_CONFLICTS.md)
- [V6.3 content registry](../design/v63_v64_20261028/02_CONTENT_REGISTRY.md)
- [V2 skills](../COMBAT_SKILLS_V2_SPEC.md)
- [V5 actor manifest](../../godot/assets/combat_v5_source_a/visual_manifest.json)
- [Owner standing rights rule](../../AGENTS.md)
