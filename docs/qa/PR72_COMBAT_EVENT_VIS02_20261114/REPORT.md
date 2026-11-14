# Combat Event Infrastructure + VIS02 QA — 2026-11-14

## Source identity and limits

- PR #72 branch: `integration/pve-p0-playable-ui-20261103`.
- Live PR HEAD at finalization check: fcba3dc73940fe73bb78c2938c247d959d36fa2b, tree 49264e96d843fafdc8170307e24e00a38014106f.
- QA source was a **reconstructed snapshot**, rooted at commit `03302b1e2c96bb76b726d0b06728bf67429bfcfd` / tree `bd923663b90945f716bee0f4ca862702b6cdc943`, with selected verified presentation/art blobs through `0277e9e636b2075fac358a6cc14dfc281a48b033` and this task's combat/harness patch. This is **not a native Git checkout** and is **not a full-tree exact-SHA run**.
- Earlier recorded comparison from reconstructed base 03302... to prior live check 4062758... showed 19 commits / 53 changed paths with no overlap in combat/VIS02. Fresh GitHub compare from 4062758d716db0cae3bfd9802ab1b1a6896681d2 to fcba3dc73940fe73bb78c2938c247d959d36fa2b shows 9 commits ahead, 0 behind; changed paths are VFX documentation/lab/art/workflow and do not touch those target paths. Snapshot is not a native checkout or full current tree; VIS08/POI05 visuals were not reconstructed/re-captured.
- Official engine: Godot `4.7.2.stable.official.ed1daf0bf`; main executable SHA-256 `AB1824F85BFD8E0E4128182C000C4003A3E042245B2967848D089B2A04B22424`.

- Finalization rechecked PR HEAD 90bf8429a2ace4ab5bc38e70c80def996fc0c9fb (tree ce5fbeca2b2ec2857148c6b8b2242cdea9ee5606). This packet is prepared to apply on that live tree; tested snapshot provenance remains as described above.

## Combat event identity

Combat V2 keeps existing event types and gameplay authority. The additions are identity/anchor metadata only. No hit/damage/cooldown/status/summon formula, balance, SaveService, economy, or VFX rendering was changed.

- Regular learned casts use encounter + actor + persistent cast sequence. Cast, release, committed hit, skill-hit and cast-caused status events share the actual cast ID.
- Events without a real originating cast receive the encounter event-sequence ID from the authoritative event journal; no cast is fabricated.
- Summons retain their actual origin cast. Their actor IDs are unique per encounter/owner; each real positive-damage attack gets its own attack ID and a `hit_event_id` pointing to the one committed Combat V2 hit. `attacker` remains canonical owner credit; `source_actor_id` identifies the summon for visual anchoring.
- Palm capacity absorption identifies the actual shield cast, protected actor, incoming attacker, optional incoming cast (empty for the tested basic attack), impact position and per-shield absorption sequence.
- Continuous snapshots persist the event sequence watermark. Old snapshots lacking it remain readable; the finite legacy snapshot v1 payload shape remains unchanged. Restoring a resolved hit preserved HP and event IDs and did not reapply damage in the deterministic fixture.
- See `COMBAT_EVENT_VFX_HANDOFF.json` and `EVENT_TRACE.json`. A VFX consumer is read-only: it may react to IDs/positions and must not create gameplay effects.

## Godot QA

See `QA_MATRIX.csv` and sanitized logs under `logs/`.

- Combat event identity: **PASS**, 20 checks, exit 0. Coverage includes deterministic repeat, two sequential casts, two independent real summon casts in one encounter, three unique attacks for one summon linked to committed hits, two distinct Palm absorption events, snapshot restore without repeated damage, and V6.3 OFF.
- P1 lineage: **PASS**, 1,447 checks, 41 pairs / 82 skill IDs.
- P2 runtime: **PASS**, 796 checks, 196 pairs equal, 0 missing/different. **Design intent remains `OWNER_APPROVAL_PENDING`; runtime equality is not approval.**
- Snapshot/group-battle, S5 Palm, S9 summon lifecycle/rendered contract and D6 boss no-reward focused regressions: PASS (matrix has exits/check counts).
- `dv2_03_runtime_clock_test.gd`: **FAIL**, exit 1 at `SaveService.save_to_path` with only generic `Runtime-clock save failed.`. Root cause is undetermined. SaveService was not edited. Test was isolated; its pre-existing QA fixture file was not modified and the default player save was not accessed.
- One initial `v63_s9_summon_skill_test.gd --headless` invocation waited for `RenderingServer.frame_post_draw` and was interrupted (exit 130); the supported rasterized run passed 2,675 checks, exit 0. This is recorded as an invocation limitation, not hidden as a gameplay failure.
- Godot logs also contain Windows root-certificate-store, `user://logs` directory and Intel GL shader-cache diagnostics. Strict import and passing test processes exited 0; these environment messages are retained in the logs.

## VIS02 recruitment flow

- The Godot P3.2 scene selected `candidate_830031` through the actual B1 candidate pager using `Viewport.push_input` synthetic mouse events, verified selected ID, accepted via B1's real double-confirm callback, and opened the real disciple profile.
- It saved only `vis02_qa_save.json` in an isolated QA profile. A second Godot process cold-loaded the same profile, selected the recruited disciple via the real roster UI, and verified 7 disciples before/after, candidate consumed, and unchanged `heaven_defying` quality.
- **Input was synthetic viewport input, not physical mouse. `PHYSICAL_GUI_PENDING`.** No Android/device or owner visual acceptance is claimed.
- Create and cold-reload test exit codes: 0 / 0. Create recorded 11 viewport screenshots. Cold reload recorded one more. Viewport 1280×720; video has 195 rendered frames at encoded 30 FPS (6.5 seconds). Encoded frame rate is not a physical FPS result.
- Local video: `outputs/PR72_VFX_EVENT_VIS02_20261114/visuals/vis02_recruitment_head0277.avi`, 22,265,838 bytes, SHA-256 `4BD27180D272E4A2B2240ECB1CF574BB5821F00C902CFCE1CA1F411764BD5F47`. It remains in the local evidence folder; it was not added to Git because it is a 22.3 MB generated media file.
- Local QA profile SHA-256 after cold reload: `7B161FF6AD0999625AB1ADF1337866193B2805D98DB0FBF80F6AB28C8532DAE1`. Create-save hash: `038e39926f1130f81f0c5fbe20b94eb3b3db2be7eaa52315992fc70505c4664e`.

## Gates

- V6.3 remains **OFF**; PvE production remains **HOLD**. No POI02/VFX integration was performed.
- P2 remains **OWNER_APPROVAL_PENDING**.
- Native exact-current-tree QA, physical Windows mouse GUI, Android, and CI on the resulting commit are **PENDING**. This packet does not claim PvE release readiness or full visual acceptance.
### Published Godot viewport screenshots (1280×720)

- [Before candidate selection](screenshots/00_dan_tien_before_selection.png) — SHA-256 `240F8070D7F50CF9AD71A6DA70CC6C4854AEBD33AF09E8ABE6251CB95A34E4DF`.
- [Candidate 830031 selected through B1](screenshots/02_candidate_830031_selected.png) — SHA-256 `2D709575F9C46A3EE1A56F86D82854A789DECFA744850F7367D9C46BC8717950`.
- [Recruit reveal complete](screenshots/04_recruit_reveal_complete.png) — SHA-256 `B177B8ED8AF51783AB099CD919D7AEAB69ABD8D762644559E6106100A2023AB8`.
- [Cold-reload disciple profile](screenshots/10_cold_reload_disciple_profile.png) — SHA-256 `47D2D21EB6D6849013718F2A9A732CCC093D51286D32D0E1A7A134B634EA4505`.
## Technically event-ready candidates for the next VFX handoff

These are event-contract candidates only, not approvals of visual assets or permission to integrate VFX. The first is traced through real summon create/attack/expire and committed-hit linkage; the second is traced through its real guard cast and repeated capacity absorption. A VFX owner still needs to select art, map visual phases, and approve the consumer presentation. *Xà Ảnh Quấn Mạch* was not included in this combat identity slice and remains pending its own event trace and visual gate.

- `tmb.skill.summon.kiem_linh.active_01.human` — create → three real attacks / hit links → expire; VFX remains separate.
- `tmb.skill.palm.hoi_phong_chuong.active_04.human` — cast/status → two capacity-absorption events; VFX remains separate.