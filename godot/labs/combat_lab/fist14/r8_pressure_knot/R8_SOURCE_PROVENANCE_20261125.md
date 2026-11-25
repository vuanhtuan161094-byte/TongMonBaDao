# FIST14 R8 source provenance — 2026-11-25

- Media source: ImageGen generated original 1536×1024 RGBA sheet at `/workspace/generated_images/exec-0a2ca0d5-8ae2-40f4-8308-dfe86960165f.png`.
- Saved original: `source/f14_r8_pressure_knot_original_1536x1024.png`.
- Exact generation prompt: `source/prompts/f14_r8_imagegen.txt`.
- Source frames: six direct 512×512 crops in `source/poses/`, one per grid cell. Cropping only separated the generated cells; no drawing, repainting, recoloring, vectorization, or code synthesis was used.
- Alpha: source is RGBA with alpha range 0–254; each cropped pose has meaningful transparent pixels.
- Review: `tools/vfx/prepare_g3_source_review.py`, `--motif-width 96`; manifest records original pose-crop SHA-256 values. The helper scales sources against dark/light backgrounds only and does not certify art. The manual review is `G3_SOURCE_FAIL` because the motif reads as a radial flower/rosette and the poses are insufficiently distinct.
- No seed or model identifier was exposed by the generation tool. No files were staged in Git.
