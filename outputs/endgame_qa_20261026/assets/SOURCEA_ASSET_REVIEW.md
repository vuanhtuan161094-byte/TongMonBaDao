# Source A QA_PASS inventory and visual review

- Local library: `E:\TongMonBaDaoWorkspace\03_AssetLibrary\SourceA`
- `catalog.jsonl` SHA-256: `2A5AD69A9B2E44F0D5DB32AD5B733E71F7F82656C719F98F8AA9B2D6D9F88D33`
- QA_PASS rows: **263** (exact `library_status=QA_PASS` listing; full per-asset SHA/clip/pivot catalog is next to this report).
- Preview PNGs available for manual visual inspection: **10** of 263; contact sheet: `sourcea_qa_pass_preview_sheet.png`.
- Existing ENV02A PNGs in project: **32**; no source art files were replaced or reconverted.
- Existing project monster bundle `godot/assets/actors/v5_sa_monster_1113031_1`: 9 files including import sidecars; reused as-is, no copy/reconversion.

## Source categories

- character/disciple: 73
- monster: 2
- npc: 41
- ui/icon: 2
- unknown: 145

## Classification confidence

- low: 118
- unknown: 145

## Monster candidates

- `1110011`: one `stand` clip at 30 FPS, pivot (384,540), classification `low`; no attack or death animation.
- `1113031_1`: 16 source clips at 30 FPS, pivot (384,540), canvas 768×768, classification `low`. The existing Godot bundle exposes `stand`, `walk`, `attack1`, `hit`, and `dead` and is already referenced by the P3.2 battle presenter.

The available preview for `1113031_1` reads visually as a stylized humanoid/demon character, not an identifiable Thanh Lang wolf. Its category confidence is low. It remains an existing presentation pilot, not a verified Thanh Lang species match. The other previews are disciples/NPCs, one creature-like mascot, and a main-hall building; none is a verified Mine, Linh Lâm, Linh Điền, Cư Xá, or luyện khí worksite asset.

## Integration decision

Reuse existing ENV02A/MAP25 terrain, road, vegetation and approved building art already in the project, plus the existing disciple bundle. Add no new worksite or combat asset: the 263-row catalog contains no high-confidence source-category mapping for those worksite roles. The three worksite SVGs remain experimental placeholders and are not described as Source A assets.
