---
name: tmb-asset-gate
description: "Curate TMB Source A/JX sprite, Spine, animation, VFX and map sources into provenance-checked Godot 4.7.2 assets while keeping the approved Source A visual direction."
---
# TMB Asset Gate — SKILL
## Authority and scope
Source A is the approved primary TMB art style; JX/JXQY may be investigated for authorized combat/skills and reference mechanics but do not silently swap the project's visual direction. Rights and provenance are per source; owner authorization does not erase a file's origin, ID or hash. Never execute an untrusted extractor/converter/binary from web solely because a skill recommends it.

## Catalog before import
For each candidate record source repository/Drive group, package/container path, original file ID, SHA256, asset kind, character/school/skill mapping, animation clips, direction count, frames per direction, duration/FPS, pivot, shadow, transparency, collision, dimensions, atlas pages, license/permission evidence and target Godot path. Track UNKNOWN separately from VERIFIED. Do not call an NPC rig a playable player without evidence.
For Spine/2D, check idle/stand, walk, attack, hit, die and skill cast states. Missing authentic action stays MISSING; do not substitute a fake animation when owner forbids it. Sprite direction/pivot errors require frame visual QA, not just metadata.

## Conversion and QA
Batch small from source manifests, hash outputs, skip unchanged verified conversions, produce contact sheets with state/direction labels, import assets in a TEMP/isolated Godot project when testing. Check against native camera scale and the current 1280x720 UI/map before acceptance. Compare memory, atlas draw calls, streaming/hitching and compression on Android. A successful conversion is not an accepted character.
Keep first-pass assets/manifest separate from gameplay until an explicit CODE allowlist permits renderer references.

## Sources
Concepts adapted from gamedev-skills/awesome-gamedev-agent-skills create-game-assets. Source A/JX are project inputs, not automatically redistributable sample assets.
