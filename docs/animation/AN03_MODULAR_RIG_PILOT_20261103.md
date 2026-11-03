# AN-03 Modular rig + detachable weapon + actual Godot 3D-to-sprite pilot

Date: 2026-11-03. Source PR #69 HEAD 1f083854defb3324722a1f05d2780c69c9cd3dd0; branch: feature/an03-modular-rig-weapon-socket-20261103.

**Owner instruction:** Begin coding a reusable character skeleton, body/hair/armor, independently replaceable weapon and separate VFX. Only three first animations: Idle, Walk, Attack. No paid Tripo/Blender required for the technical proof. No modification to PvE, Combat V2, SaveService, main, gameplay entry or real saves.

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
