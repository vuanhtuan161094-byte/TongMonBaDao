# TMB — AS-CHAR-40 Modular Sprite Feasibility V1.1

**Kết quả đã kiểm tra:** 18/18 Python PASS, 24 clip / 96 frame **kỹ thuật**, 2 biến thể áo và 2 biến thể kiếm; kiếm dùng 4 nguồn pixel tư thế (2 kiểu × 2 pose). Chi tiết `docs/FEASIBILITY_REPORT_20261114.md` và `proof/RESULTS.json`.

**KHÔNG phải art game:** toàn bộ ảnh/GIF trong `proof/` là hình khối kiểm thử phần mềm, tuyệt đối không dùng vào game hoặc báo owner đã duyệt. Không có sprite Kiếm Tu hoàn thiện, không chứng minh Walk đẹp, chưa chạy Godot runtime. Đây là kiểm định tính khả thi của lớp xuất ảnh và socket.

## Chạy kiểm thử

```powershell
python -m pip install Pillow
python -m unittest discover -s tests -v
python tools/benchmark_fixture.py --out proof
```

## Chạy QA Godot 4.7.2 (sau khi copy proof vào lab)

1. Copy `proof/export_cobalt/` và `proof/_TECHNICAL_FIXTURE_ONLY/` (nếu cần tái xuất) vào `godot/labs/character_family/as_char40_modular/proof` trong một **checkout QA tách biệt**, không động production.
2. Dùng executable Godot 4.7.2 Windows đã có ở E: để import project Godot (qua `--headless --editor --quit`).
3. Chạy `--headless --path godot --script res://labs/character_family/as_char40_modular/as_char40_headless_qa.gd -- --modular-proof-path=res://labs/character_family/as_char40_modular/proof/export_cobalt`.
4. Lưu stdout/stderr, exit code, exact SHA; PASS engine không có nghĩa ART PASS.

## Quy trình production sau đây

Có nguồn pixel thật: base nam/nữ, mặt, tóc, outfit cho từng frame/hướng, pose-cel vũ khí, anchor thật. Khi một `Walk front` đẹp ở 1×/6× được duyệt, dùng `tools/build_modular.py` để xuất atlas. **Tuyệt đối không rig**.
