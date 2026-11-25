# Phá Vây Khai Sơn R1 — native G3.5 visual self-review

**Result:** native preview technical PASS and visual self-review PASS on the exact source SHA below. Formal owner art approval remains pending.

- Source SHA: `105b48ee77174c99974912208031c9bd263b0c74`
- Exact-SHA run: [GitHub Actions #45586338616](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/45586338616)
- Capture: Godot 4.7.2, Xvfb, 1280×720, 75 frames / 1.25 seconds, FFmpeg encoded.
- Focused test: `checks=29`; native LAB log reports `receipts=1`, `target_limit=1`, `hit_count=1`, `moved_target=true`, production gate OFF.
- Frozen packet snapshot SHA-256: `94e5e1cce13c0a1f3df33dc63c1406c6dba9d5f2fd6c6f5f7b48fdd5b5aeab80`.

## Native visual review

- **Charge, 0.12 s:** existing AS50 disciple and curved DAO are visible at a comparable scale to the target. The DAO points toward the target; the charge sits beyond the tip and no longer covers the disciple body.
- **Peak, 0.40 s:** one red-bronze crescent travels forward toward the moving target. It reads as one projectile without a second wave.
- **Contact, 0.75 s:** the target is in its moved position; the native frame displays one compact contact. The focused and native runner logs confirm one real isolated `MapBattleV2` `v63_skill_hit`, target HP decreased, and outside-target HP stayed unchanged.
- **Fade, 0.90 s:** a small separated fragment remains visible on the hit target and fades. The extracted review frame is `v4-fade-review.png`.
- **Scale and placement:** the actor is rendered at preview scale `0.20` (about 67.6 px authored visible height at 720p). Labels fit. The requested rightward weapon direction is visible.

The first native review exposed an oversized actor and clipped labels. After reducing scale, the next review exposed charge overlap with the disciple silhouette. Both were corrected before this exact-SHA capture; this final capture is the reviewed revision.

## Evidence limits and remaining gates

- The packet and generated `V4_MANIFEST.json` still contain `runtime_receipt_timestamp=RUNTIME_MAPPING_PENDING`; the manifest also says `no_runtime_receipt=true`. The V4 manifest alone therefore does not prove receipt timing. The separate focused/native runner logs and the captured LAB state provide the receipt evidence above.
- The scene uses only the dark preview terrain. Bright-terrain/G3.6, no-HUD semantic G3.7, full G5 motion review, physical Android QA, and live PvE were not run.
- The monster uses generic Source A art with unverified species mapping. AS50, curved DAO, and VFX art remain candidates. Owner art review and production promotion are pending; V63/PvE release gates remain OFF.

## Archived artifact checksums

The complete native workflow output, packet snapshot, and extracted fade frame are stored in this directory. The original `SHA256.txt` validates the three V4 phase frames and MP4.

- Charge PNG: `cdf365f5814402e5185b33a037c484fb13351e1973d0b5922a5d9b9c43db3aa0`
- Peak PNG: `06f2cac428acb31b77671f3cf9190342b1f8ef89a0e3ecee0b5f2e008b13b9f3`
- Contact PNG: `5d3477d5da81034a12e392c10bc001b3e75f56e6668efc023025c7a2e6087e70`
- Native MP4: `94be6fb92695f5a0d95a36acd8b6de6b96f3bb6eb183443455e6816e1672f12a`
- Fade review PNG at 0.90 s: `b484bf5c00f00f84ae62a304e5eea87bba104020383b9de78de07a1014b7cbbd`
