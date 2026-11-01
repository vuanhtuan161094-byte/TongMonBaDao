# B0 — Native Godot blueprint for Đại Điện, Đệ Tử Xá, Dẫn Tiên Đài

This is a **design-only, text wireframe** for 1280×720 landscape. It is not a Godot screenshot, a playable mockup, or a claim that Source A art has been approved. Gameplay values and commands remain owned by current simulation/presentation authorities and Codex A.

## Shared interaction frame

### Map → building drawer → focused management

1. Tap a building on the sect map. Keep the map and hotbar visible; show a 400–440 px right drawer.
2. Drawer presents one candidate/approved building image, name + actual level/status, two most useful live metrics and two actions: **Quản lý** and one context action backed by a real command (for example, upgrade only if currently eligible).
3. Tap **Quản lý** to open a focused detail surface. Return closes the detail first, then the drawer; map selection remains stable.
4. Cost, resource quantity, progress, eligibility and disabled reasons come from the existing snapshot/query. Empty, loading, blocked and ready states explain why actions are unavailable. No fake count or decorative progress.
5. Persist focus/scroll only if already covered by the existing presentation contract; B0 adds no new save fields.

Text wireframe (not runtime):

```text
┌────────────────────────────── 1280 × 720 landscape ──────────────────────────────┐
│ Sect HUD / resources / hotbar                                                     │
├──────────────────────────────────────────────────────────────────────┬───────────┤
│                                                                      │  building │
│  Map remains interactive and visible                                │  image    │
│  focus ring + disciples + buildings                                  │  400–440  │
│                                                                      │  px drawer│
│                                                                      │  2 metrics│
│                                                                      │  [Manage] │
│                                                                      │  [Action] │
└──────────────────────────────────────────────────────────────────────┴───────────┘
```

## Visual system (original Godot-native UI)

- **Palette proposal:** parchment `#F5EBD2`, deep-forest ink `#183B35`, jade `#59A99A`, restrained bronze `#C19A50`, muted ink `#64766E`, warning `#B44F45`. Verify contrast in Godot before adoption; these are design tokens, not accepted production colors.
- **Panels:** original rounded/line-based Godot Controls; subtle jade edge and bronze rank/status mark. Do not copy Source A Unity panel crops, prefab layout or third-party game's screen.
- **Icons:** original Godot vector/drawn marks for categories (rank, office, bed, resource, progress, warning); 24–32 px glyph, 44–48 px touch target. Icons supplement a short label and accessible tooltip rather than replacing exact values.
- **Typography:** preserve readable title/value/detail hierarchy at 1280×720. Use compact labels only for stable categories. Test Vietnamese glyph coverage and contrast on-device; B0 did not run the screen.
- **Art labels:** every placed design reference uses `CANDIDATE NOT APPROVED` until rights and Godot rendering are verified. Missing art uses a clean `ORIGINAL DESIGN` geometric illustration/icon card, never a stolen or misleading placeholder.

## 1. Đại Điện — government, offices and rank

### Drawer summary

- Candidate building illustration gets about one third of the drawer's hero region. Source A 510052 is `CANDIDATE NOT APPROVED`; use only after owner rights decision.
- Show actual Hall level/rank, eligibility/progress to the next promotion, and one live sect metric. Use a segmented rank track with 27 milestones (Nhân/Tiên/Thần × 9) but keep the current numeric rank beside it.
- Show a compact office strip with the seven real role icons and occupied/vacant state. The summary opens Hall management; do not make hidden/locked role art imply an unlocked bonus.

### Focused management screen

- Header: Đại Điện, current rank, actual level, close/back.
- Left column ~34%: source building art if approved; otherwise original line illustration. Under it show the authoritative next requirement and current progress.
- Right content: seven office cards in a 4 + 3 grid. Each card has the real disciple portrait (or a neutral silhouette), role name, mastery chip, current holder and eligibility/action state. Never infer suitability/effect from color alone.
- Bottom persistent action rail: currently valid appointment/promotion/upgrade action; cost and available Warehouse quantity shown adjacent in two compact columns. When blocked, show the canonical reason, not a clickable fake.
- Keep rank advancement costs and promotion receipt logic as authored by simulation authority. UI cannot calculate a second rank/economy rule.

### Layout notes

At 1280×720, limit the dominant page to one scroll region; keep the action rail fixed. Selecting a vacant/occupied office opens a detail card with the candidate's relevant suitability snapshot and actual effect text. Avoid seven long prose rows.

## 2. Đệ Tử Xá — beds, residents and construction

### Drawer summary

- Building image area is about one third of the drawer; Source A model 510076 is `CANDIDATE NOT APPROVED` and has no approved Godot path. If blocked, use an original silhouette/house mark and keep actual level/status visible.
- Two live metrics: beds used / beds available and current residents/rest state, read from the actual house state. Show no assumed default capacity.
- Quick actions route to real housing management and a currently eligible upgrade/build action.

### Focused management screen

- Left: approved residence art or original neutral illustration; current instance identity/level and real construction/upgrade progress.
- Right: bed slots as a visual grid. The count is derived from canonical capacity; occupied slots map to actual assigned residents. Empty slots remain empty and are not silently reserved.
- Resident row/grid: portrait/avatar, name, current rest/status and assigned house; only actual assignments appear. Keep selectors/actions from the canonical housing UI and retain its transaction semantics.
- Fixed bottom rail: upgrade/build eligibility, cost breakdown and available resource quantities queried from the single Warehouse. No second inventory, no fabricated reward or benefit.

### Movement/geometry guard

Source art 510076 uses source config door [1,-1], while PR #64's fixed Residence site stores [1,3]. Do not make a visual move, flip, crop or collision change to force alignment. Codex A first needs a real map capture with world-cell overlay, actor target/path, footprint and plot evidence. The art must not imply the disciple stands inside or walks through an incorrect cell.

## 3. Dẫn Tiên Đài — candidate review

### Drawer summary

- Source A 510111 is `CANDIDATE NOT APPROVED`; current RC has no approved runtime resource path. Until rights are resolved, use original geometric gate illustration.
- Show only current recruitment state/cap and the actual available action. Do not add odds, a second gacha flow or a fake candidate count.

### Focused management screen

- Preserve the existing `CandidateDecisionActions` accept/reject bindings and all current two-step rejection confirmation/receipts.
- Candidate view uses a single large portrait card with page/thumbnail navigation. Show the actual candidate identity, six innate foundations and HS-09 radar model without merging the independent radar scales; show roots/tendencies with original icon glyphs and short labels.
- Keep accept and reject actions anchored in a fixed footer with clear state, cost and recruitment identifier. Disabled/blocked reasons come from recruitment authority. No button is inferred from decorative status.
- Page switch and selection must not issue recruitment; only the existing confirmed action does.

## UI state contract

| State | Display treatment | Command policy |
| --- | --- | --- |
| Empty / no residents or candidates | Illustrated empty card plus one next step if a real command exists | No synthetic resident/candidate |
| Loading / snapshot pending | Stable skeleton/value placeholders with no misleading zero | No action until actual command state is known |
| Blocked / unmet prerequisite | Muted panel + explicit canonical reason | Disable action or preserve current confirmation flow |
| Ready | Live value, cost/eligibility, highlighted real CTA | Existing command only; keep idempotence/receipt behavior |

This blueprint needs owner acceptance and a separate B1 CODE packet before implementation. Source A artwork remains blocked until exact rights/transport are accepted.
