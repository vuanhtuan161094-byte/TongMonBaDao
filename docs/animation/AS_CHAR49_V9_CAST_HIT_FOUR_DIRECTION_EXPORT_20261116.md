# AS-CHAR-49 V9 — Cast + Hit bốn hướng (2026-11-16)

## Kết quả

**Mức hoàn thành: 20/24 clip ứng viên kỹ thuật, 0/24 production approved; Godot 4.7.2 NOT_RUN.** Lượt này xuất **Cast_Front/Right/Back/Left và Hit_Front/Right/Back/Left**, mỗi clip 8 tư thế 512×512 RGBA *thật* từ các bảng 4×8 đã có. Mỗi clip 8/8 frame pixel-distinct; không sinh lại nhân vật, không tạo frame giả hay lấy hình poster. Cast_Right cũ được thay bằng Cast_Right cùng nguồn mới. Idle/Walk/Attack 4 hướng của V8 giữ nguyên.

- Full ZIP personal ChatGPT Library: `/TMB-Character-Art/AS_CHAR49_V9_CAST_HIT_FOUR_DIR_CANDIDATE_20261116.zip`, **99,652,900 bytes**, **405 file entries**, ZIP CRC PASS, SHA256 **`9939b1363d0c8d706f1d3f728ebbc18f6748528ce7253dbad6c2d88dcec8e9e8`**. Binary **không** nằm trong GitHub.
- Source Cast: `four_direction_xianxia_cast_sprite_sheet.png`, 1774×887 RGBA, SHA256 `57a0672dfe15ecc6af4fd0c67baf238e136b3f0714776bb5b3cecce4feab5074`.
- Source Hit: `chibi_xianxia_swordswoman_reaction_sheet.png`, 1774×887 RGBA, SHA256 `87ff852b9d699cc092f06c82a516fb3fc27ed1e576a4150aa4d548a98d687514`.
- Mỗi nguồn là **bảng 4 hàng hướng × 8 key pose**, không phải GIF động gốc. Mỗi GIF chỉ là **preview** thật dựng từ đúng 8 hình trong cùng một hàng. Hướng từng hàng: Front, Right, Back, Left. Nguồn raw preserved trong ZIP.
- Gói tích hợp **144 PNG frame RGBA 512×512**, **20 atlas 2048×1024**, 20 GIF + 20 APNG preview, 24-slot manifest chính xác, SHA từng frame, 1280×720 review video ngoại tuyến Cast/Hit, HTML review player, Godot 4.7.2 source-only project (20 animation real keys).
- Cast timing one-shot mỗi hướng [160,140,125,135,180,210,160,180]ms; Hit [100,65,85,120,145,95,110,155]ms. Đây là **preview timing**, chưa map vào Combat V2 hit/cast event runtime.
- Alpha cleanup: giảm diffuse colored speckles nhưng bảo tồn hào quang; root theo từng hướng không tự kéo cả nhân vật theo đáy mỗi frame. Không rig, Skeleton2D/Bone2D, không gameplay integration.

## QA đã thực hiện

- `tools/verify_v9.py` **PASS**: 20 key animation, **144 frame SHA256 + alpha + 512×512 + pixel-perfect atlas**, 40 animated GIF/APNG checks, **4 missing Death** đúng.
- GIF 8 frame/clip. 8/8 key poses khác biệt về pixel cho Cast Front/Right/Back/Left và Hit Front/Right/Back/Left.
- QA images: `qa/Cast_4DIR_FRAME06_OFFLINE.png`, `qa/Hit_4DIR_FRAME04_OFFLINE.png`. Preview: `qa/Cast_FOUR_DIRECTIONS_OFFLINE.gif`, `qa/Hit_FOUR_DIRECTIONS_OFFLINE.gif`. MP4: `qa/CAST_4DIR_OFFLINE_NOT_GODOT_1280x720.mp4`, `qa/HIT_4DIR_OFFLINE_NOT_GODOT_1280x720.mp4`. **NONE of these are Godot engine captures**.
- `OPEN_PREVIEW.html` shows only real clip paths, no fabricated Death placeholders. Windows and Android live QA pending.

## Art blockers (no false PASS)

- **Cast_Right frame 5/6**, **Cast_Back frame 4** have high-alpha VFX touching source grid borders; **Hit_Left frame 3** also touches cell edge. Source clipping/visual jump may need painted fixes. Detailed pixels logged in `qa/QA_V9.json` (4 instances). These are not automatically art PASS despite all file integrity PASS.
- Owner has approved Attack art source, **has NOT signed off Cast/Hit/Death motion**. No confirmed master original female APNG bytes. Sword grip, temporal smoothness, loop/transition, pivot on actual ground at 1×/2×/3× still need manual review.
- Godot 4.7.2 executable unavailable in current runtime: **ENGINE_NOT_RUN**, exact SHA-native screenshots/video cannot be claimed. Offline previews only.
- **Death_Front / Death_Right / Death_Back / Death_Left missing**. Earlier GIF death attempts were mostly a single falling sequence seen at similar angle, not four independent valid direction clips. Do not rename GIFs to inflate coverage.
- No Codex, rig, new branch, merge, Combat V2, SaveService, PvE, V6.3, economy or deployed actor change.

## Provenance

PR #72 Draft existing branch `integration/pve-p0-playable-ui-20261103`. HEAD checked before this doc: `02ab55a3e5bffb368e402e91a5206f385ac27dc8` (concurrent branch writes may advance). Stage only documentation here; user-facing binary ZIP in personal Library.
