# Disciple Asset Pilot A1 lab scene

This is an isolated, presentation-only preview scene. It does not read or modify game simulation, roster, combat, SaveService, or P3.2 runtime state.

The scene expects the actor packs named in the manifest at res://assets/actors/<asset_id>/ and the two Source A background textures under res://assets/background/. Binary assets are intentionally excluded from this branch while repository Git LFS policy remains unconfirmed. The self-contained local output project includes those copied packs and is the preview entry point for this review.

In the main Godot project, open lab.tscn after the required local packs have been staged. Use 1–4 or Left/Right to select a card, Space to toggle stand/walk, and Z to toggle zoom 0.75/1.0. The scene shows each pack's native facing only; it does not mirror, change direction, or swap clothing.

Run python preflight.py for a text-only pack/hash audit. That audit does not parse or run Godot.
