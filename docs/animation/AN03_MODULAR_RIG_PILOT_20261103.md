# AN-03 Modular rig + detachable weapon + actual Godot 3D-to-sprite pilot

## AN-03.4 WINDOWS GODOT 4.7.2 QA — 2026-11-03

### Result

Executed on Windows with official `4.7.2.stable.official.ed1daf0bf` from an isolated worktree under `E:\\codex`. The test snapshot used local project base `5e6fdd966bdf710b71e2a1539bb712e44069a4bb`; PR #71 implementation files were copied from the approved feature branch and verified against upstream blob SHAs. This is a source-file QA result, not a complete checkout of PR #71's base commit.

- Import/parse: **PASS**.
- Focused Skeleton3D, distinct Idle/Walk/Attack pose checks, detachable weapon and animated `hand_R` socket: **PASS, 22 checks**.
- Real Godot GUI at **1280x720**: **PASS, 4 framebuffer screenshots** (Idle, Walk, Attack, Attack with sword).
- Renderer bake: **PASS, 46 actual RGBA PNGs, 768x768** (Idle 18, Walk 12, Attack 16); manifest records per-frame SHA256 and bounds.
- Evidence packager: **PASS**. ZIP: `E:\\codex\\2026-10-21\\t-ng-m-n-b-o-4\\work\\issue71_an03_qa_wt\\godot\\outputs\\an03_lab\\AN03_EVIDENCE.zip`, 2,282,811 bytes, SHA-256 `E75DE92FE65CA2D75741C8B463F61D715CC25B48DAFBF12E2D9D5331D38E726E`. Includes 4 GUI PNGs, 46 baked PNGs, manifest, logs and result JSON.

### Evidence-backed launcher repairs

The first run reproduced two defects, then the complete workflow was rerun successfully:
1. Godot in this Windows environment writes `ERROR: Failed to read the root certificate store.` while otherwise importing/capturing/baking successfully. The launcher now ignores only this exact diagnostic; all other error/script-error lines remain fatal.
2. Passing `-RepositoryRoot "%ROOT%"` when `%ROOT%` ends in a backslash caused PowerShell argument parsing to fail. The launcher now passes `"%ROOT%."`.

Engine logs retain the certificate-store diagnostic as environmental evidence. No other engine/script error was observed in the passing run.

### Limits

The rendered asset is the **procedural 18-bone technical guide**, not a high-fidelity Shadow character and not a weighted owner GLB/FBX. The socket follows the animated right-hand bone in the focused contract; the sword can be toggled in the lab. No artistic acceptance, planted-foot acceptance, 8-way direction set, Android performance or gameplay integration is claimed. The owner model remains missing; Tripo was not used or purchased. The actual ZIP is local and not committed to the repository.

No change to PR #68/#69 source branches, main, PvE, Combat V2, SaveService, game entry or saves. PR #71 remains draft; no merge was performed.


Date: 2026-11-03. Source PR #69 HEAD 1f083854defb3324722a1f05d2780c69c9cd3dd0; branch: feature/an03-modular-rig-weapon-socket-20261103.

**Owner instruction:** Begin coding a reusable character skeleton, body/hair/armor, independently replaceable weapon and separate VFX. Only three first animations: Idle, Walk, Attack. No paid Tripo/Blender required for the technical proof. No modification to PvE, Combat V2, SaveService, main, gameplay entry or real saves.

## AN-03.3 STATIC SOCKET FOLLOW AUDIT — 2026-11-03

Checked live PR #71 HEAD 143d98b2bbc9a5af0fd516d84ec7797c1050c748 before editing. The existing focused contract checked BoneAttachment3D existence and bone_idx but **did not check that its world transform follows the animated right hand**; a detached/frozen attachment could therefore pass. Corrected this contract gap in godot/tests/presentation/an03_modular_rig_contract_test.gd by sampling the world transform of the hand_R bone versus BoneAttachment3D at two Attack instants. New assertions require socket-bone agreement within 0.02 world units and a nonzero physical position change during the strike. The check waits for scene frames so that Godot's skeleton-to-attachment update can propagate. It changes **only the dedicated lab test**, not combat/hit logic, animation source, rig architecture, VFX or save state.

API evidence (read-only): Godot official Skeleton3D includes get_bone_global_pose, reset_bone_poses, add_bone and set_bone_pose_rotation; BoneAttachment3D copies the parent skeleton's designated bone transform and exposes bone_idx. These docs validate expected API usage, NOT behavior in this engine build. The idle/walk/attack code intentionally has no foot IK; in-place gait smoothness and foot slip are **PENDING VISUAL**, not reported PASS. Actual GPU bake PNGs are still missing, so no image-derived bugs can be claimed.

Environment probe: container Linux; godot/godot4 unavailable, Windows E: not mounted, PowerShell not installed. Import/parse/focused 1280x720 GUI, alpha bounds, 46 actual 768px baked PNGs **NOT EXECUTED**. Do not claim runtime PASS. Next: run MO_AN03_START_ISOLATED_QA.cmd from Windows on an unused QA worktree, provide AN03_EVIDENCE.zip and make only log-backed corrections. The procedural mesh remains GUIDE ONLY, with owner Shadow GLB/FBX absent and no Tripo purchase authorization.

---

## AN-03.1 QA HARDENING — 2026-11-03

Based on official Godot 4.7 API docs, PackedScene.instantiate() variables in the focused/GUI test are now kept dynamically typed to avoid invalid custom-method calls on a statically inferred Node. This is a static-source repair, NOT engine parse evidence.

The 768x768 bake script now rejects blank, too-small, clipped, opaque-background and mostly-duplicate frames. It writes real per-frame SHA256 in the output manifest. GUI capture checks four distinct screenshots; focused test checks right-hand BoneAttachment3D is bound to the hand_R bone. The version-gated Windows runner rejects ERROR/SCRIPT ERROR diagnostics even with exit code 0. Outputs are ignored in godot/.gitignore.

One-click Windows worktree command: MO_AN03_RUN_ALL.cmd. It executes official Godot QA, real GPU sprite bake and bundles logs/PNG/manifest, result exit codes and Git SHA using tools/windows/run/Package-AN03-Evidence.ps1. Share godot/outputs/an03_lab/AN03_EVIDENCE.zip back for actual log/screenshot inspection. The runner was NOT executed in this Linux container (Godot 4.7.2 and E: unavailable). All engine/Windows/GUI/46-PNG bake remain PENDING USER, high-fidelity Shadow model BLOCKED_BY_MODEL_INPUT.

---

## Implementation vs. visual acceptance

| Feature | Actual source | QA status |
|---|---|---|
| One reusable humanoid rig | 18 real Skeleton3D bone names/rest transforms, BoneAttachment3D sockets | CODED; GODOT PENDING |
| Body, hair, coat, armor | Separate procedural primitive meshes attached to bones; NOT owner's Shadow mesh | GUIDE ONLY |
| Sword | Separate mesh under right hand attachment; start UNARMED, toggle reversible | CODED; GODOT PENDING |
| Idle | Breathing, head/arms, ponytail, robe oscillation via actual bones | CODED; VISUAL PENDING |
| Walk | Alternating legs/knees, counter-swing arms, torso/bob, ponytail | CODED; FOOT-PLANT PENDING |
| Attack | Real same-rig windup, strike, follow-through, recovery, NO damage authority | CODED; VISUAL PENDING |
| Preview | Separate 1280x720 Godot AN-03 scene, motion/speed/pause/weapon UI | CODED; GUI PENDING |
| RGBA sprite bake | Single SubViewport camera 768x768, 18 Idle + 12 Walk + 16 Attack = 46 frames | CODED; ACTUAL BAKE PENDING |
| Windows QA | Official 4.7.2 gate, focused test, four actual GUI snapshots | CODED; WINDOWS PENDING |
| Original owner Hắc Ảnh Kiếm Tu GLB/FBX | Not exported by Tripo, not present in this repo | BLOCKED_BY_MODEL_INPUT |
| Final character quality, hair/robe skinning, true 8 viewing angles | Not delivered | BLOCKED BY REAL MODEL |
| Full map/PvE integration, 1/6/30 actor perf, Android | Not authorized and not changed | NOT RUN |

**Rig caveat:** procedural rigid mesh segments on BoneAttachment3D are NOT equivalent to a correctly weighted skinned GLB. Importing a third-party model requires actual imported skeleton and rest-pose retargeting. Merely matching bone names is insufficient; see Godot official skeleton retarget documentation. A free 2D cutout pilot remains an alternative if no usable GLB can be acquired without expense.

## Files

- godot/src/presentation/labs/an03_modular_character.gd — independent 18-bone procedural actor, 3 procedural motion cycles, hand socket, swappable sword.
- godot/src/presentation/labs/an03_modular_rig_lab.gd — real Godot 3D lab HUD, no game simulation.
- godot/scenes/labs/an03_modular_rig_lab.tscn — standalone scene.
- godot/tests/presentation/an03_modular_rig_contract_test.gd — bone count, rest positions, motion extrema, socket equip/unequip and no game events.
- godot/tests/presentation/an03_modular_rig_gui_capture.gd — 4 real PNGs from a 1280x720 GUI framebuffer.
- godot/tests/presentation/an03_modular_rig_bake.gd — 46 real 768x768 RGBA frames from a single procedural rig, one camera, explicit source_kind manifest.
- MO_AN03_RIG_LAB.cmd — interactive isolated Lab.
- MO_AN03_QA.cmd — isolated Godot 4.7.2 import + focused test + GUI screenshots.
- MO_AN03_BAKE.cmd — isolated 768x768 actual GPU sprite bake.

## Safe Windows E drive worktree QA

PowerShell (no admin; don't reset/clean/change the canonical game tree):

~~~powershell
$repo = 'E:\TongMonBaDaoWorkspace\01_Game\TongMonBaDao'
$parent = 'E:\TongMonBaDaoWorkspace\QA_Evidence\AN03'
$worktree = "$parent\repo"
New-Item -ItemType Directory -Force $parent | Out-Null
git -C $repo fetch origin feature/an03-modular-rig-weapon-socket-20261103
git -C $repo worktree add --detach $worktree origin/feature/an03-modular-rig-weapon-socket-20261103
Set-Location $worktree
$env:TMB_GODOT = 'E:\Godot_v4.7.2-stable_win64_console.exe'
.\MO_AN03_QA.cmd
.\MO_AN03_BAKE.cmd
~~~

Interactive preview requires GUI version of the same official engine:

~~~powershell
$env:TMB_GODOT = 'E:\Godot_v4.7.2-stable_win64.exe'
.\MO_AN03_RIG_LAB.cmd
~~~

Logs/captures/frames saved under separate QA worktree at godot/outputs/an03_lab. Never assume the GUI screenshot/capture is real before it has been produced in the owner environment.

## Next acceptance gate

1. Run official Godot 4.7.2 import and focused QA on exact feature SHA; inspect actual 1280x720 GUI and 46 PNG baked guide frames. Repair any parser or runtime failures on this branch only.
2. Inspect whether the generated rig guide skeleton and socket are correct. Guide artwork is NOT an owner-ready Shadow character.
3. Secure a real exportable Shadow GLB/FBX or an acceptable free model at owner-approved cost (NO purchase authorization exists), compare rig/weights and map bones; retarget 3 actions, bake and request owner visual approval.
4. Do not expand to eight genuine camera angles or hundreds of frames until the actual imported model and three animations pass.

**Current execution environment:** Linux, no E: or official Godot 4.7.2. All Godot parse/import/focused/GUI/bake are PENDING ENGINE/USER. Static code review is not an engine PASS.
