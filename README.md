# Source A Spine library tooling

This branch adds a local metadata catalog and resumable wrapper around the existing SpineToGodot472 conversion tool. It adds an opt-in `--skin` extension for choosing and combining explicitly named source skins. It does not contain Source A art, generated Godot packs, or machine-local paths.

See [ASSET_LIBRARY_FOR_CODEX.md](docs/ASSET_LIBRARY_FOR_CODEX.md) for setup and CLI use. Copy `library.local.example.json` to `library.local.json` and set paths on the machine where the source assets are available.

