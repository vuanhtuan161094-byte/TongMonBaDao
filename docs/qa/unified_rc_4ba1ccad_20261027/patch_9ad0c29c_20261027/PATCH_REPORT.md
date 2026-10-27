# PR #52 focused QA patch — selected-only live actors and Stage A SHA fallback

- RC branch: integration/pve-unified-rc-20261027
- Exact tested source SHA: 9ad0c29cb04776f692a48e89558277e855e63aef
- Parent chain: 28dc812ac6de35efab38f0724b663e7be37efba8 -> 9ad0c29cb04776f692a48e89558277e855e63aef; both commits are on the same existing RC branch.
- Engine: Godot 4.7.2.stable.official.ed1daf0bf
- Scope: test expectation/diagnostics, Stage A installer SHA compatibility, and CURRENT_CHECKPOINT.md. No production renderer, Combat V2, SaveService, economy, Source A masters, generated PNGs or ZIP package were committed.
- Test source and installer blobs in the final commit were checked byte-for-byte against the Windows QA worktree before running the final SHA matrix.

## Results

- Official headless editor import: PASS, exit 0.
- Focused exact-SHA matrix: 7/7 PASS, exit 0. The changed live-map test now sets the female test identity, selects via the real _open_disciple UI path, waits for the camera tween, refreshes visibility, and checks exactly one in-viewport actor while the complete canonical roster remains virtual. It does not force actor materialization.
- The live-map diagnostic on this SHA reports selected_id=lam_an, actor_nodes=1, projected actor rect (580.6, 294.9) size (118.8, 124.2) inside the 1280x720 map viewport, camera position (-780.2001, 37.04999), zoom 1.35, and no active focus tween.
- P3.2 integration: PASS; 6 party members, 10 real monsters, active Save/Load, 71 simulated seconds, 155 actions, 9 kills, 6 unique movement slots with min spacing 2.83. Zone-hop and Injury120 were NOT_REACHED in this bounded fixture; result remained active, loot LOOT_PENDING, no fabricated rewards.
- Camera, disciple UI, JX VFX Save/Resume, Source A death snapshot, and Safe Save Recovery: PASS.
- Godot logs retain the Windows root-certificate-store warning; each listed focused test and import nevertheless returned exit 0.

## Female Stage A installer

- Exact package SHA-256 expected/observed: 6a4213b9129ffb3f438c21cbb5326672ddf8915323836bf80cb33b8e5fabfdca.
- Tracked Base64 transport install-only path: PASS, exit 0, 42 PNGs, required hair_01_down_back.png present.
- External ZIP fallback path with tracked transport absent: PASS, exit 0, 42 PNGs, required hair_01_down_back.png present.
- Both paths ran the final installer source blob 153a27887cc95217e7fb64c3b59df717eb8ba8ff. In this Windows PowerShell environment Get-FileHash is unavailable; the installer used its .NET SHA256 fallback and compared the result to the same expected hash before extraction. It fails closed on read/hash errors or checksum mismatch.
- Sync-P3-2-Female-StageA.cmd was not run. Generated PNGs and the temporary ZIP are not included in this evidence package or committed.

## Acceptance boundary

Real mouse/GUI play, Save/Return, authentic screenshot/video and FPS logger OFF/ON percentiles/1%-low/spike/RAM remain PENDING_GUI. This headless focused matrix is not a PLAYABLE PASS.