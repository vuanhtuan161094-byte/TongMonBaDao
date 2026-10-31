# HS-09 — Screenshot & binary archive manifest

**Source:** HTML HS-09 offline; screenshots captured in Chromium (not Godot).
**Date:** 2026-10-31; owner has approved HTML/CSS visual direction.
**Binary status:** Screenshot PNGs are packaged in `TMB_HS09_Design_Handoff_20261031.zip` for download/backup. **PNG binary files are not currently committed to this GitHub branch**, due to upload limitations of the available connector. Do not present this manifest as proof that GitHub hosts the PNGs.

| Path in ZIP | Resolution | SHA-256 |
| --- | --- | --- |
| `screenshots/HS09_TongQuan_1280x720.png` | 1280×720 | `2c77a4d70242d6f33627d6694b867b004f41efa8dc891569bcb31c69d61b134c` |
| `screenshots/HS09_ThuocTinh_1280x720.png` | 1280×720 | `4e425b14d772dbbe96fcc0affe53178b399bd5c59d5b15df83c48f6595b4a3d8` |
| `screenshots/HS09_TongQuan_915x412.png` | 915×412 | `7bc61d9438e03300a403310322c1c96272d411efc07ed67d31b50630bf4d784e` |
| `screenshots/HS09_ThuocTinh_915x412.png` | 915×412 | `c4e8068ed9175f2236e39e6b4f5068177a792f6389801d091670844fa05b0376` |
| `screenshots/HS09_TongQuan_812x375.png` | 812×375 | `449142fa9567cc4775b89348f7e7ba5f6f92f37619858a38f40421b7738b392c` |
| `screenshots/HS09_ThuocTinh_812x375.png` | 812×375 | `716f48dd60bf97dbe4e17b4cbaa272d1badf60b432825653824580183febd11b` |

Exact HTML binary SHA-256: `cdfcbbb1ef5fc88357db02a79fc280fe55ce23ce1722a03ce8cbd3502e1f3baf`.

## QA rerun

Chromium headless viewports 1280×720, 960×540, 915×412, 812×375:
- 7 tabs; overview radar click selects Thuộc Tính.
- No JS errors in exercised flows.
- No document horizontal overflow at each tested viewport.
- JSON sample import displayed `DỮ LIỆU JSON ĐÃ NẠP (CỤC BỘ)`.
- Tools menu, roster toggle and study subview worked at 915×412.

No Godot import, GUI gameplay, actual Android hardware or Source A animation verified in this design snapshot.
