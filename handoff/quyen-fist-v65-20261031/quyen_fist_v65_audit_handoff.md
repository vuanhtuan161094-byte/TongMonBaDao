# Quyền Tu V6.5 — audit và patch handoff

## Trạng thái

**Patch sẵn sàng chuyển Codex 1 review; chưa tích hợp vào ONE GAME. Chưa đạt DONE.** Người dùng chỉ định Codex 1 là writer duy nhất của ONE GAME, vì vậy code và fixture trong patch được giữ trong scratch. DONE còn cần Codex 1 tích hợp, kiểm thử trên exact integrated SHA và nghiệm thu presentation/gameplay.

## Phạm vi và nguồn đã khóa

- Nhánh yêu cầu: `integration/one-game-v65-20261030`; live GitHub ref đã xác minh tại HEAD `79dab92ccc95a93b39dcb563fe06c93a9aa422da`, tree `955e24c9ae175c03822a4b41a7a23a8274dc6518`.
- Catalogue có **183** bản ghi: 35 Human, 68 Immortal, 80 Divine. Trong đó 177 record thuộc nhánh Quyền và 6 record dùng chung cho basic/mobility qua ba generation.
- Catalogue SHA: Human `4c1c11527e73cb9efe39663c80c5020c8b4baddb`; Immortal `d95bce39dd078289ce76e675a4c1ffc8b9856490`; Divine `78ebe72157fb725744649aa899761b51dcffa7cc`.
- Runtime SHA trước patch: Human `ef9025381dd0f63c1ac4c038d97882c7c7bac7f7`; Immortal `78318adb2cc27f252431158b75dd9d6f461863a8`; Divine `ff9840e84870099c097264fc073d0be8179ee65c`; MapBattleV2 `1eec2e2051057a3e0843a013fe4552415da7e6a8`.
- `CombatStatsV2` `ad35254b800372ab96a1fa328dec694a23b3841d` và `MapBattleSnapshotV2` `2714e31550d052ea53db8ad9624832171ba2071d` chỉ được đọc và dùng trong fixture, không sửa.
- Test harness là project cô lập dựa trên `095ff2f90df8260dd123c06964d20c4f9b571d32`, có overlay patch và đúng ba catalogue nguồn. Live branch hiện đã lên `79dab92`; compare xác nhận 5 commit sau `095ff2` chỉ đổi checkpoint/handoff và HS-09 presentation/test, không đổi combat/data. Sáu file runtime/CombatStats/Snapshot và catalogue blobs khớp nguồn. Đây vẫn là focused combat harness, không phải full project import hoặc bài chạy end-to-end trên integrated HEAD mới nhất.
- Authority đã đối chiếu: [Issue #54](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/54), [Issue #56](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/56), [V6.5 runtime contract](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/feature/v63-v64-full-combat-20261029/docs/design/v63_v64_20261028/03_RUNTIME_DATA_CONTRACT.md) và [V6.3/V6.4 content registry](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/feature/v63-v64-full-combat-20261029/docs/design/v63_v64_20261028/02_CONTENT_REGISTRY.md).

## Audit theo nhánh

### Bá Quyền

- Scheduler hiện dùng loadout đã học/trang bị và có cast timing; D4-B focused test xác nhận nhánh người thường. Không có bằng chứng tất cả lối chơi tự tiếp cận mục tiêu ngoài tầm trong combat thường. World auto-hunt có navigation riêng; không sửa movement/collision chung.
- Patch kiểm tra vị trí hợp lệ và tầm đơn mục tiêu lần nữa tại release, ghi `skill_miss` nếu mục tiêu ra ngoài tầm. Chưa xử lý line-of-sight/vật cản, và AoE chưa được xác minh khi mục tiêu di chuyển khỏi vùng trong lúc cast.
- `Phi Thân Liên Cước` giữ `effect=guard`: catalogue ghi power 0.35, thời hạn 4 giây, tầm 5.5 và single target; runtime áp guard lên caster qua `_support_target`. Tên skill và tài liệu hiện có không cho phép đổi sang dash/attack, vì vậy patch không đổi effect.
- Damage event vẫn theo nhịp simulation release; VFX hiện tại không đọc `animation_key`/`vfx_key`, nên chưa chứng minh animation và damage event khớp khung hình.

### Kim Cang

- Bốn Human skill `Kim Cang Hộ Thể`, `Phản Chấn Quyền`, `Trấn Sơn Hộ Đồng`, `Bất Động Kim Chung` đều vào generic guard (`power=0.35`, `duration=4s`). Immortal/Divine successors có `combat_trait=kim_cang_a/b` và Divine `divine_rule=bloodless_fatal_save_shield`/`absorbed_damage_reflection`, nhưng dispatcher vẫn chỉ đọc `effect`; trait/rule không được thi hành.
- Spec đã duyệt xác định A/Hộ Pháp là finite shield + một lethal-hit protection; B/Phản Chấn phản damage thực sự được hấp thụ. Runtime contract yêu cầu shield hữu hạn theo recipient, tiêu thụ deterministic, lethal-save family ICD **90 giây** cho mỗi recipient, không hồi sinh Injury, và reflection chỉ sau committed real damage, không chain/reflection-loop. Các hành vi này đều thiếu.
- Reflection đang có chỉ từ passive Divine hiếm và dựa trên committed damage tổng, không phải shield-absorbed amount. `v63_shield_received_factor=0.6` của Rare Covenant được carry qua MapBattle trong patch nhưng chưa được tiêu thụ bởi shield implementation. `Trấn Sơn Hộ Đồng` vẫn giữ single-target/target_limit 1.
- Patch đề nghị cho Codex 1: thêm shield records có source skill/generation/lineage, recipient, expiry và remaining capacity; tiêu thụ theo thứ tự xác định trước khi commit HP; ghi absorbed amount và shield remainder; thử lethal-save trước downing với ICD90; chỉ Phản Chấn phản phần absorbed sau commit và chặn recursion; lọc mục tiêu sống/cùng party theo luật cast. Catalogue có `power`/`duration` nhưng không có trường riêng cho shield capacity hay tỷ lệ phản chấn; không chuyển `power` thành pool/ratio mới nếu chưa có mapping được duyệt.

### Huyết Quyền

- Divine đã có giới hạn 65% original max HP; Rare Covenant 55%, Divine Huyết Ma 50% heal dưới ngưỡng 35%, còn Covenant chặn heal. MapBattle setup cũ bỏ rơi Divine stage và blood fields nên hiệu lực không ổn định qua encounter; patch chuyển các field đó qua setup.
- Immortal thiếu attach/survival helper. Patch bổ sung Huyết Ma A giới hạn 75% original HP, đồng đội chỉ hồi dưới 40% ở 60%, cấm self-heal; Huyết Sinh B giữ giới hạn/heal thường. Hy sinh khi cast dùng 10% HP hiện tại hoặc 12% với ultimate và giữ tối thiểu 1 HP.
- Divine sacrifice cũ áp lên cả lineage B; patch giới hạn sacrifice vào Huyết Ma A. Divine B không nhận blood marks/sacrifice. Các giới hạn 65%/55%, 35%/50% và hệ số khác đã có trong catalogue/runtime được giữ nguyên.
- Blood Mark được ghi sau khi effect mark thực sự trúng mục tiêu còn sống; mark có owner + skill ID, thời hạn 10 giây, Frenzy 5 giây với ICD họ 35 giây. `consume_poison` vẫn chỉ xóa stack poison có caster owner hợp lệ; fixture tạo poison qua skill poison catalogue thật.

## Patch và allowlist đề nghị

Diff đầy đủ: `outputs/quyen_fist_v65_handoff.patch`. Patch đổi đúng năm path:

- `godot/src/simulation/combat/v63_human_skill_combat_system.gd`
- `godot/src/simulation/combat/v63_immortal_skill_combat_system.gd`
- `godot/src/simulation/combat/v63_divine_skill_combat_system.gd`
- `godot/src/simulation/combat/map_battle_v2.gd` — shared runtime adapter, cần Codex 1 review trước khi áp dụng.
- `godot/tests/simulation/tmb_quyen_183_combat_handoff_test.gd`

Không sửa SaveService, CombatStatsV2, catalogue, asset hay presentation. Patch chủ yếu sửa generation/lineage state, release receipts và thêm revalidation tầm cho single-target; không tuyên bố đã hoàn thành các cơ chế Kim Cang, cận chiến AI/navigation hoặc presentation còn thiếu.

**Tương thích:** các field actor mới được copy qua MapBattle setup; snapshot hiện serialize actor dictionary. Event `skill_cast`, `skill_release`, `v63_skill_hit`, `status_applied` và `blood_sacrifice` có thêm metadata. Consumer cần được kiểm tra nếu họ so sánh schema event bằng exact-key. Huyết Ma Immortal giờ bị áp cap khi loadout được attach, đúng survival contract nhưng có thể làm lộ giả định max HP cũ ở caller.

**Rollback:** trước commit, bỏ patch bằng `git apply -R outputs/quyen_fist_v65_handoff.patch`; sau commit, revert commit tích hợp riêng của patch. Patch sinh từ baseline có blob SHA trùng các file nguồn đã liệt kê; Codex 1 cần xác nhận branch HEAD/blob vẫn đúng trước khi apply.

## Kiểm thử và evidence

Godot `4.7.2.stable.official.ed1daf0bf` trên Windows:

- `tmb_quyen_183_combat_handoff_test.gd` — **PASS, exit 0**: 183 record, slot/effect thật, caster/target ID, skill ID/generation/lineage, HP trước/sau, release/cooldown, damage/guard/poison provenance/mark/consume, Immortal/Divine blood mode, 2 Kim Cang + 2 Huyết Quyền, normal/elite/Boss và snapshot save/reload.
- `v63_d4b_human_branches_bosses_test.gd` — **PASS, exit 0**, 9/9 branch casts.
- `v63_d5_immortal_lineage_combat_test.gd` — **PASS, exit 0**, 18/18 lineage casts.
- `v63_d6_divine_lineage_combat_test.gd` — **PASS, exit 0**, 18/18 lineage casts.
- Test fixture xác nhận combat gate mặc định OFF và preview gate ON. Sáu path A/B của ba nhánh có record ở cả normal, elite và Boss trong vòng 183-row fixture.
- Godot in cảnh báo môi trường về root certificate store; các test vẫn trả exit code 0 và in PASS. User-data/log ghi trong thư mục scratch riêng. Không có Android/device playtest.

Lệnh chạy fixture sau tích hợp:

```powershell
E:\Godot_v4.7.2-stable_win64_console.exe --headless --path godot --script res://tests/simulation/tmb_quyen_183_combat_handoff_test.gd
```

## Còn cần trước DONE

1. Codex 1 review/apply allowlist vào ONE GAME, ghi lại exact integrated SHA và chạy fixture cùng focused/cumulative gates phù hợp.
2. Codex 1 đưa finite shield/90s lethal-save/actual absorbed-damage reflection vào shared combat runtime theo runtime contract; chốt mapping capacity/reflect amount nếu dữ liệu hiện hành chưa mã hóa chúng, rồi test shield depletion, lethal-save, no-loop, no-Injury-revive và nhiều Kim Cang cùng đội.
3. Codex 1 sở hữu shared movement/collision: xác minh auto-approach, obstruction/LoS, AoE release geometry và attack cancellation khi sai vị trí.
4. Presentation owner nối animation/VFX keys với VFX gốc đã asset-gate; không dùng JX gameplay art hoặc sprite AI chưa duyệt.
5. Chạy chuyển động thật, save/reload tại integrated SHA, normal/elite/Boss và QA Windows/Android. Chỉ sau đó mới đủ điều kiện DONE theo yêu cầu.

## GitHub handoff addendum — 2026-10-31

- Re-fetched the live ONE GAME branch after the original audit. Its current ref is `d921b082f831d60c6827e0a147600566f87fddc9`, a documentation checkpoint on top of tested source `79dab92ccc95a93b39dcb563fe06c93a9aa422da`. The combat/data source tested by the scratch harness remains pinned to earlier source `095ff2f90df8260dd123c06964d20c4f9b571d32`; do not describe that as an exact integrated-HEAD test.
- The packet is stored on `codex/fist-combat-handoff-20261031` as documentation/handoff artifacts only. The `.patch` file is not applied to the handoff branch.
- GitHub Poison handoff ref inspected: `codex/poison-combat-handoff-095ff2-20261031` at `fa0684019a17a01efe4e609a49fc1650dd8ef8c7`. Its patch directly overlaps the Quyền patch at `godot/src/simulation/combat/v63_human_skill_combat_system.gd`; Codex 1 must integrate them sequentially and preserve both semantics. Its other changed production path is `godot/data/combat/v63_divine_combat_catalog.json`, which is not modified by the Quyền patch. See the GitHub packet README for the complete path comparison.
- The 183-row catalogue/fixture dispatch is coverage evidence only. **It is not a 183/183 per-skill behavioral PASS.** Behavioral assertions cover selected effect groups and branch/tier scenarios, with uncovered per-skill acceptance remaining pending.
- Issue #56's newest checkpoint at handoff time reports New Game GUI still open, 14 focused HS-09/ONE GAME regressions passed on source SHA `79dab92`, but GUI PvE and manual Save/Return/Reload are pending after Computer Use capture timed out. Those HS-09 results are independent of this Quyền scratch test evidence.
