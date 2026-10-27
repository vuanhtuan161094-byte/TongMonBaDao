# Regression diagnosis — exact SHA 0d3952dd

## Full matrix

22/22 test exit 0 trên `0d3952dd11f85bebbde60176deafc4f19afc8a6f`; official Godot `4.7.2.stable.official.ed1daf0bf`. Xem CSV và raw logs bundle ở [EVIDENCE_INDEX](EVIDENCE_INDEX.md).

## Findings

| Hạng mục | Bằng chứng | Kết luận |
|---|---|---|
| SaveService error 1 / D7 | `core_d7_save_ab`: invalid D7 fixture có aptitude/quality không nhất quán; `save_error=1`, primary hợp lệ không bị thay. Natural aptitude và cross-seed control save/load PASS. | Fixture lỗi có chủ đích; không sửa SaveService, validation và bảo vệ save cũ được giữ. |
| Movement C17 / formation | C17 14 checks PASS; đội hình 10 checks PASS, 6 slot duy nhất, deterministic, snapshot và atomic failure. | PASS headless; `physical_mouse=NOT_TESTED`. |
| Camps / HP0 / autonomous | 20-camp contract PASS, 20 camps; 200/300/400 population slots chỉ là contract. HP0 bridge PASS, unpaid receipt/reward=none. Autonomous C01→C02, 11 kills, 5 respawns C01, Save/Reload PASS. | Không suy diễn rằng đã chạy 400 quái thật; không có loot giả. |
| Injury120 | GP-02C1 online/offline, terminal/recovery/compatibility checks PASS; T119/T120 PASS. | Test độc lập PASS; P3.2 encounter không đạt Injury120. |
| P3.2 6v10 | 6 thành viên, 10 quái, 6 điểm di chuyển, spacing min 2.83, Save/Load và zone-hop PASS, 10 kills. | PASS headless; test kéo dài 256.765 giây wall-time. |
| VFX JX #158 | Cast, projectile, positive hit, one impact; no fake hit explosion; SaveService reload không replay. | PASS focused/headless; timing/hình ảnh GUI chưa nghiệm thu. |
| Performance | `visual_perf_probe` PASS là contract logger p50/p95/p99/max/1%low/spikes/immutable, không phải lượt benchmark. P3.2 headless mất 256.765s. | Nguyên nhân lag GUI chưa xác định. Cần FPS logger OFF/ON và Godot profiler trong cửa sổ chơi thật. |
| Editor import | Lượt đầu exit 0 nhưng quét shader-cache QA trong `godot/outputs` và ghi lỗi không vào được 14 thư mục; thêm lỗi ghi editor settings vì profile mặc định không writable. Rerun với APPDATA/LOCALAPPDATA cô lập và temporary `.gdignore` tại outputs: exit 0, không còn lỗi ngoài root-certificate warning. Temporary file đã gỡ. | Asset import được xác nhận trong lượt cô lập; không sửa project source hoặc test assertions. |
| Engine warnings | Godot stdout có `Failed to read the root certificate store`; lệnh exit 0. D7/Injury negative fixtures ghi `ERROR` khi xác nhận fail-closed. | Không phải test failure theo exit/status; không được xóa validation để làm log im. |

## Tách bạch PASS

- `HEADLESS_PASS`: full 22, Stage A import/two contract tests và invariant tests ở trên.
- `PENDING_GUI`: click thật, camera/minimap, combat presentation, Save/Return, screenshots/video.
- `PENDING_FPS`: không có số percentile, 1%-low, peak RAM hay attribution trên GUI.
- Không tuyên bố PLAYABLE PASS.
