# DV2-03 + Combat Event/VIS02 closure — 2026-11-14

## Source and exactness

- PR #72 branch: `integration/pve-p0-playable-ui-20261103`.
- Live HEAD immediately before this evidence commit: `fcc166d5c909c4a14c998500c632d80a27ba4b86`; tree `6d08d8b037feb2aea7eff62dc7b2a56ac4e80ace`.
- Compared from the task's prior reference `a6fa6112846b1507ae8593a1c29e05ff51b41b6f`: 11 commits ahead, 0 behind. Those commits changed docs/art/lab plus four P3 presentation scripts, including the isometric world and actor presentation. SaveService, runtime-clock, Combat Event, DV2-02 and VIS02 recruitment/save source paths did not change. The latest world/actor presentation was not re-captured in this pass.
- Git CLI fetch remained unavailable in this sandbox. QA is **CONTENT_VERIFIED_RECONSTRUCTED_SNAPSHOT_QA_PASS**, not native exact-SHA checkout QA and not full-tree QA. `SOURCE_IDENTITY.json` records 16 relevant save/runtime/test source paths and 4 Combat V2 event implementation paths verified against the live tree; the DV2-03 test's live base blob was `c3b35885783ab82876534c974f162446e06ec5e6`.
- Official engine: Godot `4.7.2.stable.official.ed1daf0bf`; executable SHA-256 `AB1824F85BFD8E0E4128182C000C4003A3E042245B2967848D089B2A04B22424`.

## DV2-03 result and diagnosis

- The first published run remains a historical **FAIL, exit 1**, with generic `Runtime-clock save failed.`; it did not record the returned `Error` or resolved path.
- The unmodified test then passed on fresh isolated profiles, including with no pre-created `user://logs`. The certificate-store warning persisted while save and test exited 0, so neither the warning nor absent log directory is supported as the cause.
- A diagnostic copy of the test logged the physical QA profile/save target and returned `code=0 error=OK file=true tmp=false`. The target was inside the isolated QA profile. No player save was read or written.
- The actual DV2-03 harness now reports the returned Error, `error_string`, user data dir and resolved QA path **only when its existing save assertion fails**. The assertion remains `save_error == OK`; no assertion was removed or weakened.
- Three independent Godot 4.7.2 runs of the instrumented harness passed (clean A, clean B and repeat profile), each exit 0 with the PASS marker. The historical one-off root cause remains **undetermined / non-reproducible**; this packet does not claim the root cause was fixed.
- SaveService source stayed unchanged at live blob `7a9131fa7d78eef4c3c3ebcf72a8e15d9c54c5e1`.

## Focused regression

| Check | Result | Evidence |
|---|---|---|
| Strict import/parse | PASS, exit 0 | [log](logs/strict_import_current_snapshot.log), [exit](logs/strict_import_current_snapshot.exitcode.txt) |
| DV2-03 repeated runs | PASS, 3/3, exit 0 | [A](logs/dv2_03_runtime_clock_clean_a.log), [B](logs/dv2_03_runtime_clock_clean_b.log), [repeat](logs/dv2_03_runtime_clock_repeat_profile.log), each with an exit-code sidecar |
| Combat Event identity | PASS, 20 checks, exit 0 | [log](logs/combat_event_identity_v2.log) |
| DV2-02 snapshot / group map | PASS, exit 0 / exit 0 | [snapshot](logs/dv2_02_battle_snapshot.log), [group map](logs/dv2_02_group_map_battle.log) |
| P0 Save roundtrip | PASS, exit 0 | [log](logs/p0_save_roundtrip.log); malformed/negative payload diagnostics are expected assertions |
| Async SaveService roundtrip | PASS, 10 checks, exit 0 | [log](logs/save_service_async_roundtrip.log) |

P1 lineage (41 pairs / 1,447 checks), P2 runtime audit (196 pairs / 796 checks), S5 Palm, S9 summon and D6 no-reward are carried forward from the previous report because their source/test/catalogue blobs are unchanged; they were not rerun in this closure. P2 design remains `OWNER_APPROVAL_PENDING`.

## VIS02 and gates

- Existing VIS02 harness evidence selected `candidate_830031` through B1 pager input, recruited it through the actual callback, opened its profile, saved in an isolated QA profile, then cold-reloaded in a separate Godot process. Roster stayed 7 before/after and the candidate was consumed once. Input was `Viewport.push_input` synthetic input, **not physical mouse**.
- Existing viewport captures are 1280×720. The 6.5-second AVI remains local (195 rendered frames; encoded at 30 FPS, not a device FPS measurement): `outputs/PR72_VFX_EVENT_VIS02_20261114/visuals/vis02_recruitment_head0277.avi`, SHA-256 `4BD27180D272E4A2B2240ECB1CF574BB5821F00C902CFCE1CA1F411764BD5F47`. The latest P3 presentation actor edits were not re-captured.
- Scoped status: **COMBAT_EVENT_VIS02_TECHNICAL_QA_COMPLETE** for content-verified save/runtime/combat-event regressions and the prior synthetic VIS02 flow.
- **PENDING:** native exact-current full-tree QA; physical Windows mouse GUI and latest-art recapture; Android; CI on the closure commit; owner P2 design approval and visual approval. V6.3 stays **OFF**, PvE production **HOLD**. No VFX was integrated.
- Technically traced next event-contract candidates remain Summon `tmb.skill.summon.kiem_linh.active_01.human` and Palm `tmb.skill.palm.hoi_phong_chuong.active_04.human`. **Xà Ảnh Quấn Mạch** has no event trace in this slice and remains pending its own gate.

All uploaded logs redact local absolute paths only; test data, markers and exit codes are preserved.
