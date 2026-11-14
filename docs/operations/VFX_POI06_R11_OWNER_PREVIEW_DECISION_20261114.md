# POI06 — Vạn Cổ Phệ Giới R11 — Owner preview decision (2026-11-14)

## Binding user decision
User responded **"ok. chốt đc."** to the R11 candidate preview on 2026-11-14. This records **OWNER_R11_PREVIEW_ACCEPTED / ART_DIRECTION_LOCKED** for the R11 imagery and movement concept, rather than another mandate to redraw R4/R10. Do not relabel the R4 code-arc approach as approved. Preserve R10 as the independently tested rollback baseline.

## Actual R11 evidence and limitations
- Isolated locally generated **R11 candidate pack**: 48 RGBA frames, atlas 2048x1536 px, 8x6 cells of 256x256. Art-source selection: 16 distinct generated key poses plus 32 edited transition/dissolve frames; source-generated illustration, no third-party proprietary game sprites.
- Preview MP4/GIF were **Python-composited, not Godot-rendered**. They do not certify actual 1x native Godot animation or game readability. A visible hard rectangular alpha/cell-bleed defect at 3.00s was corrected in the revised local preview, but needs native QA.
- Candidate bundle `TMB_POI06_VanCoPheGioi_R11_candidate.zip` SHA256: `b54e2d961ddf78158d70a913d099e835e3f4ed449ae1a8aee322f09af93df0f8`; R11 atlas PNG SHA256: `1d3c8adbee16e48973998a66f3692f12366dd64e8b9582ecf090ccfcb00299f8`.
- **No R11 asset or scene has been pushed to this PR as of this record.** Its R10 scene remains unaffected. Local pack contains dedicated `godot/labs/combat_lab/poison06/r11_candidate/` assets, script and scene.
- Canonical skill: `tmb.skill.poison.co_doc.ultimate.human`, poison / circle / radius 3 / maximum 3 targets / range 8 / cast 1.10 / duration 8 / 2 stacks. **Visual-only LAB**, never invented combat hit, poison ticks, HP or target state.

## Gates, authority and next action
- **OWNER_R11_PREVIEW_ACCEPTED / ART_DIRECTION_LOCKED** — user's explicit approval of the shown preview and art direction.
- **R11_GODOT_IMPORT_PARSE_PENDING / NATIVE_MOVIE_PENDING / REAL_1X_REVIEW_PENDING** — do not report `GODOT_PASS` or final production VFX approval for this candidate.
- **PVE_INTEGRATION_HOLD / V63_OFF / PHYSICAL_WINDOWS_ANDROID_PENDING**.
- Next: bring R11 pack into isolated LAB on this one PR branch, preserve R10, run official Godot 4.7.2 Compatibility exact-SHA import/parse/focused test and genuine 1280x720 native movie, inspect >=8 phase stills, correct seams if necessary. Only then close the R11 native-art gate; no automatic live PvE hookup.
- No rigging, Codex, new branch/merge, Combat V2/SaveService/economy/AI changes. Other school work and the three approved Human Poison LABs remain untouched.

This note records the **owner's explicit preview acceptance** accurately without misrepresenting the underlying renderer or CI evidence.
