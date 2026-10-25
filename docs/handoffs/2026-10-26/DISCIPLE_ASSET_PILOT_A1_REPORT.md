# Disciple Asset Pilot A1 — handoff report

## Scope and review base

A1 was prepared on branch art/disciple-asset-pilot-a1-20261025 from main SHA 29b5fba448b0178cb520a4ada44b375b4b934e31 (2026-10-22). PRs #26, #27 and #28 were open drafts and unmerged at review time. Newer related PRs #38 and #39 are also open drafts on another stack; neither supplies a new disciple asset set. PR #39 itself says recovered Source A art still needs to replace authored placeholders.

No PR was modified or merged. The branch contains the isolated lab source, text-only pack preflight, manifests and reports; binary art stays in local output because the repository's production-art storage policy is still proposed.

## Asset candidates

All four local packs are Source A baked SpriteFrames with a 768×768 source canvas, foot anchor (384, 540), 30 FPS, 48-frame stand and 24-frame walk. None exposes directional variants in this lab. The scene shows the native facing without mirroring.

| Tag | Asset | Evidence and status |
|---|---|---|
| A | 1113028_1 | Female entry in PR #26's unmerged disciple visual pool. The staged 72-frame pack has no matching runtime QA fingerprint; historical row is fast-only with Godot skipped. Exact staged-pack QA pending. |
| B | body_1110201 | Male entry in PR #26's unmerged disciple pool. Historical Godot 4.7.2 import/playback and six exact RGBA sample checks pass for the staged pack. |
| C | body_1120402 | PR #26 calls this male, but the Source A source directory is body_female; catalog role and gender are UNKNOWN. Historical pack QA passes; identity review pending. |
| D | 113104_5 | Visual candidate only. Source catalog category is character/disciple at low confidence and role/gender remain UNKNOWN. Historical Godot 4.7.2 import/playback and six exact RGBA samples pass for the staged old pack. A current full re-bake was blocked at preflight. |

The four existing appearances are visibly distinct in the local offline lineup, but A1 does not claim four owner-approved final disciple looks. At the original candidate-survey stage, no new source art had been created. The Recovery A1 update below now records two new local profile paintings. No gameplay class was assigned and no runtime outfit/hair/weapon swap was added.

## Lab and evidence

godot/tools/disciple_asset_pilot_a1/lab.tscn displays the four profiles on a Source A map-texture background at 1280×720. It supports card selection, stand/walk playback and zoom 0.75/1.0.

Static audit command: python godot/tools/disciple_asset_pilot_a1/preflight.py  
Result: PASS_STATIC_PACK_AUDIT for four copied packs. It recomputes packaged file hashes, checks stand/walk metadata, and verifies lab references. It is not a Godot parser or runtime test.

The local contact sheets are offline composites from stored historical frame captures. They are not an A1 runtime screenshot.

## QA state

Fresh official Godot 4.7.2 import, script parse, lab playback, 1280×720 scene capture, pivot-jitter review, direction review, Android QA and performance measurement are PENDING.

The current converter stopped before conversion because two Godot 4.7.2 processes were already active. The owner asked to leave those sessions running, so this task did not launch another process. No new binary output was produced by that attempt.

Binary packs and PNG evidence remain local because Git LFS support/policy was not confirmed. The PR branch does not include binary art. Gameplay, save, combat, economy, roster and the production P3.2 renderer were not changed.

## Recovery A1 update — original character artwork

Two new full-body character paintings were created after the original pilot review, using the built-in image generation tool and the requested designs:

- Nam Kiếm Tu: local `outputs/disciple-asset-recovery-a1/assets/nam_kiem_tu_fullbody.png`; SHA-256 `52d92be2b5d08f22be29050ad6bb8a63ec7ac1e7ff89a6791296133d7d43c7ae`.
- Nữ Pháp Tu: local `outputs/disciple-asset-recovery-a1/assets/nu_phap_tu_fullbody.png`; SHA-256 `0d386ea4aea8af9054c758811f5cc74e689af6891b8890add4c6d26d494576a6`.

The local output also contains editable OpenRaster review sheets, outfit/hair/weapon detail crops, and a side-by-side comparison with an original `body_1110201` Source A baked frame. No Source A pixels were used as character content.

These are new profile paintings, not runtime-ready Character Creator parts. The OpenRaster files keep the complete painting on one editable layer with separately movable detail-crop layers; they do not provide rig-separated 128×128 body/hair/outfit cutouts, directions, or idle/walk animation. Godot import/runtime remains pending.

The artwork binaries were not added to this PR: ADR-0002 still marks Git LFS adoption as proposed and `.gitattributes` has no LFS patterns. The path-free Recovery A1 manifest records hashes and local-only status. This update does not approve the art for production or merge the PR.
