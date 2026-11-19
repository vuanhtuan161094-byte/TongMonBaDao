# TÔNG MÔN BÁ ĐẠO — ASSET × VFX · ARCHITECTURE A V1

**Owner chốt:** 19/11/2026 — tách hoàn toàn nguồn character Asset và skill VFX; giao tiếp duy nhất bằng **điểm neo có thật trên frame nhân vật** và **sự kiện có thật từ Combat V2**.  
**Trạng thái:** OWNER_ARCHITECTURE_LOCKED / ISOLATED_READONLY_BRIDGE_PRODUCED / PRODUCTION_ATTACH_HOLD.  
**Scope:** Draft PR #72, branch integration/pve-p0-playable-ui-20261103. Không merge, không Codex Cloud, không rig/Skeleton2D/Bone2D cho art mới, không GIF mặc định, không SaveService/Combat V2/AI/economy/V6.3/PvE.

## 1. Hai nguồn art độc lập

~~~text
CHARACTER ART                                      SKILL VFX ART
  - mặt, tóc, áo, body cels frame-by-frame            - RGBA hero master + authored key poses
  - vũ khí/pháp khí riêng theo grip                   - light core, color body, glow, impact, fade
  - 4 hướng × clip và anchor theo frame               - binding chỉ gọi tên slot và event
         |                                                    |
         +---- Character Anchor Contract       VFX Binding Contract
                          \                     /
                         READ-ONLY VISUAL BRIDGE
                                  |
                         Combat V2 event (authority)
                                  |
                  Isolated Godot compositor (chưa nối live)
~~~

**Character team** giữ master/turnaround/face/body/hair/outfit/held-tool dưới thư mục thuộc nhóm nhân vật, không đưa projectile/hào quang/đường chém vào body. **VFX team** giữ hiệu ứng theo skill/tier dưới school-owned LAB và Art-First V4 packet, không lưu một bản clone nhân vật/weapon atlas. Bộ ghép dùng chung chỉ lấy *tọa độ và ngữ nghĩa*, không sở hữu hoặc chép pixel của hai nhóm. Hai người có thể sản xuất song song; mỗi đường dẫn chỉ một writer. Approved/provisional art luôn bất biến.

Sự tồn tại của legacy godot/src/presentation/p3/modular_disciple_actor.gd dùng Skeleton2D là nợ kiến trúc hiện hữu: **không sửa hoặc tích hợp nó ở commit này**, không lấy làm tiền lệ để rig nhân vật mới. Actor mới dùng cels frame-by-frame thực.

## 2. Character Anchor Contract — tmb.character_anchors.v1

- Một manifest theo context xuất: source_kind=CHARACTER_ONLY; asset_id, source_status, canvas_px, foot_px, clips[action][facing][frame].anchors.
- **Bốn hướng thật**: front/right/back/left; không mirror mù. Tối thiểu clip được VFX tham chiếu phải có frame/anchor đúng ở mọi hướng. Cùng nhân vật một ảnh không được dùng giả thành Cast/Attack/Hit nếu thiếu pose.
- Anchor semantic: foot, hand_r, hand_l, weapon_grip, weapon_tip, chest, head, body_center, ground. Từng anchor là cặp tọa độ **pixel nguồn** của frame thật; thiếu = vắng, không được suy từ một vòng tròn hoặc từ trung tâm thumbnail.
- Weapon/talisman/luopan/needle/contract-token là lớp RGBA riêng với grip và occlusion. Quyền và Chưởng không có vũ khí cầm tay mặc định. Giữ đa dạng nam/nữ, 36 nhánh, không dùng màu làm dấu phân biệt duy nhất.
- Không trộn quy mô: P3 map 128×128 pivot (64,104), combat V4 160×192 pivot (80,179), và các AS-CHAR source cỡ 400×440 là những **hợp đồng riêng**. Mỗi context có export/foot transform đo thật trước khi dùng, không chuyển số mù.

## 3. Skill VFX Contract — tmb.vfx_bindings.v1

- source_kind=VFX_ONLY; skill_id canonical, school, tier và source_status; bindings[] khai báo event_type, visual_phase, actor_clip, caster_slot, target_slot.
- Binding chỉ mô tả **vị trí phát sinh hiệu ứng** và **điều kiện phát**; không chứa đường dẫn asset nhân vật, actor_id, damage, heal, poison_stacks, hit_count hoặc phát sinh số mục tiêu. Source VFX RGBA, atlas, pivot, license và storyboard vẫn ở **packet Art-First V4** của từng skill.
- Mỗi Nhân/ Tiên/ Thần chọn master VFX riêng có hình học nâng cấp thực nếu cơ chế cho phép, không chỉ palette, scale hay số hạt. **Tập trung Nhân trước**, Tiên/Thần chờ owner visual.
- **POI06 R11** benchmark mỹ thuật; **POI19 R3** benchmark ánh sáng động, owner provisional; **POI15 R1B** owner approved. Không sửa những source này, không copy mô-típ Độc Tu sang các phái khác.
- G0–G2 semantics/storyboard → G3 original RGBA + keyframes real hard STOP → G3.5 native Godot 1280×720 moving-target 1× → G3.6/3.7 readability/meaning → G4–G7 motion and exact-SHA QA → owner art review → G8/PvE HOLD. Tách source QA và native/owner gate.

## 4. Quyền sự kiện và transform

MapBattleV2._event() tạo event có type, event_id, encounter_id; skill events có skill_id/caster/target khi được khai báo. Các event như skill_cast, hit, status_applied chỉ phát VFX pha tương ứng **khi có nguồn thật**. Không coi animation timeline hoặc LAB timestamps là quyền hit/poison/guard; không tự phát release. Cần biết nguồn duy nhất khi cả hit và v63_skill_hit cùng có mặt để **không vẽ double-hit**. Không suy diễn sự kiện status_removed nếu nguồn không phát.

Bộ thu Visual Bridge V1:
- begin_encounter(encounter_id) đặt phạm vi và xóa dedupe *chỉ lúc lifecycle thật bắt đầu/được reset*;
- route_authoritative_event(raw, vfx_manifest) từ chối thiếu event_id, encounter, skill_id, actor/target, event không binding; đối chiếu skill; loại event_id trùng; trả lại **visual intent data** mà không gọi damage, status hay tạo node;
- resolve_frame_anchor(actor_manifest, clip, facing, frame, slot, source_to_world) dùng chính pose đã vẽ, chuyển tọa độ bằng source_to_world × (anchor_px − foot_px), không tự dịch tay hay tự mirror. Caller cung cấp transform hiện hành có scale, offset, actor motion. Target đang WALK phải lấy anchor/transform của *frame hiện hành*, không dùng điểm đích dự đoán.
- Một bridge instance làm dedupe cho một stream/binding domain; nếu nhiều VFX manifest cùng tiêu thụ event, dispatcher sau này phải phân phối trước khi dedupe. Không buộc một instance chung nuốt các sự kiện hợp pháp khác.

**Fail-closed:** thiếu slot/hướng/frame/grip, event_id/encounter/caster/target, mismatch skill, source art chưa có hoặc thiếu actual target → không phát VFX. Không vẽ vòng/bézier/nhân vật giả để lấp lỗ. Không tự động chuyển ART_PENDING thành OWNER_APPROVED vì test xanh.

## 5. Những tệp đã tạo trong phạm vi độc lập

- godot/labs/visual_bridge_v1/asset_vfx_readonly_bridge_v1.gd — lớp dữ liệu GDScript, **không gắn vào scene production, không rig**.
- tools/qa/validate_asset_vfx_bridge_v1.py — static validator cross-manifest, kiểm cặp nguồn riêng biệt, binding event/slot, 4 hướng và every-frame anchor.
- tools/qa/test_asset_vfx_bridge_v1.py — 12 test positive/negative cho contract.
- docs/operations/visual_bridge_v1/fixture_character.json — nhân vật dữ liệu **SYNTHETIC_FIXTURE**; tọa độ 128×128 bịa cho test, không phải artist/source thật.
- docs/operations/visual_bridge_v1/fixture_vfx.json — VFX binding **SYNTHETIC_FIXTURE**, không có hiệu ứng/sprite/sáng động thực.
- Tài liệu này — quyết định kiến trúc và biên giới trách nhiệm.

Chạy từ repo root:

~~~bash
python -m unittest discover -s tools/qa -p 'test_asset_vfx_bridge_v1.py' -v
python tools/qa/validate_asset_vfx_bridge_v1.py docs/operations/visual_bridge_v1/fixture_character.json docs/operations/visual_bridge_v1/fixture_vfx.json
~~~

Python test ở môi trường xây dựng đã **12/12 PASS** trên chính các mẫu này. Đó là **contract-only**; Godot 4.7.2 native import/parse/video/GUI chưa chạy và chưa có quyền gắn adapter vào PvE. Đừng tuyên bố engine PASS, artist PASS hay measured FPS.

## 6. Handoff tiếp theo — sản phẩm, không tăng thủ tục

1. **Nhóm Asset/Nhân:** trên nguồn E: thật, bảo vệ master Nữ Độc Tu SHA-256 435f8969… và thiết kế Kiếm Tu owner-liked. Sửa lỗi đã nhận diện trong Issue #77: bất nhất style 24 nhân vật, AS65 Back sai hướng/thủng alpha, AS54/55 Downed quá khổ; hoàn thiện props tách lớp cho Sword/Dao/Dual/Spear/Bow/Poison/Talisman/Curse/Formation/Summon, đúng tay/grip. Chuyển **real authored** anchors trên 4 hướng, không tái tạo toàn bộ hàng loạt bằng ảnh giả.
2. **Nhóm VFX/Nhân:** tiếp tục độc lập Wave 1 Issue #83; sản xuất đúng sprite RGBA và keyframe trước Godot, một candidate G3 thật/phái, không poster. Có thể hoàn thành G0–G3 trước khi các actor hoàn thiện; G3.5 cần nguồn actor/grip thật, owner review tách.
3. **Nhóm tích hợp (chỉ ở LAB khi có giao việc):** nối 1 actor Human đã có source thật + 1 skill VFX đạt G3 + một encounter event stream read-only vào viewer Godot 1280×720, 4 hướng và một quái WALK, so charge/peak/contact/occlusion/bright-dark. Giữ production attach/PvE/merge HOLD.

**Trạng thái thực:** LOCK kiến trúc + bridge cô lập + mẫu/validator và test; không ảnh nhân vật mới, không effect mới, không native MP4, không sửa các asset đã duyệt, không merge.
