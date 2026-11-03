# TRI-03 P0 Windows follow-up — 2026-11-03

Status: implementation checkpoint; full owner playable acceptance remains OPEN. PR #67 stays Draft.

## Runtime identity and launcher

Launcher: E:\TongMonBaDaoWorkspace\01_Game\TongMonBaDao\CHOI-GAME.cmd

Local checkout branch is integration/tri-facility-a-b-playable-20261102; local Git HEAD remains 27ed01cd8f377994e5e50bac9ede84e78e8895bd with preserved working changes and generated import files. This is a verified source overlay, not a clean checkout of the published commit. Upstream source parent is 7f732c74bc87d4f579d6a90442b036f1040995da.

Current runtime fingerprint: db30cfb372ec539331f8dbaa66f331be82e80fe0818224b1d5cb9a41a0da3fce (40 pinned files). Each changed code blob in this commit was checked against the local Git hash used by the launcher. The launcher verifies all changed Godot source, prints the actual local HEAD and fingerprint, imports when the fingerprint changes, and checks for a responsive game window. Official binary: 4.7.2.stable.official.ed1daf0bf. Preflight exit 0.

Save profile is isolated under E:\TongMonBaDaoWorkspace\03_QA_Logs\TRI03_OWNER_FINAL_20261103\owner_play_profile. Default player saves were not opened or overwritten.

## Implemented and exercised

- Canonical Residence placement and eligible annex relocation retain paid costs, site/door/path/collision checks and exactly-once receipts.
- Recruit -> real HS-09 deep profile -> Workforce assignment -> Save -> independent-process Reload passed. Reload retained candidate_0007, roster 7, spirit_field_001 and recruitment tokens 2.
- Current 1280x720 build-mode hint is fully readable and explains supported construction.
- Launcher start helper distinguishes process creation from an actually responsive game window.

## Windows test evidence

The 14-case core matrix passed with exit 0: import, B1 contract/art/live save, independent B1 reload, P3.6A, P3.7C1, Warehouse, DD092, O2, GP01, GP02A, O5 and O6. This matrix predates the final display-only build-hint edit; it is not presented as a complete final-SHA rerun.

After that edit, current fingerprint db30cf passed import, B1 contract, real OpenGL map placement/relocation capture, independent map reload, recruited HS-09/assignment render flow, and independent recruit reload. Map reload markers: TRI_MAP_BUILD_CROSS_PROCESS_RELOAD_PASS and TRI_MAP_RELOCATION_CROSS_PROCESS_PASS, exit 0. HS-09 reload marker: TRI03_RECRUIT_HS09_CROSS_PROCESS_RELOAD_PASS, exit 0.

[Matrix](TEST_MATRIX.csv) · [Unmodified stdout/stderr combined with file delimiters](raw_logs_current.txt)

Original latest PNGs are retained locally in real_rendered_frames_post_patch_20261103 under the QA root. Captures are actual Godot OpenGL frames using injected UI input, not physical mouse acceptance. Renderer: OpenGL 3.3 Compatibility, Intel Iris Plus, driver 31.0.101.2125.

## CI triage and remaining acceptance

Historical 20a9bfd CI: 9 success / 9 failure. Actual logs identified stale GuidanceRecruitOrder locators in GP/O6; tests now exercise UseRecruitmentOrder and its canonical debit. O5 direct scheduler advancement left its wall-clock anchor stale before the save barrier; the test now reanchors the test clock while retaining upgrade/progress/resource assertions. Current local GP01/GP02A/O5/O6 exit 0. Production SaveService and economy were not changed.

DV2-02 group initialization and DV2-03 canonical combat-stat failures remain separate unresolved regression debt. No claim of full repository CI PASS; new-commit Actions status must be read separately.

Only Residence has canonical map placement authority. New Game starts Hall Lv1 with one house; the next Residence requires Hall Lv11 and real resources. Placement captures use explicitly seeded in-memory QA prerequisites. Natural New Game -> production -> Hall Lv11 -> player-built house remains UNVERIFIED. Other initial unique buildings retain fixed positions; no fake build or direct state mutation was introduced.

Prior Windows retry failed in GLES shader initialization with signal 11 through ig11icd64.dll. Current map and HS-09 render runs succeeded, but repeated clean-launch stability is still UNVERIFIED; cause is not established. All Godot stderr streams retain the environment warning about reading the root certificate store.

Physical mouse end-to-end playthrough, Android/touch, full natural construction progression, repeated graphics stability and final full CI acceptance remain PENDING. This is not PLAYABLE/GUI PASS.

## Exact-code follow-up on a166252

Three independent Windows OpenGL capture processes (PIDs 3524, 18952, 1020) each completed exit 0 using fresh isolated profiles. All three newly opened capture processes exited; pre-existing PIDs 6428 and 14692 were left untouched. The prior shader/Intel crash was not reproduced in these three runs; this does not establish absence of intermittent failure. Original logs include inline base64 image previews; those preview lines are omitted from the appended text archive, while original PNGs/logs remain on E:.

[Current build gate, 1280x720](screenshots/current/01_new_game_build_catalog_gate.jpg) · [Actual HS-09 profile, 1280x720](screenshots/current/07_hs09_real_recruit_profile.jpg). JPEG copies are quality-90 encodings of the original Godot PNGs; no UI was composited.

CI snapshot on exact code a166252: 8 success (O1/O3/O4/O5/O6/O7/O8/P3.6A), 1 failure (DV2-03), 7 still running (O2, P3.7, GP01, GP02A/B1/C1, Economy-A). Full CI remains open. [Actions for this code SHA](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions?query=head_sha%3Aa166252e634127337c9d74ee125f02e4a477a2d1).
