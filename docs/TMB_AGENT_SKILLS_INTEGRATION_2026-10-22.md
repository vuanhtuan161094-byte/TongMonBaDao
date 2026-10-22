# TMB AGENT SKILLS — MAIN INTEGRATION REGISTRY (2026-10-22)

**Status:** Skills-only proposal; documentation files are in a separate PR derived from main HEAD 461caca1171462e0da092f21108c5c1733157ad9. Not a gameplay change, not an approval to modify CODE.

## Six project skills
All source files are under `.agents/skills/<name>/SKILL.md`.
- `tmb-project-director`: coordinate checkpoint/ownership/requirements and select one specialist.
- `tmb-balance-lab`: inspect 30×10 Tu Vi & Luyện Thể, map farm, Linh Điền, production, medicine and economy simulations.
- `tmb-autoplay-ai`: audit safe automation/return, One Active Job, 1000–3000 disciples, group policies.
- `tmb-godot-evidence`: code/test/save/receipts and Windows/Android evidence gates.
- `tmb-asset-gate`: Source A/JX/JXQY/Spine character/map/VFX manifests and actual Godot import QA.
- `tmb-ui-playtest`: hands-on Android 1280×720 touch/camera/production/combat UI review.

### Routing
Use `tmb-project-director` plus the single best specialist. For cross-system work, consult at most two specialists. In Codex, try `$tmb-project-director`, `$tmb-godot-evidence` or the relevant explicit name; if automatic discovery is missing, read these files explicitly. This is guidance, not a replacement for `AGENTS.md` or a CODE authorization.

### Project authority and current B3 CARE checkpoint
Latest explicit owner decision on 2026-10-22: shared daily medicine saturation **1,000,000 points per disciple per canonical simulation day**, day `floor(state.tick/1440)`. The prior 100,000 was a typo, not a Codex defect. Hồi Xuân +55 HP / 10 points; Tụ Khí +10,000 fixed Tu Vi / 25 points; 2 Thanh Linh Thảo +1 Linh Cốc / 6 ticks. Injury120 remains. Combat V2 remains mathematical/gameplay authority. One canonical clock, Warehouse and SaveService, One Active Job, exactly-once settlement; no arbitrary duplicate grant. Game targets Godot 4.7.2 / Android landscape 1280×720.

**B3 CARE Codex handoff (NOT MERGED BY THIS PR):** local commit `35ffa85fd45da42e43722e7ac74b7423602d4491`, based on B3 FASTTRACK `1d686dc8e202f4831fa51373c15e6666f44702f9`; supplied handoff ZIP verified 73/73 SHA-256, with reported 15/15 official focused PASS, clean project import+GUI smoke and prototype world/medicine/save receipts. In the recorded demo, Injury remains at sim tick 131 and auto-return occurs on tick 132, with 4 `tinh_lang_bi` total warehouse rewards. This is **artifact evidence**, not independent rerun, manual player QA or Android device acceptance. No claim that B3 CARE was already pushed/merged to main. Do not silently merge unreviewed gameplay from other branches.

### Using skill plugin in ChatGPT
Private plugin `Tông Môn Bá Đạo — Project Copilot` version 0.1.0 has independently been created for ChatGPT personal use. Its six bundled skills have been verified; invocation/automatic selection in a fresh chat is a separate acceptance question. The GitHub skills are for **Codex when present in the active checkout**, not direct modification of the user's plugin or ChatGPT global settings. The plugin has no new MCP server; live GitHub access uses whatever GitHub connector is available in the conversation.

### Status boundaries
- These skills **do not write gameplay**.
- Future Boss multi-team rewards, realm-specific medicines and r2–r30 maps are DESIGN only unless separately coded and tested.
- No Source A, Combat V2, `project.godot`, save schema, test or gameplay changes in this docs-only PR.
- Existing canonical docs/AGENTS have higher priority than these skills. Preserve CURRENT_CHECKPOINT/NEXT_CHAT_HANDOFF records until authorized integration.
