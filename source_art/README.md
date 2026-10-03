# source_art — editable production masters

This folder is intentionally **outside `godot/`**.

Purpose:

- store approved editable/master artwork when the Git LFS workflow is accepted;
- keep source art separate from exported runtime textures;
- prevent Godot from importing PSD/Krita/reference/archive files that the game does not load directly.

Planned layout:

```text
source_art/
  p3/
    buildings/
    characters/
    environment/
    ui/
```

Runtime exports belong under `godot/assets/p3/...`.

Rules:

- do not place diagnostic Base64 chunks here;
- do not treat a generated mockup as an approved source asset unless user explicitly approves it;
- source filenames use lowercase snake_case when practical;
- registry entry must point to the authority doc and source path once ingested;
- source binary policy is currently **PROPOSED**, see `docs/decisions/0002-adopt-git-lfs-for-production-art.md`;
- do not enable/migrate Git LFS from an AI/chat session without the planned Windows verification first.
