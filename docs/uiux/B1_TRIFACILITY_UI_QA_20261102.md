# B1 three facility screens — integration preview

Branch: `feature/codex-b-uiux-b1-20261102`  
RC base: `rc/one-game-playable-20261101` @ `970af33b23076c80d677cf5898a721a27504708f`

This package adds three Godot-native presentation screens and a standalone preview gallery. Each screen exposes `bind_view_model(view_model: Dictionary)` and typed intent signals. It does not call simulation, save, scheduler, economy, building, warehouse, recruitment, or combat authority.

## View-model and callback contract

| Screen | Read-only input fields | UI intent signals |
|---|---|---|
| Đại Điện | `building_level`, `rank_step`, `rank_progress`, `rank_requirement`, `can_promote`, `can_upgrade`, `upgrade_costs[{name, amount, icon}]`, `offices[{id, disciple_name, portrait, office_rank}]` | `office_selection_requested(role_id)`, `promotion_requested`, `hall_upgrade_requested`, `closed` |
| Đệ Tử Xá | `building_level`, `room_count_label`, `bed_slots[{id, occupied, disciple_short_name}]`, `sites[{id, name, status, resident_summary, built, can_build, can_upgrade}]`, `selected_residence_id` | `site_selection_requested(site_id)`, `residence_build_requested(site_id)`, `residence_upgrade_requested(residence_id)`, `closed` |
| Dẫn Tiên Đài | `candidate[{id, name, realm, origin, personality, status, portrait, source_art_approved, tam_values[3], tu_values[4]}]`, `can_accept`, `can_reject`, `can_lead_in`, `can_recruit`, `metrics[{label, value, icon}]`, optional `radar_factory: Callable` | `candidate_page_requested(direction)`, `accept_candidate_requested(candidate_id)`, `reject_candidate_requested(candidate_id)`, `lead_in_requested(candidate_id)`, `recruit_candidate_requested(candidate_id)`, `closed` |

The host supplies all costs, status text, rank progress, occupancy, candidate values, and action eligibility. Screens only display those values and emit intents with IDs. The D7 radar renders three Tam and four Tứ values as separate series. The host may pass a factory for its canonical radar control.

## Rendered 1280×720 captures

These were captured from the Godot 4.7.2 OpenGL game viewport with the gallery capture runner. They show sample data and are not connected gameplay.

- Đại Điện: ![Đại Điện B1 preview](images/b1_dai_dien.png)
- Đệ Tử Xá: ![Đệ Tử Xá B1 preview](images/b1_de_tu_xa.png)
- Dẫn Tiên Đài: ![Dẫn Tiên Đài B1 preview](images/b1_dan_tien_dai.png)

## Verification

Godot binary: `Godot_v4.7.2-stable_win64.exe`, `4.7.2.stable.official.ed1daf0bf`.

| Check | Command / evidence | Result |
|---|---|---|
| Import | `--headless --path <QA>/godot --editor --quit` | PASS, exit 0 |
| Callback/data contract | `--headless --path <QA>/godot --script res://tests/presentation/b1_trifacility_ui_contract_test.gd` | PASS, exit 0 |
| 1280×720 layout host | `--headless --path <QA>/godot --script res://tests/presentation/b1_trifacility_layout_test.gd` | PASS, exit 0 |
| Render captures | `--path <QA>/godot --script res://tests/presentation/b1_trifacility_capture_screenshots.gd -- <output-dir>` | PASS, all three 1280×720 PNGs saved |

The Windows runner prints `Failed to read the root certificate store` during startup; the engine commands exit 0 and import/tests/capture succeed. GUI mouse review through Computer Use was unavailable because its app approval timed out. The saved captures were visually inspected as image files; owner visual review remains pending.

The QA source clone is isolated under Codex documents and came from local main SHA `5e6fdd966bdf710b71e2a1539bb712e44069a4bb`, not the exact RC checkout. B1 files are new and self-contained under `godot/src/presentation/uiux`, its preview scene and presentation tests; the remote commit is based on current RC `970af33...`. The import/test result therefore validates these new components in Godot 4.7.2 but is not an RC integration or gameplay acceptance.

## Screen coverage and asset boundary

- **Đại Điện:** seven role cards with portrait slots/placeholders, building level, 27 supplied rank segments, supplied requirement and costs, eligibility-gated promotion/upgrade callbacks.
- **Đệ Tử Xá:** original facility illustration, supplied bed/resident records, selectable plot cards with supplied state, build and upgrade intent callbacks.
- **Dẫn Tiên Đài:** caller-approved optional portrait texture; original vector fallback; candidate details; independent 3-value Tam / 4-value Tứ radar; accept/reject with two-tap rejection; lead-in and recruit intents.
- The gallery labels all fixtures as sample data. It is an integration preview, not connected gameplay.
- No Source A/JX or third-party art is included. All illustrations and glyphs are original Godot vector drawing code.

Host-game integration, wiring of current game data/actions, portrait rights/candidate tests, and owner visual review remain pending.
