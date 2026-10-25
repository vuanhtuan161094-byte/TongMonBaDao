# Disciple Asset Pilot A1 — handoff report

## Scope and review base

A1 was prepared on branch art/disciple-asset-pilot-a1-20261025 from main SHA 29b5fba448b0178cb520a4ada44b375b4b934e31 (2026-10-22). PRs #26, #27 and #28 were open drafts and unmerged at review time. Newer related PRs #38 and #39 are also open drafts on another stack; neither supplies a new disciple asset set. PR #39 itself says recovered Source A art still needs to replace authored placeholders.

No PR was modified or merged. The branch contains only a lab scene source, a text-only pack preflight, a path-free manifest and this report. The local output directory contains the binary packs and contact sheets.

## Asset candidates

All four local packs are Source A baked SpriteFrames with a 768×768 source canvas, foot anchor (384, 540), 30 FPS, 48-frame stand and 24-frame walk. None exposes directional variants in this lab. The scene shows the native facing without mirroring.

| Tag | Asset | Evidence and status |
|---|---|---|
| A | 1113028_1 | Female entry in PR #26's unmerged disciple visual pool. The staged 72-frame pack has no matching runtime QA fingerprint; historical row is fast-only with Godot skipped. Exact staged-pack QA pending. |
| B | body_1110201 | Male entry in PR #26's unmerged disciple pool. Historical Godot 4.7.2 import/playback and six exact RGBA sample checks pass for the staged pack. |
| C | body_1120402 | PR #26 calls this male, but the Source A source directory is body_female; catalog role and gender are UNKNOWN. Historical pack QA passes; identity review pending. |
| D | 113104_5 | Visual candidate only. Source catalog category is character/disciple at low confidence and role/gender remain UNKNOWN. Historical Godot 4.7.2 import/playback and six exact RGBA samples pass for the staged old pack. A current full re-bake was blocked at preflight. |

The four existing appearances are visibly distinct in the local offline lineup, but A1 does not claim four owner-approved final disciple looks. No new source art was created, no class was assigned, and no outfit/hair/weapon swap was added.

## Lab and evidence

godot/tools/disciple_asset_pilot_a1/lab.tscn displays the four profiles on a Source A map-texture background at 1280×720. It supports card selection, stand/walk playback and zoom 0.75/1.0.

Static audit command: python godot/tools/disciple_asset_pilot_a1/preflight.py  
Result: PASS_STATIC_PACK_AUDIT for four copied packs. It recomputes packaged file hashes, checks stand/walk metadata, and verifies lab references. It is not a Godot parser or runtime test.

The local contact sheets are offline composites from stored historical frame captures. They are not an A1 runtime screenshot.

## QA state

Fresh official Godot 4.7.2 import, script parse, lab playback, 1280×720 scene capture, pivot-jitter review, direction review, Android QA and performance measurement are PENDING.

The current converter stopped before conversion because two Godot 4.7.2 processes were already active. The owner asked to leave those sessions running, so this task did not launch another process. No new binary output was produced by that attempt.

Binary packs and PNG evidence remain local because Git LFS support/policy was not confirmed. The PR branch does not include binary art. Gameplay, save, combat, economy, roster and the production P3.2 renderer were not changed.
