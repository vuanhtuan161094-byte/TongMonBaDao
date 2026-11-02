## FINAL DELIVERY — Windows playable RC status (2026-11-02)

**Status: BLOCKED for physical Windows delivery; automated focused QA PASS.** Live PR #67 HEAD was checked as `df6f55ee63d36c77e52b5d9eaf3c5743349b935a`; code/capture SHA tested by official Godot 4.7.2 is `8979dca68495a74ad272ca4c861034040bf385f7`. PR stays Draft and unmerged.

### Exact-SHA evidence

[Godot 4.7.2 O2 workflow 41402324227](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41402324227) completed SUCCESS: import/parse, O2, P3.7C1/Dẫn Tiên, B1 contract/live callbacks, independent two-process SaveService reload, DD092, Source A checks, four 1280×720 map/B1 captures and P3.6A. [Capture artifact](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41402324227/artifacts/13122450868). This was Ubuntu/Xvfb/llvmpipe, not Windows mouse acceptance.

### E: source and launcher

- Canonical `E:\TongMonBaDaoWorkspace\01_Game\TongMonBaDao` is unchanged on `main` @ `5e6fdd966bdf710b71e2a1539bb712e44069a4bb`, with the existing seven untracked QA entries preserved. No user save was accessed.
- Exact-source folder `E:\TongMonBaDaoWorkspace\01_Game\TongMonBaDao_PR67_QA` and launcher `E:\TongMonBaDaoWorkspace\01_Game\CHOI-GAME-THU.cmd` are **not present**. The official binary exists at `E:\TongMonBaDaoWorkspace\04_Tools\Godot\Godot_v4.7.2-stable_win64.exe` and reports `4.7.2.stable.official.ed1daf0bf`.
- Local Git does not contain commit `df6f55ee63d36c77e52b5d9eaf3c5743349b935a` (`git cat-file -e` failed). E: main is 259 commits behind PR base `970af33b` by ancestry; it cannot serve as a PR67 checkout.
- Fetch attempts: Git HTTPS/GCM returned `SEC_E_NO_CREDENTIALS`; disabling the helper for a read-only OpenSSL attempt could not prompt without a TTY; codeload and the signed Actions artifact URL both returned Windows `Authentication failed`; Node fetch also failed. The authorized GitHub connector provides metadata/text but not a local binary source archive.
- No launcher was created against a missing checkout, so it cannot be mistaken for a playable PR67 build.

### O6 / GP-01 / GP-02A locator assessment

Static review at PR #67 shows those older tests search for `GuidanceRecruitOrder` and `AcceptCandidate_<id>`. Current B1 controls are named `UseRecruitmentOrder` and `AcceptCandidate`; the live adapter connects those controls to canonical RecruitmentSystem callbacks. The exact-SHA O2 live integration gate passes real recruitment and independent reload. This supports a **legacy test-locator mismatch**, not evidence that recruitment gameplay is broken. No fake controls were added and no assertion was weakened. The complete O6/GP runs remain **PENDING** on Windows.

### Final gates

| Gate | Status |
|---|---|
| Exact-SHA Godot 4.7.2 automated focused suite and 4 captures | PASS |
| Windows PR67 QA checkout and one-click playable launcher | BLOCKED — source transfer/auth unavailable |
| Windows 1280×720 mouse playthrough of three facilities | PENDING USER |
| GUI Save → exit → launcher → Reload receipt verification | PENDING USER |
| Android/touch and owner visual acceptance | PENDING USER |

Safe workaround: restore official Git Credential Manager sign-in in the Windows session (no token/password in chat), then fetch this existing branch into the isolated QA folder. The canonical game directory and untracked files must remain untouched. Do not claim PLAYABLE RC until the launcher runs this exact PR source.

---

## O6/GP legacy locator review

The older `p3_o6_m1_release_rehearsal_test.gd`, `gp_01_v2_mine_vertical_slice_test.gd`, and `gp_02a_v2_cultivation_panel_test.gd` locate `GuidanceRecruitOrder` and per-candidate `AcceptCandidate_<id>`. The B1 Dẫn Tiên controls are `UseRecruitmentOrder` and `AcceptCandidate`, and `tri_facility_b1_live_integration_test.gd` asserts those controls and the canonical live recruitment callbacks. O2 on the exact code SHA passes live recruitment plus SaveService cross-process reload. This indicates the legacy locators are incompatible with the current B1 surface; it does not prove the whole O6/GP scenarios pass. Those full tests remain pending Windows exact-source execution. No fake controls or weakened assertions were added.

## TRI-03 — Windows playable acceptance & UI polish status (2026-11-02)

**PR #67 code commit tested:** [`8979dca68495a74ad272ca4c861034040bf385f7`](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/8979dca68495a74ad272ca4c861034040bf385f7). Official Godot 4.7.2 workflow [41402324227](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41402324227) completed **SUCCESS** on this exact commit. Four real Godot 1280×720 P3.2/B1 captures are in [artifact 13122450868](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41402324227/artifacts/13122450868). The run used Ubuntu/Xvfb/llvmpipe: this is automated real-render evidence, **not Windows mouse acceptance**.

### Change and visual comparison

The TRI-03 code delta is limited to raising the shared B1 button minimum height from 46 to 48 px and the map “QUẢN LÝ ĐẦY ĐỦ” control from 42 to 48 px. No gameplay, canonical callbacks, Source A files, SaveService, or save profile changed. The four 320×180 QA review thumbnails from the prior capture and this exact run retain the same map/Hall/Residence/Guidance composition; no new overlap or clipping is visible at thumbnail scale. Detailed pixel-level review of the native 1280×720 files and owner visual sign-off remain pending.

Source A stayed SHA-gated and passed runtime alpha/import checks:
- 510052: `b6bf88c35e3edc33aba822124296af15a5c8491a05c28f6b5d7b342d20d5325c`
- 510076: `f8e05d7376fc5ddc7b25f56673b6d5f444b10fd759da06a5929ec4f38a68d320`
- 510111: `90b7c595f3b77788c99924ef2eb7ba4b8ede794ccffda1c6808263ba3c711762`

Guidance uses the 510111 facility art separately from the candidate portrait. The candidate image remains the previously documented neutral fallback; no approved candidate portrait was introduced.

### Exact-SHA QA matrix

| Gate | Result | Evidence |
|---|---|---|
| Official Godot 4.7.2 version and project import/parse | PASS, exit 0 | O2 run 41402324227 |
| P3 O2 recruitment/map actor test | PASS | `P3 O2 RECRUITMENT MAP TEST PASS` |
| P3.7C1 / Dẫn Tiên backend | PASS | `P3.7C1 FOUNDATION + DAN TIEN RECRUITMENT TEST PASS` |
| B1 canonical screen contract | PASS | `TRI01_B1_UI_CONTRACT_PASS` |
| Live Hall/Residence/Guidance callbacks and SaveService | PASS | `TRI_B1_LIVE_PASS hall=1 residence=1 guidance=1 real_recruit=1 save_service_roundtrip=1` |
| Separate-process SaveService reload | PASS | `TRI_B1_CROSS_PROCESS_RELOAD_PASS roster=7 queue=1 houses=1 accepted=candidate_0001` |
| DD092 exterior door/chosen plot + save reload | PASS | `DD092_DOOR_PLOT_PASS road_gate=none chosen_plot=1 exterior_door=1 save_reload=1 conflict=1` |
| Source A alpha assertions and 4 map-context/B1 renders | PASS | `TRI02_SOURCE_ALPHA_PASS` ×3; `TRI02_P32_CONTEXT_CAPTURE_PASS map=1 hall=1 residence=1 guidance=1 size=1280x720` |
| P3.6A scene regression | PASS | `P3.6A PLAYABLE SLICE TEST PASS` |
| Windows physical mouse journey, New Game → 3 facilities → Save/Return/Reload | **PENDING USER** | No Windows GUI interaction was performed in this run |
| Android device/touch acceptance | **PENDING USER** | No device test |

The capture job logged that the CI graphics driver does not support changing V-Sync and that the runner has no ALSA device; Godot fell back to dummy audio. All capture markers, the P3.6A marker, and the job completed successfully.

### Windows gate / limits

The canonical E: game directory remains untouched. At verification it was `main` @ `5e6fdd966bdf710b71e2a1539bb712e44069a4bb`, with seven existing untracked QA entries; it is not the PR #67 source and was not used as a substitute. Git CLI fetch with GCM failed to prompt/persist credentials (`SEC_E_NO_CREDENTIALS` / no interactive TTY); the HTTPS archive request also failed authentication in this session. Therefore no exact-SHA Windows checkout, Windows GUI journey, or Windows screenshot/log exists yet. `Get-Process` showed no Godot/MovieWriter entries; a complete process-command-line check was unavailable due Windows access denial in the earlier probe. No user/default save was read or written.

**Overall:** exact-SHA automated focused QA is PASS; TRI-03 physical Windows playable acceptance is **PENDING USER**, Android is **PENDING USER**, and broad visual polish/owner approval is not complete. Keep PR #67 Draft and do not merge.

---

# B1 three facility screens — integration preview

## TRI-02 Source A intake and live P3.2 capture — 2026-11-02

**Exact tested code+capture SHA:** `b5b4d496c4bfdafdf343a12733acaa29625efdd4` (production Source A/UI code is in its parent `ea06e31e9ea4c2188de3aca6f828317c0189e975`) on the existing PR #67 branch. The historical TRI-01/V2.2 notes below describe the earlier `a97c946` checkpoint; statements there that Residence and Guidance PNGs were absent are superseded by this section.

### Verified production sprites

| Facility | Source A model | Runtime file | SHA-256 | Dimensions | Classification |
|---|---:|---|---|---:|---|
| Đại Điện | 510052 | `godot/art/source_a_env02a/pv01_assets/main_hall/510052.png` | `b6bf88c35e3edc33aba822124296af15a5c8491a05c28f6b5d7b342d20d5325c` | 1104×740 | Existing full building sprite |
| Đệ Tử Xá | 510076 | `godot/art/source_a_env02a/pv01_assets/residence/510076.png` | `f8e05d7376fc5ddc7b25f56673b6d5f444b10fd759da06a5929ec4f38a68d320` | 536×416 | Imported original full building sprite |
| Dẫn Tiên Đài | 510111 | `godot/art/source_a_env02a/pv01_assets/guidance/510111.png` | `90b7c595f3b77788c99924ef2eb7ba4b8ede794ccffda1c6808263ba3c711762` | 532×592 | Imported original full building sprite |

The exact PNGs are SHA-gated by the existing Source A adapter. Each source `.atlas` was inspected: it contains one region covering nearly the entire PNG, not a collection of loose parts. The runtime uses the complete PNG directly and preserves its aspect ratio. Alpha checks on the original bytes passed for transparent, opaque and antialiased pixels for all three models. The source `.skel` files and atlas hashes are recorded in `godot/data/presentation/tri_facility_source_a_manifest.json`.

The shared B1 renderer now uses the matching Source A building sprite on all three actual management screens. Dẫn Tiên Đài shows model 510111 in its header; a disciple candidate remains the anonymous neutral fallback because no approved candidate portrait is mapped. Source luminance masks were not composited: the original material/blend behavior is unvalidated. The catalog records external redistribution scope as unverified; this intake is not a license determination.

### Exact-SHA Godot 4.7.2 QA

[O2 workflow run 41400397206](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41400397206) completed **SUCCESS** on the exact code+capture SHA above. The artifact contains four real Godot-rendered 1280×720 PNGs: P3.2 map context, Đại Điện, Đệ Tử Xá and Dẫn Tiên Đài: [download PNG archive](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41400397206/artifacts/13120779305). Relevant live capture markers include `TRI02_SOURCE_ALPHA_PASS` for each building and `TRI02_P32_CONTEXT_CAPTURE_PASS map=1 hall=1 residence=1 guidance=1 size=1280x720`.

| Check on exact SHA | Result |
|---|---|
| Official Godot 4.7.2 install/version and project import | PASS |
| O2 recruitment/map actor persistence | PASS |
| Dẫn Tiên backend regression | PASS |
| B1 UI contract | PASS |
| B1 live callbacks and independent process SaveService reload | PASS — roster 7, queue 1, one house, accepted candidate_0001 |
| DD092 exterior-door/plot regression | PASS |
| Live P3.2 map → all three B1 screens, model IDs and 1280×720 frames | PASS |
| P3.6A regression | PASS |

The capture uses the actual P3.2 scene and its real management buttons under Ubuntu/Xvfb with llvmpipe. 320×180 review thumbnails generated from those same frames were visually reviewed; the full-resolution 1280×720 frames remain in the artifact. It is an automated render harness, **not** physical Windows mouse acceptance. The run emitted nonfatal CI audio-device/V-Sync warnings; Godot used its dummy audio driver.

**Before reference:** [TRI-01 V2.2 B1 captures](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41391730042/artifacts/13116893857) show the earlier UI checkpoint before importing 510076 and 510111. That artifact was captured in the previous B1 state harness and is not the same P3.2 map-context route; use it only as a historical visual reference.

### Still pending

- Owner review of visual composition; physical Windows mouse and Android device.
- Redistribution rights outside the source workspace.
- Approved disciple-specific portraits and historical approved S3 building masters. Neutral candidate art remains a clearly separate fallback.
- Project-wide CI not covered by the focused O2 workflow.

## TRI-01 V2.2 art/UX release evidence — 2026-11-02

**Scope:** existing Draft PR #67 only, no new branch or main merge; canonical simulation, SaveService, economy and PvE are unchanged. The existing screenshot fixtures near the bottom of this document are historic B1 gallery captures, not the new live V2.2 evidence.

**UI polish from real 1280×720 screenshots:** real Source A Đại Điện selected through SHA gate; original image-based Residence and Guidance studies; independent anonymous candidate portrait fallback; 7 office avatars no longer use repeated initials; moved "Quản lý đầy đủ" from bottom overlay into header so Build/Upgrade controls remain accessible; bigger bed cards and radar labels; full-width residence and candidate metrics; client-only Vietnamese mapping of exact canonical origin/race/source/root/profession trait IDs without changing underlying IDs or saves; residence IDs displayed as house ordinals only. No new gameplay authority.

**Original Source A intake targets found in** `vuanhtuan161094-byte/ZQZS-Source-Knowledge`, `transferkit/Catalog/BUILDING_VISUAL_INDEX.csv`:

| Game facility | Source A model | Original isolated PNG and SHA-256 | Runtime disposition |
|---|---|---|---|
| Đại Điện | `510052` | Existing `godot/art/source_a_env02a/pv01_assets/main_hall/510052.png`, `b6bf88c35e3edc33aba822124296af15a5c8491a05c28f6b5d7b342d20d5325c` | Available now through `SectMap25SourceArt.texture_for` SHA gate |
| Đệ Tử Xá / Phòng Ốc | `510076` | `E:\GameAssetExtract\Assets\Characters\AndroidData_character\spinelib\build\510076_skeletondata\510076_Texture2D_815792867394781754.png`, `f8e05d7376fc5ddc7b25f56673b6d5f444b10fd759da06a5929ec4f38a68d320` | **Verified catalog entry only; missing from game repo**; original V2 SVG fallback active |
| Dẫn Tiên Đài | `510111` | `E:\GameAssetExtract\Assets\Characters\AndroidData_character\spinelib\build\510111_skeletondata\510111_Texture2D_3239249786622463018.png`, `90b7c595f3b77788c99924ef2eb7ba4b8ede794ccffda1c6808263ba3c711762` | **Verified catalog entry only; missing from game repo**; original V2 SVG fallback active |

The two missing PNGs must be copied from owner Windows workspace in an isolated, hash-checked intake. Verify atlas regions, silhouette/transparency, stage/map scale and Android exports before calling them production assets; preserve rights metadata. Do **not** fabricate assets with identical source names or rename new SVG art as historical approved S3 masters. Approved disciple-specific portraits remain PENDING; anonymous candidate study is not a character identity.

**Official CI proof (earlier exact art SHA):** O2 run [41391246555](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41391246555) at `76d8b4861d98e3574c9a2dee56de2eae501ce1df` has 4 visual textures and verified SourceA Hall, cross-process SaveService save+reload (roster 7, one accepted candidate), hall/residence/guidance callbacks, P3.6A map-label regression and 3 real 1280×720 capture steps **PASS**. **Latest V2.2 Godot gate PASS:** O2 run [41391730042](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41391730042) at exact UI code SHA `a97c946ca5b0fb161b4c6ac8797d3791c873f8c0`, all workflow steps success, including 4 imported art textures, SHA-verified Source A Hall, canonical B1 callback smoke, SaveService cross-process reload, 1280×720 screenshots, P3.6A uncluttered map regression. The [latest visual artifact](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41391730042/artifacts/13116893857) includes three live-state PNGs. Full repo CI is a separate gate. Linux/Xvfb/llvmpipe capture is not a physical Windows mouse or Android playtest. No save in default APPDATA is used by the isolated QA.

**Final acceptance:** owner visual approval **PENDING**, physical Windows input **PENDING USER**, Android **PENDING USER**, Source A residence/guidance import **PENDING SOURCE INTAKE**, unrelated repository-wide CI red workflows need separate assessment. This packet is not FULL GAME completion.


## TRI-01 visual V2 addendum — 2026-11-02 (PR #67)

Status: CODE COMMITTED; Godot 4.7.2 new-art CI RUNNING at `d92a21ee79981260c994eedc0859fd1d688eca1c` when authored. Visual approval, physical mouse and Android are still **PENDING USER**. This visual layer is presentation-only; it does not change Hall, Residence, Recruitment, SaveService, economy or PvE rules.

**What changed:** The three B1 views now use `sect_facility_art_v2.gd` through the shared theme. The renderer first requests the in-repository Source A main-hall art `res://art/source_a_env02a/pv01_assets/main_hall/510052.png`, exclusively through `SectMap25SourceArt.texture_for()`. The source gate checks the fixed map25 manifest SHA-256 `b6bf88c35e3edc33aba822124296af15a5c8491a05c28f6b5d7b342d20d5325c` before returning the texture. If unavailable, it falls back to **new original art**, not a false Source A attribution.

- `res://art/uiux/hall_paint_v2.svg`: original hall composition, fallback only.
- `res://art/uiux/residence_paint_v2.svg`: original residence courtyard composition; no approved source residence PNG exists in the repository at this checkpoint.
- `res://art/uiux/guidance_paint_v2.svg`: original guidance ceremonial gate composition; this is not a disciple portrait.
- `sect_facility_illustration_v1.gd` remains a final fallback if SVG texture import fails.
- The Source A verification tooltip distinguishes imported source from original study artwork; missing office portraits use a neutral unassigned silhouette, not duplicated name initials.
- B1 art has more vertical space, borders/shadows are tuned for 1280×720 and touch-oriented buttons remain at least 46px high.

**Asset authority caveat:** `docs/P3_ASSET_REGISTRY.json` still records historic approved S3 building masters as unrecovered. The above main-hall texture is a **different, identifiable Source A runtime candidate**, not a claim to have recovered that historical S3 master. Original V2 illustrations are a new study, not a replacement labeled as the previously approved source. Do not use their presence as proof of production visual acceptance or distribution rights.

**Automated evidence requested in existing O2 workflow:** official 4.7.2 import, source-art-script `--check-only`, `tri_facility_b1_art_v2_test.gd` (imported texture and SHA gate), existing B1 callbacks, in-engine real-state UI captures, SaveService and P3.6A checks. No PASS is claimed until GitHub run concludes; follow the run on the exact source SHA. The runtime image output, not these original B1 gallery PNGs, is the evidence to review.

**Open gates:** owner visual selection of illustration style; high-resolution source portraits actually mapped to candidate/appointed disciple identities; production-art provenance for Residence/Guidance; physical Windows mouse/Android; total CI regressions unrelated to this visual-only diff; verify exported Android fallback preloads and SHA-gated PNG behavior on device.


Branch: `feature/codex-b-uiux-b1-20261102`  
RC base: `rc/one-game-playable-20261101` @ `970af33b23076c80d677cf5898a721a27504708f`

This package adds three Godot-native presentation screens and a standalone preview gallery. Each screen exposes `bind_view_model(view_model: Dictionary)` and typed intent signals. It does not call simulation, save, scheduler, economy, building, warehouse, recruitment, or combat authority.

## View-model and callback contract

| Screen | Read-only input fields | UI intent signals |
|---|---|---|
| Đại Điện | `building_level`, `rank_step`, `rank_progress`, `rank_requirement`, `can_promote`, `can_upgrade`, `upgrade_costs[{name, amount, icon}]`, `offices[{id, disciple_name, portrait, office_rank}]` | `office_selection_requested(role_id)`, `promotion_requested`, `hall_upgrade_requested`, `closed` |
| Đệ Tử Xá | `building_level`, `room_count_label`, `bed_slots[{id, occupied, disciple_short_name}]`, `sites[{id, name, status, resident_summary, built, can_build, can_upgrade}]`, `selected_residence_id` | `site_selection_requested(site_id)`, `residence_build_requested(site_id)`, `residence_upgrade_requested(residence_id)`, `closed` |
| Dẫn Tiên Đài | `candidate[{id, name, realm, origin, personality, status, portrait, source_art_approved, tam_values[3], tu_values[4]}]`, `can_accept`, `can_reject`, `can_lead_in`, `can_recruit`, `metrics[{label, value, icon}]`, optional `radar_factory: Callable` | `candidate_page_requested(direction)`, `accept_candidate_requested(candidate_id)`, `reject_candidate_requested(candidate_id)`, `lead_in_requested(candidate_id)`, `recruit_candidate_requested(candidate_id)`, `closed` |

The host supplies all costs, status text, rank progress, occupancy, candidate values, and action eligibility. Screens only display those values and emit intents with IDs. The D7 radar renders three Tam and four Tứ values as separate series. The host may pass a factory for its canonical radar control.

## Rendered 1280×720 captures

These were captured from the Godot 4.7.2 OpenGL game viewport with the gallery capture runner. They show sample data and are not connected gameplay.

- Đại Điện: ![Đại Điện B1 preview](images/b1_dai_dien.png)
- Đệ Tử Xá: ![Đệ Tử Xá B1 preview](images/b1_de_tu_xa.png)
- Dẫn Tiên Đài: ![Dẫn Tiên Đài B1 preview](images/b1_dan_tien_dai.png)

## Verification

Godot binary: `Godot_v4.7.2-stable_win64.exe`, `4.7.2.stable.official.ed1daf0bf`.

| Check | Command / evidence | Result |
|---|---|---|
| Import | `--headless --path <QA>/godot --editor --quit` | PASS, exit 0 |
| Callback/data contract | `--headless --path <QA>/godot --script res://tests/presentation/b1_trifacility_ui_contract_test.gd` | PASS, exit 0 |
| 1280×720 layout host | `--headless --path <QA>/godot --script res://tests/presentation/b1_trifacility_layout_test.gd` | PASS, exit 0 |
| Render captures | `--path <QA>/godot --script res://tests/presentation/b1_trifacility_capture_screenshots.gd -- <output-dir>` | PASS, all three 1280×720 PNGs saved |

The Windows runner prints `Failed to read the root certificate store` during startup; the engine commands exit 0 and import/tests/capture succeed. GUI mouse review through Computer Use was unavailable because its app approval timed out. The saved captures were visually inspected as image files; owner visual review remains pending.

The QA source clone is isolated under Codex documents and came from local main SHA `5e6fdd966bdf710b71e2a1539bb712e44069a4bb`, not the exact RC checkout. B1 files are new and self-contained under `godot/src/presentation/uiux`, its preview scene and presentation tests; the remote commit is based on current RC `970af33...`. The import/test result therefore validates these new components in Godot 4.7.2 but is not an RC integration or gameplay acceptance.

## Screen coverage and asset boundary

- **Đại Điện:** seven role cards with portrait slots/placeholders, building level, 27 supplied rank segments, supplied requirement and costs, eligibility-gated promotion/upgrade callbacks.
- **Đệ Tử Xá:** original facility illustration, supplied bed/resident records, selectable plot cards with supplied state, build and upgrade intent callbacks.
- **Dẫn Tiên Đài:** caller-approved optional portrait texture; original vector fallback; candidate details; independent 3-value Tam / 4-value Tứ radar; accept/reject with two-tap rejection; lead-in and recruit intents.
- The gallery labels all fixtures as sample data. It is an integration preview, not connected gameplay.
- No Source A/JX or third-party art is included. All illustrations and glyphs are original Godot vector drawing code.

Host-game integration, wiring of current game data/actions, portrait rights/candidate tests, and owner visual review remain pending.
