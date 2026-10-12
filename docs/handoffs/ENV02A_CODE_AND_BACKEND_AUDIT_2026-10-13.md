# ENV-02A isolated code mirror and backend audit — 2026-10-13

**Authority:** user ordered code-only GitHub upload and source/CI audit while Windows PC is unavailable. `main` baseline read before this change: `f2417d881030845febcc398056653e753d0be0dc`. Scope: `labs/env02a/` and its isolated code audit workflow plus checkpoint/handoff docs. **Never use ENV-02A as production main scene.**

## ENV-01 and ENV-02A evidence

- ENV-01 v4: user-provided official Godot 4.7.2 Windows import.log contains clean import; `env01_structure.log` includes `ENV01_RESULT PASS_STRUCTURE`, three building textures, 29 environment asset textures and props=19; `interactive.log` confirms Compatibility renderer on Intel Iris Plus, screenshot shows real map. Selection/pan/zoom manual checklist and Android remain unverified; do not claim full mobile acceptance.
- ENV-02A: isolated code package from prior handoff: 192×192 logical cells, initial preview 48×48 centered at (72,72), 16×16 logical chunk partition, 3 Source A building previews; single `TransferMapModel` parameterized to 192×192 while retaining default 20×13. Existing ENV-01 scene unchanged in isolated ZIP. Python structural/geometry + asset hashes PASS offline; **Godot Windows 4.7.2 parser/runtime, pan/zoom/AStar/render, Android APK/performance PENDING USER**.
- GitHub `labs/env02a/` is text-only; binaries are deliberately not pushed. Full runnable pack remains the archived owner-supplied `TongMonBaDao_ENV02A_192World_Lab.zip`. Art must be recovered from the exact matching ZIP and verified; do not treat GitHub-only checkout as runnable.

## Backend source audit (READ ONLY, not newly tested runtime)

| Layer | Observed code/contract | Evidence and current distinction |
|---|---|---|
| Simulation/time | `SimulationState`, `SimulationScheduler`, `SimulationRuntimeOwnerV2`, `SimulationRuntimeClockV2`, `LiveGameRuntimeV2`; 60 wall seconds per simulation minute; offline and online through same scheduler | Code exists; DV2-03 historical official CI success at Action `38193051740`; no Android offline/lifecycle measurement here |
| Persistence | `SaveService` JSON v2 stores exact float64 encoding, state save/load, scheduler ownership | Unit and simulation roundtrip tests exist. **Audit watchpoint:** `save_to_path` opens destination with `FileAccess.WRITE`; atomic temp + rename/recovery behavior has not been established from this source review. Do not report actual corruption without a reproduction. |
| Disciples | Birth/envelopes, recruitment, traits/destiny, spiritual roots, bloodline, physique, cultivation paths, techniques, equipment, professions, needs, relationships, memory, organization and cultivation | `godot/src/simulation/` implementations and P1/P2/DV2 tests exist; distinguish breadth of code from full gameplay UX/Android acceptance |
| Tu Vi/Luyện Thể | Realm progress, body XP, realtime flows, training actions, gate transaction; gate data for early low tier and hard limits on high realms | DV2-03 F1–F6 paths/tests exist. User-directed DV2-03 is PAUSED NOT CLOSED; no F7/final closure claim. High-realm materials/seals still gated by source readiness. |
| Economy | `WarehouseSystem`, `ResourceRegistry`, `BuildingSystem`, `WorkforceSystem` with canonical transaction and reserve policy, mine/forest/spirit field/alchemy/forge/medicine-related production flows | P3.7 Backend official CI success Action `38193051669`; P3 O9 M2 production rehearsal official CI success Action `38193051636`. Do not infer unrestricted building/free construction or scale/perf acceptance. |
| Combat/PvE | Combat statistics/skills, deterministic combat, hunting encounters, map and snapshots, equipment/loadout | DV2-02 group/map test code present and prior CI. Full graphical mobile PvE presentation remains separate |
| UI | P3.2 landscape map/camera/tap panels and P3.3–P3.6A playable slice; P3 O1–O9 management/real warehouse production loops | P3.6A historically Windows gate passed but final user visual acceptance incomplete. Production still graybox/procedural art, Source A ENV-01/02A visuals NOT integrated. |
| Art and pipeline | VisualAssetRegistry FE-01A; FE-01B1 verified pack exporter; 13 Source A candidates, 10 verified source catalog / 3 analog | Official CI actions `38201510657`, `38214043053` SUCCESS. Eight historic S3 approved visuals untouched; LFS production binary transport not approved/tested. |

## Concerns and next actions (no backend mutation)

1. Maintain one simulation/save authority. Large-map chunk/visual coordinates are presentation only. `BuildingState` has no persisted world placement; free building/unlock requires independent design, data migration and authorization.
2. Add a later scoped persistence fault-injection/recovery audit for partial-write/crash behavior. No failure has been proven; no changes made now.
3. Check long-session/offline catch-up and 1,000–3,000 roster scale on target Android hardware before product-level confidence.
4. ENV-02A: official Godot 4.7.2 parser and scene gate, then Windows screenshot, then Android touch/FPS/memory QA after PC returns.
5. Only after ENV-02A acceptance and separate approval may ENV-02B–E or FE-02 begin. Backend feature and balance changes stay outside scope. DV2-03 PAUSED NOT CLOSED.

## CI source links

- https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38193051669
- https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38193051636
- https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38193051740
- https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38214043053
- https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38201510657

**QA classification:** Historic upstream GitHub Actions statuses verified via GitHub API; no fresh Godot/Android simulation tests were run for this audit. CI code-only workflow is insufficient to close ENV-02A.