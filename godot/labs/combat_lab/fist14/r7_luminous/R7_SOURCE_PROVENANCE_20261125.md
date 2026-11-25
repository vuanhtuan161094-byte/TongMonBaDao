# FIST14 R7 source provenance — 2026-11-25

All three reviewed candidates were created with the ImageGen media-generation tool and then split into six equal 512×512 RGBA pose crops from the generated 1536×1024 sheet. No sprite pixels were drawn, painted over, recolored, vectorized, or reconstructed in code. Review sheets were made with `tools/vfx/prepare_g3_source_review.py`; that helper only scales the supplied sources over dark/light backgrounds. Candidate C review inputs are tight transparent-canvas crops of their raw pose cells to the per-cell alpha≥24 bounding box; raw pose cells and the complete generated sheet are preserved unchanged alongside them.

The exact prompts for candidates B and C are in `source/prompts/`. The initial R7 sheet at `source/f14_r7_original_pose_sheet_1536x1024.png` was ImageGen output copied from `/workspace/generated_images/exec-5c07bae3-5f75-453d-be1f-0460290dc978.png`; its original prompt was not retained in the current R7 source artifacts, so it is marked rejected and is not represented as prompt-complete provenance.

The repository helper output `ART=MANUAL_PENDING` means only that it created a preview. This task's manual review records `G3_SOURCE_FAIL` for all reviewed candidates in `R7_G3_SOURCE_DECISION_20261125.md`.
