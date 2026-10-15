# UI REFERENCE MAP — NOT A PORT OF PROPRIETARY GAMEPLAY

| Target | Source evidence | Pilot implementation | Confidence |
|---|---|---|---|
| Map-first sect | TMBĐ P3_REFERENCE_UI_AUDIT / P3_UX_FLOW_V3 | World-first 1280×720 placeholder shell | Reference layout, no real source artwork |
| Building window | ZQZS metadata `analysis/DeepAnalysis/data/building_ui.json`; `gui.windows.home.uibuildingmsgwin_*.bin.lua` | Right operation panel | Window family documented; exact prefab/assets not imported |
| Workforce panel | ZQZS `docs/HOME_BUILDING.md` & `indexes/ui_calls.csv` | Slot portraits + common picker | UI structure inferred; not a claim of exact source behavior |
| Disciple portrait selection | TMBĐ P3_REFERENCE_UI_AUDIT / P3_UX_DISCIPLE_SCREEN | Searchable portrait-slot grid | Placeholder portraits, pending Source A sprites |
| Production | TMBĐ Economy-A canonical backend | 12-second synthetic timer, +2 synthetic ore per demo packet | **NOT** production balance or save authority |
| Spine 3.8 | Official spine-unity 3.8 compatibility docs + Source A local asset manifest | Optional adapter behind compile define | Not integrated, no runtime test |

**Important:** The Unity UI arrangement is deliberately being trialed.
The original ZQZS/Unity source remains a benchmark for layout and art.
The Godot code remains sole gameplay V2 authority until a separate
engine migration is explicitly approved.
