# Báo cáo kiểm toán — Dev Character Studio MVP

**Repo:** `vuanhtuan161094-byte/TongMonBaDao`
**Base đã fetch:** `main` — `461caca1171462e0da092f21108c5c1733157ad9`
**Nhánh riêng:** `feature/dev-character-studio-mvp`
**Engine:** Godot 4.7.2
**Phạm vi:** chỉ `godot/addons/tmb_character_studio/`; không sửa runtime, project settings, save hoặc authority sản xuất.

## Kết quả theo authority hiện hành

- `DiscipleState` là state sản xuất có identity, nền tảng, tiến trình, skill, equipment, inventory và save representation. Studio chỉ tạo object tạm trong bộ nhớ cho preview; không sửa/serialize object sản xuất.
- `DiscipleGeneratorV2` là authority sinh đệ tử deterministic, đọc state seed và generation index. Studio không gọi generator và không ghi `profile_seed`/`latent_identity_seed` vào preset.
- `DiscipleBirthCatalogueV2` có bảng trait/fate/physique/bloodline canonical. `DiscipleBirthProfileV2` dùng envelope version 1 và domain seed riêng; các lớp birth chưa `initialized` không được giả thành identity thật.
- `DiscipleRealmProgressV2` sở hữu hai track Tu Vi/Luyện Thể, mỗi track 30 cảnh giới × 10 tầng. `initialize` yêu cầu complete V2 birth identity. Preview chỉ gọi label/progression/stat consumers hiện có; coordinate trong preset là sandbox input, không phải tiến trình đã lưu.
- `DisciplePresentationSnapshotV2` là read model và không mutate state. Nó che latent identity; snapshot V2 phân loại effect root/trait/bloodline/physique/destiny là `identity_only`.
- `DiscipleActorVisualCatalog` hiện có hai rig modular `female_normal_v1`/`male_normal_v1`, frame/pivot coarse và fallback path riêng. `ModularDiscipleActor` có hình fallback cho runtime; studio không dùng fallback đó để giả Source A.
- Trên base `main`, `DiscipleSourceAVisualPool` chưa có. Source A V5 worktree (hiện tại `ae3f397cef654cd3ff1936261b018476a132e7db`; snapshot audit ban đầu `44a25b56d684f15783b3161072a317577b1ac3be`) có pool ba rig thật: `1113028_1` (female), `body_1110201` (male), `body_1120402` (male). Cả ba có `actor.tscn`, `animations.tres`, atlas và metadata `stand`/`walk`; hai rig nam qua SHA-256 `asset.json`. Rig nữ có binary hiện diện nhưng checksum `actor.tscn`/`animations.tres` trong `asset.json` không khớp nội dung checkout nên studio đánh dấu **CHƯA XÁC MINH**, không preview/lưu preset bằng rig đó cho đến khi authority cập nhật manifest.
- Source A V5 `visual_manifest.json` chứa mapping combat/base actor và scale, không thay thế asset manifest từng rig. Manifest `godot/data/presentation/source_a_candidate_manifest.json` trên base `main` lại là 13 building candidates; nó không liệt kê rig/character binary. `godot/assets/` hiện không có trên base `main`.
- `CombatStatsV2` là stat derivation hiện hành. Các channel gồm HP/attack/defense, move/attack/cast/cooldown rate, crit, effect hit/resistance, reduction và lifesteal; không có `accuracy`/`evasion`.
- `CombatSkillSystem` là nguồn skill definitions và ownership/eligibility (`learned_combat_skills`, `min_stage`). `DiscipleCombatLoadoutV2` nhận role từ `frontline/ranged/mage/healer`, tính skill damage loadout và deferred skill. Không có runtime skill-slot schema; preset slot chỉ là thứ tự editor, DESIGN-ONLY.
- `EquipmentSystem` canonicalizes ba slot `weapon/armor/talisman` và recipe IDs. Studio lưu recipe reference trong sandbox, không tạo kho, item ownership hay giao dịch.
- `CURRENT_CHECKPOINT.md` giữ DV2-03 **PAUSED**; plugin không mở lại phase runtime này.

## Giới hạn runtime hiện hữu

Khi chỉ checkout base `main` `461caca`, Source A character pool và binary chưa có nên dock sẽ báo thiếu pool/rig, không hiện placeholder. Khi Source A V5 snapshot có trong project, plugin đọc danh sách thật và kiểm tra asset paths, manifest, SHA, animation resources. Rig có manifest hash sai vẫn được liệt kê nhưng hiện **CHƯA XÁC MINH** và không được preview/lưu preset. Root/talent nếu V2 birth profile chưa complete và skill ordering không được runtime tiêu thụ sẽ hiển thị DESIGN-ONLY. Accuracy/Evasion không được đưa vào stat schema.
