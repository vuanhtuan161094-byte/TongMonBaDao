# TMB MASTER V3 — UI issue matrix

Evidence sources: current captures from base 53ff0b2, annotations/mockups derived from those actual screenshots, and actual-after capture from code SHA 80ed027. Resolution 1280×720, scene P3.2. Static mockup images are proposals only.

| Issue | Screen | Evidence | Current actual after | Status | Follow-up |
|---|---|---|---|---|---|
| MAP-01 | Main map | Top HUD packs many metrics; contextual cards overlap open map; small zoom/focus labels | Actual-after still shows floating cues over Source A map | MOCKUP_ONLY | Owner chooses which card/navigation changes to implement |
| MAP-02 | Main map | Bottom navigation focus needs stronger state | Actual-after retains current controls | MOCKUP_ONLY | Review touch target/focus in Windows and Android manual QA |
| PRO-01 | Mine/Linh Lam/Linh Dien | Long production panel, nested scrollbar, stacked world cues | Existing panel remains in actual after; no map/worksite layout patch in this branch | MOCKUP_ONLY | Pick compact panel design and implement against real worksite IDs |
| PRO-02 | Production staff | Roster does not clearly distinguish assigned worker, candidate and idle disciple | Actual panel remains unchanged | MOCKUP_ONLY | Show only canonical assignment/job states, no invented worker |
| PRO-03 | Production settlement | Progress/forecast/committed Warehouse receipt boundary needs clearer separation | Actual panel remains unchanged; production logic tests remain passing | MOCKUP_ONLY | Show actual receipt only after canonical settlement |
| PROFILE-01 | V2 disciple profile | Six-axis radar cannot represent D7; old display showed six dimensions | Actual D7 profile has seven axes, grouped Tam Căn/Tứ Tính values and current/birth/delta | FOCUSED_PASS | Profile test + radar test PASS; owner review pending |
| PROFILE-02 | V2 disciple profile | Dense text and low-contrast roster labels; content needs scrolling | Actual after still has small dense rows and scrollbar | PENDING_OWNER | UI readability and layout review needed |
| COMBAT-01 | CARE / Combat V5 | Arena actor art and facts crowd center; damage/skill indicator overlaps sprite | Actual after still shows actors and numeric cues in central playfield | MOCKUP_ONLY | Implement side-panel/readability change only after owner review, preserve camera input/VFX order |
| COMBAT-02 | CARE / Combat V5 | Facts read as one long block; actions uneven and low contrast | Actual after retains current facts/actions | MOCKUP_ONLY | Use only values/event receipts from CARE snapshot; no fake Boss/AoE/skill event |
| COMBAT-03 | CARE injury display | Required Injury120 capture | Actual capture has injury=0; injury logic is covered by focused gameplay tests | PENDING_OWNER | Capture an authentic defeat/recovery state or retain as pending |
| VISUAL-01 | All screens | Owner visual acceptance | No owner sign-off in evidence | PENDING_OWNER | Owner review needed |
| DEVICE-01 | Windows/Android | Physical mouse and touchscreen acceptance | GUI capture is scripted; no physical interaction performed | PENDING_OWNER | Manual Windows and Android device checks |

Artifacts:
- Annotated: outputs/TMB_MASTER_V3_20261024/01_annotated_issues/
- Static mockups: outputs/TMB_MASTER_V3_20261024/02_mockups_from_real_captures/
- Actual after: outputs/TMB_MASTER_V3_20261024/03_actual_after_godot/commit_80ed027/
- Twelve before/after pairs and four four-panel sheets: outputs/TMB_MASTER_V3_20261024/08_before_after_comparisons/.
