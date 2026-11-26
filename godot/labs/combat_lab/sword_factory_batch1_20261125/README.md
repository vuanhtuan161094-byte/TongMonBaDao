# Sword Factory batch 1

Shared data adapters for the 17 Human cast masters already present in the Sword catalog and LAB review work. The batch keeps each source revision intact and routes it through the existing AS48 Front renderer, real Jian Weapon Library attachment, and authored `main_hand` / `weapon_tip` sockets.

The 17 source lanes remain distinct: Phi Kiếm Truy Ảnh R2B keeps its G3 rework note; Kiếm Vũ Hồi Phong uses the owner-approved R1E V2 source motion; Sword 03–08 use the six exact source-approved RGBA atlases; Sword 09–17 use the existing Batch9 deterministic compositions from painted Batch6 cels, with their A3 self-review notes preserved. These source and runtime approvals do not transfer to the Factory adapters. All Factory rows are candidate-only, owner visual review pending, and PvE HOLD.

The native runner records only exact MapBattle V2 skill events. Guard uses `status_applied`; mobility uses `v63_mobility`; damage contact uses `v63_skill_hit`. This batch does not add or simulate gameplay events. The six original Batch9 blockers and any source revision notes remain visible in the manifest.

`batch_config.json` contains source frames, phase maps, size, socket/anchor, target fixture and mechanic data. `build_batch.py` updates only the shared Factory registry and existing Sword Web Review rows. It does not modify the original LAB scenes or source atlases.
