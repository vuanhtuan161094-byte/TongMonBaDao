# Windows command entrypoints

MO_GAME.cmd at the repository root is the sole user-facing launcher.

All technical CMDs retain their behavior under tools/windows/:

| Category | Path |
|---|---|
| Bootstrap / install | tools/windows/bootstrap/ |
| Normal and QA runs | tools/windows/run/ |
| QA and verification | tools/windows/qa/ |
| Source synchronization | tools/windows/sync/ |
| Visual previews | tools/windows/preview/ |

The relocated scripts resolve the repository root from their own location, so %~dp0 no longer assumes that the script sits at the root. For tools/windows/sync/Sync-Main.cmd, pass a repository-relative target, for example:
tools/windows/sync/Sync-Main.cmd tools/windows/qa/Verify-P2-8.cmd

Use the owner launcher from the repository root for normal play:
MO_GAME.cmd