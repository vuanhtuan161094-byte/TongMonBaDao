# CP-04 — Visual-first handoff & QA (31/10/2026)

## Scope
- HTML offline; only UI/CSS/JS. No Godot, no main/RC branch modifications. No AI images.
- Derived from CP-03, retaining 4 tabs and the 9 school branches / known catalog presentation.
- All characters, equipment/loadout previews, costs and unowned state are demonstrative. No save authoritativeness.
- Feature flags of V6.3 remain OFF by default; implementation and balance have not been signed off.

## Layout contract
| UI zone | Rendering | Suggested future media |
|---|---|---|
| Skill grid | 72×72 display in 1280 layout | 96×96 or 128×128 RGBA PNG, no embedded text |
| Codex list | 53×53 thumbnail | 128×128 RGBA PNG |
| Large Codex preview | Flexible ~240×230 HTML display | 512×512+ PNG/WebP with transparent background |
| VFX viewer | Approx. 540×248 display (responsive) | APNG/WebP/GIF preview or Godot atlas playback later |
| Evolution stages | 5 stage cards with ~90×90 placeholders | Separate PNG per stage, distinct A/B lineages |
| Evolution VFX | Independent stage/lineage animation area | Animated APNG/WebP/GIF in HTML; frames/atlas in Godot |

## Interactions tested in Chromium
- Screen sizes: 1280×720, 960×540, 915×412, 812×375; no document horizontal overflow.
- 4 tabs available: Công Pháp, Kỹ Năng, Tiến Hóa, Nghiên Tu.
- Select branch and character; filter 4 active skills, select skill and inspect VFX viewport.
- Switch lineage B, select Divine III; jump to book; preview equip without saving.
- On low-height landscape viewport the visual preview appears above the long list.
- Local PNG upload displayed in correct placeholder; media is held by Object URL and disappears upon reload.
- No JavaScript exceptions in the exercised paths.
- Screenshots are direct Chromium renders using set_content() because container policy blocks file:// navigation.
- **Not tested:** Android touch device, Godot import, actual Source A animations, full V6.3 game integration.

## Data caveat
- Names/requirements of sample books are based on catalogue V6.3 previously audited; costs, study times and divine gates are candidate data.
- Skill ratios/CD shown only as candidate or suppressed when they could incorrectly imply a finalized effect.
- “Learned” and “available in the catalogue” are not conflated. This demo cannot confirm codex ownership, actual learned status, or feature enablement.
- Images left blank by intention. Attach PNG/animated images with respective buttons; UI doesn't generate images.
- Design source SHA-256: `94476786ed2019b4d1d4870d85bc870a125d6f9ed7ca6baaf36c6e5d13e23352`.
