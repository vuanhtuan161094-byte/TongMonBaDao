# Blockers and pending acceptance

- Resource gate did not pass: last one-second CPU sample 76.9%, RAM available 1,802 MiB; 60-second samples included CPU >70% and RAM remained below 2,200 MiB. Nine Kernel-Power ID 41 events appeared among the latest 200 recent System error/critical events. Do not start Godot, import or benchmark under this snapshot.
- Git CLI remote access returns `SEC_E_NO_CREDENTIALS` after the sandbox network path is enabled. Git Credential Manager is present, but this sandbox has no Windows credentials. Owner authentication via official sign-in is still needed before local clone/promotion/push; no token/password requested or changed.
- Canonical `E:\TongMonBaDaoWorkspace\01_Game\TongMonBaDao` stays on `main` `5e6fdd966bdf710b71e2a1539bb712e44069a4bb` and exposes 46 root CMDs. Exact remote RC content exists in a staging tree only; its synthetic local SHA is not the remote commit. Therefore the canonical shortcut and actual GUI launcher are pending.
- Desktop shortcut is absent.
- Godot 4.7.2 import, focused tests, launcher smoke, Save/Return, FPS logger OFF/ON, screenshot and gameplay video were not run/captured in this shift.
- E canonical 435-entry SHA preservation manifest was not rehashed during this shift due CPU/RAM pressure. Prior shift reported all 435 unchanged; that is historical evidence, not a fresh after-check.
- No worktree, saves, original Source A/JX asset, QA output, branch or PR was deleted. No changes were made to game code.

