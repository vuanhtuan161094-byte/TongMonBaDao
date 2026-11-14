# VFX POI06 — Vạn Cổ Phệ Giới R11 — Native Godot Lab closeout (2026-11-14)

## Scope and authority
- PR #72 Draft, branch `integration/pve-p0-playable-ui-20261103`.
- Skill `tmb.skill.poison.co_doc.ultimate.human`: poison, circle, radius 3, max three targets, range 8, cast 1.10, duration 8, two stacks as **read-only catalogue metadata**.
- **VIEW-ONLY isolated Combat Lab**, no actual gameplay hits/ticks, status, HP or saving; **PvE HOLD**, **V6.3 OFF**.
- Owner on 2026-11-14 explicitly accepted the **R11 local art preview**. This does not preapprove native runtime quality or enable live gameplay. Current `OWNER_R11_PREVIEW_ACCEPTED / NATIVE_ART_SELF_QA_PASS / OWNER_NATIVE_REVIEW_AVAILABLE`.

## Asset provenance and integrity
- Original owner-accepted transparent 48-frame atlas, 2048×1536 RGBA, 8×6 cells of 256×256, located at `godot/labs/combat_lab/poison06/r11_candidate/assets/realm_vortex_r11_48.png`.
- Original asset SHA256 `1d3c8adbee16e48973998a66f3692f12366dd64e8b9582ecf090ccfcb00299f8`.
- Exact Git blob SHA `2bfc1f02e91e7a7700e1ad483dccc96bb703014f` **matched the local original**, committed via `46357d676d91bd8b09a575fd5a9d4042a2d2112b`. No substitute texture, lossy resave, commercial-game copy or R10 overwrite.
- Asset alpha local gate: **48/48** cells nonempty, **48/48** all four outer edges transparent; **48 distinct frames**.

## Exact-SHA test, native video and regression evidence
**Original R11 native proof, SHA `46357d676d91bd8b09a575fd5a9d4042a2d2112b`:**
- [GitHub Actions #43604199282](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43604199282) SUCCESS; [native R11 artifact #14117189492](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43604199282/artifacts/14117189492).

**R11 motion-polish final exact SHA `2d67d1a9cc63b8f54ea9ba23858f501de9d54279`:**
- [GitHub Actions #43605005718](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43605005718) SUCCESS: official SHA256-pinned Godot 4.7.2 GL Compatibility, Stage A restore, owner PNG SHA verification, strict import, scene parse, focused contract `VFX_POI06_R11_RESULT=PASS failures=0`, native 333-frame 1280×720 Godot recording at fixed 60-frame-clock, H264 MP4, GIF, timeline and 14 named phase stills.
- [Artifact #14117273665](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43605005718/artifacts/14117273665): MP4, GIF, 14 PNG phase frames, timeline, logs, metadata, checksums. **17/17 hashes** for the MP4/GIF/stills verified after downloading artifact; ffprobe confirmed 1280×720, 333 frames, 5.55 seconds, 60/1 playback rate. **Fixed video rate is not measured hardware FPS**.
- [Unchanged R10 regression #43605005721](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43605005721) SUCCESS on the **same final exact SHA**, strict R10 import/test/native-video proof. Original R10 scene and sprite assets untouched.
- V6.3 matrix workflow #43605004399 FAIL on this SHA. This is **NOT** counted PASS or covered by these VFX Lab tests; investigate separately if in-scope. Its failure does not imply R11's scoped native test failed.

## Native visual review and refinements
- Inspected *actual native Godot* timepoints t=0.38/0.75/1.06/1.31/1.71/2.11/2.38/2.66/2.98/3.30/3.73/4.21/4.72/5.20 on 1280×720 game-like background, with four 1× original character sprites.
- The main smoke/violet jade core has irregular feathered alpha, no visible rectangular crop seam at t=2.66–3.73. The three target heads/costumes stay distinguishable, the three chest marks are localized and view-only; by 5.20s the world has no active skill overlay.
- Native R11 initial renderer directly changed atlas frames and showed visible temporal spikes in the region 650:1260×100:580. Motion-polish `2d67d1a9` **crossfades adjacent actual sprite poses** and removes export-unsafe `Image.load_from_file` from the focused test in favor of imported `Texture2D.get_image()`. The atlas PNG itself is unchanged.
- Internal ROI frame-change mean-absolute-difference diagnostic: initial largest spike 7.88 intensity levels/frame (around 3.70s), polished maximum 4.46 at 2.03s (a phase boundary); remaining polished large spikes <=2.63. Diagnostic only, **not** FPS nor subjective visual-approval metric.
- Current 1× review: `R11_NATIVE_ART_SELF_QA_PASS` for alpha, motion, composition, contact, fade. The owner has already accepted the artwork *preview*; final native movie is now available for user review if desired. Do not assert an additional owner decision that was not made.

## Final controlled status
- `R11_LAB_CODE_COMPLETE`, `EXACT_ASSET_IN_GITHUB`, `GODOT472_NATIVE_FOCUSED_PASS`, `R10_REGRESSION_PASS`, `NATIVE_MP4_GIF_FRAMES_VERIFIED`, `OWNER_R11_PREVIEW_ACCEPTED`.
- `OWNER_NATIVE_VISUAL_REVIEW_AVAILABLE` (not another explicit owner approval), `LIVE_PVE_INTEGRATION_HOLD`, `V63_OFF`, `PHYSICAL_WINDOWS_ANDROID_QA_PENDING`.
- **No Codex, rig, new branch, merge or live Combat V2 / SaveService / economy / AI edits**. Moving this LAB VFX to live Combat V2 needs a separate owner instruction, real event mapping, deterministic and stress QA.
