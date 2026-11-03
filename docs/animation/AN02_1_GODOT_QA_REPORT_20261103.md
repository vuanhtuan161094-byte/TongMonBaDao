# AN-02.1 — Shadow Animation Lab QA — 2026-11-03

**Source:** PR #68, commit d35a8affb4cef0e45c9d98c403c983554587f584.
**Patch branch:** fix/an02-1-shadow-lab-qa-20261103.
**Outcome:** SOURCE STATIC PASS; OFFICIAL GODOT ENGINE PENDING. No actual gameplay screenshot exists from this execution.

## Environment and honest blockers
- Linux container; Windows E: drive not mounted.
- Neither godot nor godot4 executable installed.
- Curl to official GitHub release fails with DNS lookup error. No executable downloaded.
- Official Godot 4.7.2 import, parser, shader compiler, focused test, real GUI capture and physical Windows/Android QA: **NOT EXECUTED**.
- Concept art shown earlier in the chat is not a Godot screenshot.

## Confirmed asset audit (metadata)
Checked both asset.json and animations.tres for seven authentic Source A packs: female base, two male base packs, female combat, male combat, Thanh Lang combat, Boss slot.
- **7/7 packs, 24/24 clips**: stored frame count, loop flag and per-frame summed duration agree with metadata (tolerance 0.05 sec); nominal FPS 30.
- **7/7 metadata foot anchors**: coordinates lie inside corresponding texture canvas bounds. This is not proof that rendered feet are visually stable.
- Boss dead has 21 stored SpriteFrames covering 30 logical frames, total 1.0 sec; do not use 21/30 sec.
- The real adapter has horizontal mirror, NOT eight authored viewing angles.
- Female cast maps to attack1; Boss requested walk maps to run. Both must be visibly reported as adapter fallback.
- Actual weapon sockets, bow pull, fist strike, poison throw, eight genuine directions, alpha/feet on real frames: still unverified.

## Changes made on patch branch
1. Lab view now exports source texture dimensions, source foot anchor, mirror state, anchor-within-texture result, and rendered foot displacement; QA-only timeline seek. It remains view-only.
2. Focused test extended to check each sampled actor/clip foot anchor, texture dimensions, all eight requested directions and mirrored state, cast->attack1 and walk->run fallback, Boss logical death duration, and non-loop attack/death holding final frames.
3. New GUI capture script saves FIVE actual framebuffer PNGs when invoked in a real Godot window, requires 1280x720, rejects headless, fails on missing frame or anchor drift.
4. New official-Godot version-gated Windows QA launcher tests headless import and focused script, then optional GUI screenshots. All outputs/profile isolated under godot/outputs/an02_lab.
5. New one-click MO_AN02_QA.cmd starts this QA, including GUI captures.

Static review: referenced resource paths exist; changed paths limited to independent Lab source, Lab focused/capture tests and QA launcher; GDScript/shader structural balance checked. NONE of these static checks is an official engine parse or screenshot PASS.

## Windows E: official reproduction — isolated worktree
In Windows PowerShell, do NOT reset/clean the owner's current game checkout. Run:

~~~powershell
$repo = 'E:\TongMonBaDaoWorkspace\01_Game\TongMonBaDao'
$parent = 'E:\TongMonBaDaoWorkspace\QA_Evidence\AN02_1_20261103'
$worktree = "$parent\repo"
New-Item -ItemType Directory -Path $parent -Force | Out-Null
git -C $repo fetch origin fix/an02-1-shadow-lab-qa-20261103
git -C $repo worktree add --detach $worktree origin/fix/an02-1-shadow-lab-qa-20261103
Set-Location $worktree
$env:TMB_GODOT = 'E:\Godot_v4.7.2-stable_win64_console.exe'
.\MO_AN02_QA.cmd
~~~

QA wrapper reports exact Git SHA and refuses nonofficial Godot version. It runs:
- Headless --editor --import: error/exit and log gate.
- Headless focused AN-02 scene test: exit AND explicit PASS marker gate.
- Real GUI 1280x720 capture: exit AND explicit PASS marker gate.
- Output PNGs: godot/outputs/an02_lab/captures/[timestamp] under QA worktree.
- Logs: godot/outputs/an02_lab/qa_logs. Isolated APPDATA: godot/outputs/an02_lab/qa_userdata.
- Manual preview without QA: MO_ANIMATION_LAB.cmd.

If Git LFS assets are incomplete, restore genuine files before running; do not synthesize/source-substitute. The wrapper itself has NOT been run on Windows yet.

## Gate matrix
| Gate | Status |
|---|---|
| Source packs/clips cross-check | STATIC PASS 7/7, 24/24 |
| Metadata anchors within bounds | STATIC PASS 7/7 |
| Lab paths isolated and source paths existing | STATIC PASS |
| Official Godot 4.7.2 parser/import/shader compile | PENDING ENGINE |
| SourceA clip/foot/mirror focused runtime tests | PENDING ENGINE |
| Real 1280x720 GUI capture | PENDING WINDOWS |
| Shadow visual sign-off / 1,6,30 actor perf | PENDING OWNER/ENGINE |
| Android performance and UI | PENDING USER |
| Merge main / modify PR #68 | NOT DONE |

**Next:** execute the version-checked Windows QA on this exact branch, inspect actual PNGs, repair any engine/runtime failure on the same isolated branch, then request owner approval for Shadow. No PvE, Combat V2, SaveService, balance or canonical game launcher changes.
