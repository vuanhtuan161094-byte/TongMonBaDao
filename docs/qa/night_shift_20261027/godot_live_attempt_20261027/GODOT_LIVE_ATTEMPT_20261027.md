# Godot live attempt — 2026-10-27

## Source identity and safety

- PR #52 remains at remote exact HEAD 0bc96348e6ef1a2eb945e9713e3faeb8912fb07d; its tree is 485d79b3060f22a8b552b52c3e0352f34ccaefb1.
- Local E staging checkout remains synthetic commit 8ec30dfbc5734730a01ea7c3fbfb7e0763da6aad, but its tracked tree is exactly the remote tree above. It is not an exact Git checkout; all execution below is labelled tree-equivalent.
- Canonical E game directory remains untouched on main 5e6fdd966bdf710b71e2a1539bb712e44069a4bb; 17 untracked and 418 ignored files are present. No reset, clean, deletion, overwrite, merge, or branch creation.
- No Godot/Source A worker was present in the process-name scan before starting the game. Only one Godot process was launched at a time.

## Git network/authentication

- Exact remote commit object 0bc96348... is absent in all four known local checkouts (canonical E, staging E, RC QA E, recovery C).
- Staging has no origin remote configured. Per-command fetch using Schannel failed SEC_E_NO_CREDENTIALS. GCM 2.9.0 login could not persist to Windows Credential Manager; browser flow returned unsupported-operation and device flow lost its connection. A fetch using OpenSSL with certificate verification enabled reached an HTTPS credential prompt but no credentials were entered; the remote then returned repository not found. No token/password was read, entered, or stored; no global Git config was changed.
- Exact Git checkout and canonical promotion are therefore blocked on owner completing GitHub authentication in a supported Windows Git/GCM session.

## Stage A

- Before install, staging contained 42 PNGs. Copied them to a timestamped backup under this QA folder and saved a per-file SHA-256 manifest.
- Ran Install-P3-2-Female-StageA.cmd with STAGE_A_INSTALL_ONLY=1.
- PASS, exit 0. Tracked 20-part transport rebuilt the pack with SHA-256 6a4213b9129ffb3f438c21cbb5326672ddf8915323836bf80cb33b8e5fabfdca; the .NET SHA-256 fallback was exercised. Exactly 42 PNGs were present afterward. Before/after PNG hashes were identical (0 changes). Target hair_01_down_back.png exists.

## Godot 4.7.2

- Official GUI and console binaries both report 4.7.2.stable.official.
- First GUI attempt failed parsing global classes SaveService and SimulationState because the project import/class registry had not been generated.
- Headless editor import then exited 0 after reimporting 145 assets. It logged an editor-settings write error to the default user AppData; later GUI run used isolated APPDATA/LOCALAPPDATA folders. This was a QA environment write error, not a game save path.
- Second GUI launch used the exact tracked tree hash above, local synthetic HEAD 8ec30df..., official GUI binary, 1280x720, deterministic 130-disciple QA seed copied to a new unique save under godot/outputs/night_shift_20261027/userdata/. Runtime reported P3.2 ready, 130 disciples, 103 buildings, tick 120. PID 12420 remained running with window title Tong Mon Ba Dao (DEBUG), working set about 575 MiB at the end of the sample.
- GUI log contains “Failed to read the root certificate store”; runtime continued. No screenshot/video or direct mouse evidence was obtained because the Windows UI inventory did not expose the Godot window. Owner was asked to operate the visible game directly. Save/Return/Load, combat and movement remain PENDING until owner feedback.

## Resource sample (not an FPS result)

- 15 process/system samples over 30.29 seconds while PID 12420 was running.
- Godot process CPU: P50 1.8%, P95 4.9%, maximum 4.9% across the sampling bins.
- Godot working set: median 574.1 MiB, peak 616.4 MiB.
- System available RAM ranged 2176–2252 MiB.
- Input and scene activity were not instrumented during this sample. It is not an FPS/frame-time measurement and must not be used as gameplay performance acceptance.
- FPS logger OFF/ON runs, frame-time percentiles, 1%-low, spike attribution, and focused regression have not run yet because the one interactive Godot process was left open for owner play.

## Current status

- P3.2 was opened from a tree-equivalent rehearsal checkout, not from the exact commit object.
- Canonical checkout, Desktop shortcut, exact-SHA focused regression, FPS OFF/ON, screenshot/video, and physical GUI acceptance remain PENDING.

