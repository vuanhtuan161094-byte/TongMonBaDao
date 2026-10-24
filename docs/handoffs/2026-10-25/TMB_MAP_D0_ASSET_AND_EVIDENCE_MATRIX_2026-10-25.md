# MAP-D0 — ma trận ảnh, asset và nguồn dữ liệu

Ngày kiểm toán: 2026-10-25. Đây là tài liệu docs-only dựa trên PR #31. Mọi vị trí trong concept là kế hoạch trình bày, không phải tọa độ đã kiểm thử.

## Kết luận nguồn

- Capture manifest ghi 19 ảnh P3.2 ở 1280×720, runtime evidence tại code/test SHA 4b02a0c61a2771d9d4638129d96b68ad292270dc, code tree 352700b65d3cd0ef7039df22a1153d81b2fd7b82.
- SHA-256 của cả 19 PNG trong bản workspace đã đối chiếu với source_manifest.json: 19/19 khớp. Danh sách SHA bên dưới lấy từ manifest trên PR #31; ảnh runtime gốc không bị sửa.
- MAP25 chứa 32 PNG (4 terrain, 6 đường, 19 cây/props, 3 công trình). Mỗi file tồn tại trong PR #31 tree, local raw SHA-256 đối chiếu manifest 32/32 khớp; tổng kích thước PNG theo manifest là 2,169,285 bytes (~2.07 MiB trên đĩa). Đây không phải kích thước texture đã giải nén.
- Log Godot official 4.7.2: MAP25 SOURCE A SHA-GATED ART CONTRACT PASS accepted=32 missing=0 rejected=0.
- PNG môi trường/công trình là ảnh tĩnh: không có animation clip/FPS/atlas/pivot metadata trong MAP25 manifest. Các actor animation atlas khác thuộc nhánh trình bày nhân vật/combat, không phải bộ environment này.
- Phạm vi quyền ghi trong manifest: chỉ sử dụng trong project nội bộ được phép; không đóng gói/phát tán raw art ra ngoài.

## 1. MAP25 PNG inventory — raw SHA-256 từ manifest, khớp local bytes 32/32

| Nhóm | Asset path tương đối trong source_a_env02a | Bytes | SHA-256 | Tình trạng trong renderer P3.2 |
|---|---|---:|---|---|
| Đường | env01_assets/roads/stone_axis_a.png | 16,623 | 6e87057fd7753ee294405f90f78f44dc4641d841c3329711d92fcec5cb184520 | 6 tile đường trong bộ ROAD_TEXTURES; đường dùng cho route preview. |
| Đường | env01_assets/roads/stone_axis_b.png | 17,621 | 992fbc52d30ca012a43b0b7aab0f63c0c8c8bea0876b3067ba0bd641cb022646 | 6 tile đường trong bộ ROAD_TEXTURES; đường dùng cho route preview. |
| Đường | env01_assets/roads/stone_branch.png | 20,066 | 1894d9047c73a6d9c80c8455b1a09209e49acb6eafed2922eb23446f190ab819 | 6 tile đường trong bộ ROAD_TEXTURES; đường dùng cho route preview. |
| Đường | env01_assets/roads/stone_cross.png | 11,985 | cb87f596382cae2e539705f1bc081b04ee2de577dd46c09aa49bd7b9e6b8c127 | 6 tile đường trong bộ ROAD_TEXTURES; đường dùng cho route preview. |
| Đường | env01_assets/roads/stone_junction.png | 15,691 | 9fd33912b3aa580bf49a60547f2749ac66f1ae971e9c22bd922ac6d38fa925f6 | 6 tile đường trong bộ ROAD_TEXTURES; đường dùng cho route preview. |
| Đường | env01_assets/roads/stone_scatter.png | 11,611 | 23cb40461b517c7cad3206986bf8d9c7c8b6769fe12cf6222bc1b8dec6fa9570 | 6 tile đường trong bộ ROAD_TEXTURES; đường dùng cho route preview. |
| Terrain | env01_assets/terrain/stone_border.png | 12,470 | 4836980944a8c0701c492c66da59819b1d9dc7ca123fb4371488d6e515569c0f | Được nạp bởi source-art adapter; chưa thấy vẽ trong _draw hiện tại. |
| Terrain | env01_assets/terrain/stone_courtyard.png | 7,448 | c157965bd15f2747a55b602d4320dc34ad70c9129f79cc17eb8b4b139897468a | Được vẽ dạng phủ mờ lặp thưa; 3 tile còn lại chỉ được nạp vào render_art, chưa thấy dùng trong _draw. |
| Terrain | env01_assets/terrain/stone_runes.png | 15,851 | 458cc4510a7f4cc8c3757a4c059837d24113f3d716ceba698decc553989c812e | Được nạp bởi source-art adapter; chưa thấy vẽ trong _draw hiện tại. |
| Terrain | env01_assets/terrain/stone_variant.png | 12,637 | 8580ac97906cfac6b5fea68a378482ce7d157194295310c6e6f64b5902b81368 | Được nạp bởi source-art adapter; chưa thấy vẽ trong _draw hiện tại. |
| Cây / props | env01_assets/vegetation/570036.png | 71,036 | c828e661e22c2c87b6b5c71ba5b309eb2df3f27c196659c2a0ddce035c1af32d | Được gọi trong DECOR_LAYOUT như ảnh tĩnh, không có clip hành động. |
| Cây / props | env01_assets/vegetation/570037.png | 64,615 | 157aa21abd837691268d97afacbf9e0afda059dd9e1035f47eeff8302f6dd75e | Được gọi trong DECOR_LAYOUT như ảnh tĩnh, không có clip hành động. |
| Cây / props | env01_assets/vegetation/570038.png | 67,010 | 900ae63de14cbbe7aef006d448418af16095e8426c34b31be25f819ef638b220 | Được gọi trong DECOR_LAYOUT như ảnh tĩnh, không có clip hành động. |
| Cây / props | env01_assets/vegetation/570041.png | 19,646 | 46af5ce8f7205b35bdd820db58be3071e6698ba789106e74095101b39b53abc2 | Được gọi trong DECOR_LAYOUT như ảnh tĩnh, không có clip hành động. |
| Cây / props | env01_assets/vegetation/570042.png | 90,057 | 0e894b8ff4cbe1bf1e78ccdfc0f0c22316ac516b284b3faf08ffa61f8e6ddaa3 | Được gọi trong DECOR_LAYOUT như ảnh tĩnh, không có clip hành động. |
| Cây / props | env01_assets/vegetation/570043.png | 39,732 | 9d8023f8ff2093672de5940f7926c341b8b1b192b61ce44b2b6c6650328b26c6 | Được gọi trong DECOR_LAYOUT như ảnh tĩnh, không có clip hành động. |
| Cây / props | env01_assets/vegetation/570073.png | 70,996 | 7a78ada4290d3a6eb96acc8c9c46fd4a1b0ae5e95d4194ba59e75e600e2e657a | Được gọi trong DECOR_LAYOUT như ảnh tĩnh, không có clip hành động. |
| Cây / props | env01_assets/vegetation/570144.png | 19,364 | 8aedcc16baeb12427f956c235b923402000e16aee878c81bf6aa0061695dc7f5 | Được gọi trong DECOR_LAYOUT như ảnh tĩnh, không có clip hành động. |
| Cây / props | env01_assets/vegetation/570171.png | 60,705 | 604f46f555ef62d0e63daa9b3d47643f0345592569c8938f33de89949a4064b4 | Được gọi trong DECOR_LAYOUT như ảnh tĩnh, không có clip hành động. |
| Cây / props | env01_assets/vegetation/570172.png | 73,412 | 625859e1a76cb6aaf9970fcdb7c8189a448e4356ed06b4340014f221d4c5c7b0 | Được gọi trong DECOR_LAYOUT như ảnh tĩnh, không có clip hành động. |
| Cây / props | env01_assets/vegetation/570173.png | 66,171 | cac13e6a3b92b4dc1300d859b607469191b4fca6d6261f14ffc20202818259c4 | Được gọi trong DECOR_LAYOUT như ảnh tĩnh, không có clip hành động. |
| Cây / props | env01_assets/vegetation/570181.png | 46,147 | 53710bc51e9a9b1992658888a34042b2e9e0104e4aba1ebf04e112b2d1454918 | Được gọi trong DECOR_LAYOUT như ảnh tĩnh, không có clip hành động. |
| Cây / props | env01_assets/vegetation/570182.png | 44,400 | b277a7c0450ff487e33607df91d13bd367bc9b080d1a8bf664e268f060536272 | Được gọi trong DECOR_LAYOUT như ảnh tĩnh, không có clip hành động. |
| Cây / props | env01_assets/vegetation/570183.png | 42,998 | 08da71fd44121d8a65bb51883966117a770d8b3012e110c38e7cdff1a5de16c0 | Có trong manifest / gate test; không có trong DECOR_LAYOUT hiện tại. |
| Cây / props | env01_assets/vegetation/570185.png | 31,455 | 89fba324db3e3c6d850ed36ee2a3b0aea2021fa6a3d0712c569cae220fbe9655 | Được gọi trong DECOR_LAYOUT như ảnh tĩnh, không có clip hành động. |
| Cây / props | env01_assets/vegetation/570186.png | 65,641 | 79a7d53cf813eef644c3d2fca320d3fda586f860b7be8117048287affb8c1573 | Được gọi trong DECOR_LAYOUT như ảnh tĩnh, không có clip hành động. |
| Cây / props | env01_assets/vegetation/570187.png | 37,311 | b3386ea6336fc59410afbaefe31012a54f72d59d14127b4da4e0a80ee1fe2fa8 | Được gọi trong DECOR_LAYOUT như ảnh tĩnh, không có clip hành động. |
| Cây / props | env01_assets/vegetation/570397.png | 69,325 | b39916567876d173e7d51aec01ad8e5da7871589a0d4afc8e903a1c672717308 | Được gọi trong DECOR_LAYOUT như ảnh tĩnh, không có clip hành động. |
| Cây / props | env01_assets/vegetation/570399.png | 40,568 | bc718c88609f236aac9c381c0b93e6be57f13047b3cfc0b77e406189a9fb66f8 | Được gọi trong DECOR_LAYOUT như ảnh tĩnh, không có clip hành động. |
| Công trình | pv01_assets/forge/520081.png | 248,467 | 4225062d48c08f9562be76315f5b8984d4bea0a2311e5762dc844a23e7567458 | Đang dùng làm Main Hall / Forge / Warehouse sprite. |
| Công trình | pv01_assets/main_hall/510052.png | 596,816 | b6bf88c35e3edc33aba822124296af15a5c8491a05c28f6b5d7b342d20d5325c | Đang dùng làm Main Hall / Forge / Warehouse sprite. |
| Công trình | pv01_assets/warehouse/510102.png | 161,410 | 9bd8b5196ba8b7b79d6f7ef17da07a0d5289fa208ed03484ec1803fd765d9158 | Đang dùng làm Main Hall / Forge / Warehouse sprite. |

### Đọc đúng mức độ sẵn có

1. **Có thể reuse nguyên byte ngay:** 3 PV01 building PNG (510052 Main Hall, 520081 Forge, 510102 Warehouse), 6 road tiles, 4 stone terrain tiles, 19 environment tree/prop PNG. Đây là file thật đã hash-gate, không khẳng định toàn bộ “building family” lịch sử đã được phục hồi hoặc owner visual đã nghiệm thu.
2. **Đang được world gọi:** 3 building, 6 road, 4 terrain được nạp vào render_art, 18 vegetation được chọn trong DECOR_LAYOUT. Trong các terrain, stone_courtyard.png là tile được vẽ trong _draw; các variant/border/runes hiện chưa thành terrain layout nhìn thấy. 570183.png có trong manifest/gate nhưng không có trong DECOR_LAYOUT.
3. **Ý nghĩa chưa xác minh:** các tên vegetation là ID số; chỉ dùng với vai trò prop đã được code hiện tại gán. Không suy diễn 570397 thành ruộng Linh Điền, 570073 thành một tòa Mỏ, hay các cây thành animation khai thác/chặt/trồng.
4. **Gaps cần giải quyết trước visual sign-off:** building art cho Cổng, Cư xá, Tu luyện, Rèn Thân, Y Quán, Luyện Đan, Mỏ, các công trình phụ; station art riêng cho Linh Lâm/Linh Điền; base terrain kit đầy đủ, đất/sỏi, suối/nước, cầu, tường, vách đồi/núi, transitions. Các gap này không chặn nghiên cứu bố cục, nhưng chặn tuyên bố “bản đồ Source A hoàn chỉnh”.
5. **Độ lệch tài liệu:** P3_ASSET_REGISTRY.json, P3_SOURCE_RECOVERY_MANIFEST.md và P3_ASSET_MAP_ENVIRONMENT.md có snapshot 2026-10-03 ghi source thiếu/production pending. PR #31 đã chứa và gate 32 PNG MAP25 sau thời điểm đó. Không sửa canonical inventory trong lượt này; cần reconcile ngày/trạng thái sau owner chọn direction. Các ảnh PV01 có thật nhưng chưa chứng minh byte-identical với bộ 8 building “historical approved” trong log cũ.

## 2. Ma trận 19 ảnh runtime và vấn đề cụ thể

| Ảnh / mở ảnh | Kích thước | SHA-256 | Đọc ảnh và liên hệ với thiết kế map |
|---|---:|---|---|
| [00_current_map_main.png](../2026-10-24/evidence/packet-b/sha4b02/screenshots/00_current_map_main.png) | 1280×720 | 284a7d2db71302e4278c92a7bedc2d905fd0afaf08d87a4b1a88330815a5e657 | Idle map. Three Source A buildings/vegetation read, but lawn repeats across most of viewport; landmark cluster leans right and there is no strong gate-to-hall composition. |
| [01_current_map_pan_zoom.png](../2026-10-24/evidence/packet-b/sha4b02/screenshots/01_current_map_pan_zoom.png) | 1280×720 | 8386746b1885fa5f922eb44d98cc58da222a365457cedb888a3c88d228abdc8b | 135% camera state. Pan/zoom works; Main Hall and right-edge residence are cropped while worksite markers remain spread. Treat as framing/layout feedback, not a camera logic failure. |
| [02_current_mine.png](../2026-10-24/evidence/packet-b/sha4b02/screenshots/02_current_mine.png) | 1280×720 | de3731502fb529e97ba033e354c31cd9d01b3374fcfe0f9c52be301fee96d97b | Mine panel and real mine_001 state are visible. Cyan crystal is prop 570073, while no mine building/workstation art is present; selected card covers much of the viewport. |
| [03_current_linh_lam.png](../2026-10-24/evidence/packet-b/sha4b02/screenshots/03_current_linh_lam.png) | 1280×720 | 7a1a7d16ead6f8ded8ca8828ad332487e7c87aba67369adbe2c25b2c74e31abe | Real linh_forest_001 panel. Tree assets provide a grove cue, but the worksite itself remains a flat marker rather than a forestry station. |
| [04_current_linh_dien.png](../2026-10-24/evidence/packet-b/sha4b02/screenshots/04_current_linh_dien.png) | 1280×720 | 7842bb526aad54b610fbb159767cabb001484acb7579c982ef17c7a8e07ab8f0 | Real spirit_field_001 state and four empty plots are shown in the panel; map surface does not visually show the plot/crop system. |
| [05_current_warehouse.png](../2026-10-24/evidence/packet-b/sha4b02/screenshots/05_current_warehouse.png) | 1280×720 | a032704d26379769eb68fc891ee3872f7cd52988f0982e4a27decd21ba376097 | Canonical Warehouse values are shown through the existing panel. Layout/terrain remains visible behind it; keep panel/system unchanged. |
| [06_current_v2_male_profile.png](../2026-10-24/evidence/packet-b/sha4b02/screenshots/06_current_v2_male_profile.png) | 1280×720 | 1d2c05d7f811ac87bab3fc52eef4cd6c43c5caaeb8f7d1a9311545e24c33e1b9 | Full disciple profile, not a map state. Preserve the existing profile UI; do not use it to redesign sect geography. |
| [07_current_v2_female_profile.png](../2026-10-24/evidence/packet-b/sha4b02/screenshots/07_current_v2_female_profile.png) | 1280×720 | 6976d93e382da7c8d7fde5ad2f36d3a0a5e321e9439456a318d4d7618f623d9c | Authentic female V2 profile, not a map state. Preserve the existing profile UI; do not use it to redesign sect geography. |
| [08_current_mine_after_real_settlement.png](../2026-10-24/evidence/packet-b/sha4b02/screenshots/08_current_mine_after_real_settlement.png) | 1280×720 | 1aa74d493f40ef20ffde378ba8019b73ee5ab89e340e74f49ef674b2a86ba5e0 | Real mine_001 settlement capture: tick 20, one worker, phases travel_out→mining→haul_back, Thanh Thiết 37→39 (+2). Protect the live worksite-to-Warehouse path. |
| [09_current_combat_v5_start.png](../2026-10-24/evidence/packet-b/sha4b02/screenshots/09_current_combat_v5_start.png) | 1280×720 | bbc0f8e99c1b4c6bee44a4ddb3f4ff81ac2e07ebb2ec611354f80b8aefa27fa4 | B3 hunt encounter start. This is the separate hunting battle viewport; it is not a sect-map location or terrain reference. |
| [10_current_combat_s1_real_burn.png](../2026-10-24/evidence/packet-b/sha4b02/screenshots/10_current_combat_s1_real_burn.png) | 1280×720 | 9eb2b4bf4832e106727a82fdcbdf5d40d9dcf76be8ec1a8953325fc4ca076072 | B3 hunt world with authoritative burn event. Keep outside the sect-map plan. |
| [11_current_combat_after_real_hit.png](../2026-10-24/evidence/packet-b/sha4b02/screenshots/11_current_combat_after_real_hit.png) | 1280×720 | 6006c79e886e2d5126d0df249e8ebc6914268ff9e92610f954e3f5f0277864ef | B3 hunt world after a real hit. Keep outside the sect-map plan. |
| [12_current_combat_after_real_skill_hit.png](../2026-10-24/evidence/packet-b/sha4b02/screenshots/12_current_combat_after_real_skill_hit.png) | 1280×720 | 21263f8fe43f98099135d614bdd885670f3eedadecdba1c6a9b688eb4505bd4f | B3 hunt world after the real skill hit. Keep outside the sect-map plan. |
| [13_current_combat_s1_real_weaken.png](../2026-10-24/evidence/packet-b/sha4b02/screenshots/13_current_combat_s1_real_weaken.png) | 1280×720 | 72203af5fda1f22edd49b0d0c9abbeaf13c9f10a1680747a52bda8ca7be04dcd | B3 hunt world with authoritative weaken status. Keep outside the sect-map plan. |
| [13b_current_combat_s1_learned_guard_active.png](../2026-10-24/evidence/packet-b/sha4b02/screenshots/13b_current_combat_s1_learned_guard_active.png) | 1280×720 | b6f923f374daf7d89c701db6a96ca89b29ba4258f8a49e06c97b28bd4795b557 | B3 hunt world with learned guard active. Keep outside the sect-map plan. |
| [14_current_combat_after_paid_loot.png](../2026-10-24/evidence/packet-b/sha4b02/screenshots/14_current_combat_after_paid_loot.png) | 1280×720 | 53fd4cced577eb14c576d5ad31a07f3045202ba83149f7bb8386d3545235c608 | B3 paid-loot receipt state; receipt is COMMITTED in the hunt world. Do not reuse this presentation as a sect production visual. |
| [13c_current_combat_s1_learned_guard_expired.png](../2026-10-24/evidence/packet-b/sha4b02/screenshots/13c_current_combat_s1_learned_guard_expired.png) | 1280×720 | 56082165fc70d6581cdc75c2e6414915b5edd99700f17cb4127dcb3a1a21371c | B3 hunt world after learned guard expired. Keep outside the sect-map plan. |
| [15_current_combat_same_world_after_respawn.png](../2026-10-24/evidence/packet-b/sha4b02/screenshots/15_current_combat_same_world_after_respawn.png) | 1280×720 | 1c86c4b1340a645d94ce9fbb14a4d5c8c8f4775b177da0275502d48a155daacd | B3 same-world respawn state. This confirms the hunt scene persists separately; it is not sect-world expansion. |
| [16_current_main_after_hunt_return.png](../2026-10-24/evidence/packet-b/sha4b02/screenshots/16_current_main_after_hunt_return.png) | 1280×720 | 13743c10aa06bee90bb0d7b8539dc01ba59fe63c784a9149584d3abe1ba0f9a9 | Returned to P3.2 sect map with the same disciple state; the right summary panel overlays the world. Preserve this return path and same runtime. |

### Các điểm đọc qua ảnh

- **00–01:** V1 có chất màu Source A và three buildings rõ nhất, camera pan/zoom hoạt động. Nhưng trường xanh lặp chiếm phần lớn frame; các điểm chức năng tản rộng và Main Hall/đường/cổng chưa thành một trục đọc đầu tiên. 135% làm mái/cụm mép bị crop, nên option mới phải ưu tiên default framing + pan-to-site.
- **02–05:** panel là giao diện nghiệp vụ đã QA, giữ nguyên. Map-layer cần cho người xem nhận ra Mỏ / Linh Lâm / Linh Điền bằng bối cảnh công trình/prop đúng nguồn; hiện marker diamond + prop rời chưa đủ. Mỏ có đá tinh thể 570073 gần khu khai khoáng nhưng không có station artwork; Linh Lâm có cây nhưng không có forestry station; Linh Điền có trạng thái 4 plot trong panel nhưng không có ruộng/crop silhouette nhìn thấy.
- **06–07:** hồ sơ đệ tử, ngoài phạm vi thiết kế địa hình. Giữ UI và số liệu, không lấy modal profile làm khung map.
- **08:** đây là giao dịch sản xuất thật (+2 Thanh Thiết, 37→39) và cần giữ liên hệ marker / worker / lối hauling trong bất kỳ bố cục nào. Đây không phải bằng chứng cần đổi backend sản xuất.
- **09–15:** toàn bộ là battle viewport của B3 hunt-world. Đây là bằng chứng scope boundary: không chuyển nền, 20 bãi, actor positions hay tile set bãi săn sang sect map.
- **16:** quay lại cùng map sect sau hunt. Giữ liên tục runtime/camera và profile side panel. Bố cục mới không được tạo scene/runtime sect thứ hai.

## 3. Source/data flow đang có (PR #31)

| File | Quan sát trực tiếp | Hệ quả cho MAP-D1 |
|---|---|---|
| [sect_isometric_world_v1.gd](../../../godot/src/presentation/p3/sect_isometric_world_v1.gd#L7-L80) | GRID 192²; CHUNK 16; STARTER (72,72,48,48); iso 50×26 logical px/cell; anchors cho 13 điểm; source textures cho 3 building. | Bố cục được thiết kế như presentation anchor. Chỉ di chuyển các visual anchors sau khi kiểm tra producer ID, worksite cue, worker overlay và collision proxy. |
| [sect_isometric_world_v1.gd](../../../godot/src/presentation/p3/sect_isometric_world_v1.gd#L126-L245) | Seed model và route preview; project/inverse; virtual_legacy_point quy đổi anchor. Route hiện được tạo rõ cho Spawn → Hall/warehouse/forge; producer markers không đồng nghĩa đã có road-to-site gameplay path. | Nếu thêm tuyến, phải là preview/presentation road, không thay pathfinding/runtime production. |
| [sect_isometric_world_v1.gd](../../../godot/src/presentation/p3/sect_isometric_world_v1.gd#L257-L359) | refresh_from_state dựng điểm hiển thị từ building thật; producer giữ ID thật; selection đổi screen→world rồi hit-test ellipse. | Giữ mapping instance ID và mở đúng panel. Geometry hit phải theo chân/footprint, không theo alpha sprite. |
| [sect_isometric_world_v1.gd](../../../godot/src/presentation/p3/sect_isometric_world_v1.gd#L361-L535) | Cached ArrayMesh theo 16×16; sparse road/terrain overlays; y-sort building/vegetation; Mỏ/Lâm/Điền chưa có texture riêng nên fallback footprint/label. | Giữ renderer/chunk path hiện tại; không thêm renderer hoặc vật lý mới để giải quyết composition. |
| [sect_map_camera.gd](../../../godot/src/presentation/p3/sect_map_camera.gd#L4-L65) | View rect (0,72,1280,570), zoom .75–1.80, default 1.0, focus 1.35, clamp world bounds. | Giữ một camera tự do, UI ngoài world transform; default framing phải cho thấy hub và ngõ ra. |
| [p3_2_landscape_sect.gd](../../../godot/src/presentation/p3_2_landscape_sect.gd#L502-L567) | World chạy trong 1280×570 SubViewport; map pick chuyển tiếp đến building handler; camera legacy actor overlay đồng bộ với iso world. | Không dựng màn map/clock/runtime mới. Giữ exact scene P3.2 và các panel hiện tại. |
| [sect_map25_source_art.gd](../../../godot/src/presentation/p3/sect_map25_source_art.gd#L32-L77) | Chỉ nạp file nằm dưới root + đúng SHA256, trả texture; missing/rejected fail-closed. | Không đổi manifest/gate và không nhận asset dựa vào filename đơn thuần. |
| [sect_iso_map_model_v1.gd](../../../godot/src/presentation/p3/sect_iso_map_model_v1.gd#L8-L28) | Footprint + doorway definitions và AStarGrid2D là presentation model. Nó không phải SimulationState, save schema hay gameplay construction. | Mọi đường/footprint thử trong MAP-D1 phải tiếp tục ở layer trình bày. |

## 4. Điều kiện asset / duplicate / scope

| ID / group | Có thật ở repo | SHA verified | Dùng hiện tại | Dùng nguyên bản? | Gaps/ràng buộc |
|---|---|---:|---|---|---|
| MAP25 4 terrain + 6 road + 19 vegetation + 3 PV01 building | Có: godot/art/source_a_env02a/ | 32/32 | subset runtime/gate | Có; source bytes giữ nguyên | Không water/cliffs/dirt/path-wall kit; 570183 unused |
| 3 PV01 buildings | Có; IDs 510052/520081/510102 | 3/3 trong gate | Hall/Forge/Warehouse | Có; runtime sizes do code chỉ định | Không chứng minh historical 8-family exact master art |
| Numeric environment IDs | Có: 19 PNG | 19/19 | 18 DECOR_LAYOUT, one unused | Có; không đổi byte | Không metadata semantics/pivot/action |
| B3 map/battle screenshots | Có trong evidence/packet-b/sha4b02 | 19/19 screenshot SHA | QA screenshots | Chỉ để xác nhận tách world | Không tái dùng làm sect-map concept art |
| P3_ASSET_REGISTRY/source recovery documents | Có | SHA không thuộc PNG list | stale metadata | Chỉ làm lịch sử/inventory | Cần reconcile; không sửa ở MAP-D0 |

## 5. Ranh giới world

**Map tông môn:** SectIsometricWorldV1, shown in P3.2. Nó trình bày tông môn, canonical building instances, worksite cues và actor overlays.

**Map săn Thanh Trúc Lâm:** B3HuntWorld/battle view của CARE. 20 bãi săn/respawn/monster/event/loot thuộc world riêng. Ảnh 09–15 chứng minh đây là cửa sổ encounter khác. MAP-D0 không chọn tile, đường, spawn, kích thước hay camera của hunt world.

## 6. Baseline PR31 regressions (không rerun trong nhiệm vụ docs)

- Official Godot 4.7.2.stable.official.ed1daf0bf; PR31 code/test 4b02a0c61a2771d9d4638129d96b68ad292270dc.
- 28/28 focused PASS; 56/56 S1 edge checks PASS; O9 production rehearsal PASS; MAP25 art gate accepted=32/missing=0/rejected=0.
- 19 GUI screenshot frames at 1280×720. Capture snapshots have recorded fps 1–24 and static_memory_bytes 62.7–73.7 MiB across states; this is **not** a sustained FPS/OS RAM profile and must not be promoted into one.
- Windows physical/manual, Android physical/touch, sustained perf and Owner Visual remain PENDING.
