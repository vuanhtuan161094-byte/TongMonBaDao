# POISON V3 — Launcher SHA-256 + real Godot video acceptance (2026-11-09)

## Status

**PARTIAL — launcher source fix committed; video BLOCKED before runner startup. No GUI/gameplay PASS claimed.**

Repository: `vuanhtuan161094-byte/TongMonBaDao`. Branch: `integration/pve-p0-playable-ui-20261103`. PR #72 remains Draft, unmerged. Inspected branch HEAD after changes: `dcb7fb74441bd3dd9add05d135850d88089ca2e6`.

## Changes

| Commit | Allowed path | Scope |
| --- | --- | --- |
| `c095d548d75e49f5d31e4e1fab97aa7f2df1b70a` | `tools/windows/run/OPEN_POISON_LAB.ps1` | Replaced missing `Get-FileHash` call with streamed `.NET SHA256`. Missing/unreadable file, unavailable crypto provider or digest mismatch still blocks launch. |
| `e59074e25011aa76e9061b0230f12240f3ee766a` | `godot/tests/labs/combat_lab/poison_v3_video_capture.gd` | Isolated SceneTree capture harness using Combat Lab, canonical V6.3 skill ID, MapBattleV2 events; rejects video acceptance without matching cast+release. |
| `a2907f65de7f3154be5bbcae836770e3faa99b4f` | `tools/windows/qa/Test-PoisonLabHashCompatibility.ps1` | PowerShell parser and known SHA256 vectors, tamper/missing fail-closed assertions; **not run** on Windows. |
| `c4c849542c18fb98e2350caacc0bc613f7a1f9b5` / `dcb7fb74441bd3dd9add05d135850d88089ca2e6` | `.github/workflows/poison-v3-video.yml` | Official SHA-pinned Godot 4.7.2 via Ubuntu/Xvfb, 24fps 1280x720 movie, MP4 conversion and log artifact for three poison branches. |

All changes are launcher, QA harness or CI-only. No `SaveService`, simulation authority, real gameplay source, player saves, VFX textures, atlas or production scene changed in this packet. No new branch, no merge, no E: local dirty worktree modification.

## Verified in this session

- **STATIC SOURCE INSPECTION:** launcher now uses `[Security.Cryptography.SHA256]::Create()` with streaming `FileStream`, checks physical file exists and compares the computed digest to the manifest digest. No `Get-FileHash` cmdlet call remains in the asset verification loop.
- **GITHUB COMMIT EVIDENCE:** the above commits are in the existing PR #72 branch. This is not evidence that PowerShell/Windows or Godot runtime executed.
- **ACTIONS ATTEMPTS:** `42586582874` (SHA `c4c84954`) and `42586704812` (SHA `dcb7fb74`) were both `completed/failure` within seconds. For the latter, job `129058156680` reports `runner_id=0`, `runner_name=""`, `steps=[]`. The GitHub logs endpoint returned `BlobNotFound` (404); no runner logs or artifacts were produced. Several unrelated existing workflows at neighboring SHAs showed similarly rapid failure. **Infrastructure/runner start failure is observed; its upstream reason is not verified.**
- **ENVIRONMENT:** this ChatGPT runtime is Linux, with ffmpeg and Xvfb but **without** a Godot 4.7.2 binary, the owner's Windows E: drive, or an authenticated private repository checkout; thus no genuine Combat Lab scene could be opened here.

## NOT verified / open gates

- **PowerShell compatibility runtime:** PENDING — source test exists, but it has not run under Windows PowerShell.
- **Official Godot 4.7.2 import + parse/focused on updated SHA:** PENDING.
- **Three MP4 clips (Độc Châm, Cổ Độc, Dược Độc):** NOT GENERATED. Never substitute an image-tool video, static VFX, or synthetic render and call it Godot.
- **Event-time cast → projectile → hit → DoT/heal, animation continuity and VFX aesthetics:** PENDING visual evidence. Harness count alone is not visual acceptance.
- **Physical Windows GUI, FPS/RAM, Android touch and user acceptance:** PENDING USER.

## Recovery without dirty-file loss

1. Diagnose GitHub Actions runner/service/plan availability at the failed run link. Only after job steps can start, re-run `Poison V3 Godot Combat Video Evidence` on the latest SHA; accept only a real Godot movie, scene log with skill_cast + skill_release from canonical combat, and downloadable MP4 evidence.
2. Alternatively, on the user's Windows 10 8GB device, **do not reset/clean** the dirty E: worktree. Fetch into a separate safe QA checkout or update only when the existing dirty tree is preserved. Run `tools/windows/qa/Test-PoisonLabHashCompatibility.ps1` before `tools/windows/run/OPEN_POISON_LAB.cmd`; do not kill other Godot PIDs. Verify 4 VFX SHA and 6 actor atlas SHA hashes via the launcher.
3. Record a genuine Godot 4.7.2 GUI MP4/GIF of three skill branches (cast, flight, impact, DoT/heal), preserve frame time, actual event chronology, screenshots and SHA; inspect 1280x720 and 1–6×. Fix presentation timing only after seeing real frames. Do not merge main.

**Acceptance remains BLOCKED.**
