# PR #28 UI / Source A issue matrix

Current tested P3.2 source: `9f7e10425e907b74ce69af1c3d74d60bc1984eaf`  
Code commit: `47b704270ae165504aeef526963e8d03f87bc579`  
PR #28: OPEN / DRAFT / UNMERGED

| ID | Area | Status | Evidence / disposition |
| --- | --- | --- | --- |
| SRC-01 | P3.2 GDScript source header at fetched f253cca1 | **FIXED / VERIFIED** | Remote parent blob began with a literal truncation warning before `extends`; code commit 47b70427 restores valid GDScript source. Official focused suite and real P3.2 capture pass on the corrected blob. |
| UI-01 | Mine/Linh Lâm worker phase hidden when roster is collapsed | **FIXED / PASS** | Initial O3 failed on hidden `haul_back` text. P3.2 now exposes active cycle/timer from canonical state in `ĐANG THỰC HIỆN`; O3 rerun PASS. Both logs retained. |
| UI-02 | P3.2 map, pan/zoom, production panels, Warehouse and real V2 profile | **PASS, visual review pending** | 12 actual scene captures at 1280×720. Owner has not approved the final visual. |
| UI-03 | CARE damage/receipt overlap and readable fact labels | **IMPROVED / OWNER REVIEW PENDING** | Existing label/lane fixes are in earlier PR28 commits. New combat screen captures are real but some receipt labels still crowd. |
| AST-01 | Four local worker actor packs: Boss, female disciple, male disciple, Thanh Lang | **VERIFIED DUPLICATES / REUSED** | Exact atlas SHA; scene/animation text exactly matches after newline normalization. Raw text SHA differs only CRLF/LF. Current packs are already present; no overwrite/copy. |
| AST-02 | MAP25 Source A static environment, 32 SHA-locked files | **PASS** | `sect_map25_verified_art_gate_test`: accepted=32, missing=0, rejected=0; actual map capture. |
| AST-03 | Complete Source A building art for Mỏ/Linh Lâm/Linh Điền | **BLOCKED / ASSET PACKAGE INCOMPLETE** | No full packs found. Seven candidate packs missing; three candidates lack dependencies and require QA. No inferred assets installed. |
| AST-04 | Candidate cultivation/body-training/medicine hall visuals | **REJECTED** | Manifest entries are inferred analogs without source bundles. |
| COMBAT-01 | CARE/Combat V2 remains authority; V5 displays only verified actors/events | **PASS** | V5 presenter test PASS; no simulation/reward path changed. Boss asset/event remains unmapped. |
| SAVE-01 | Paid loot, canonical Warehouse and SaveService receipt persistence | **PASS** | Actual P3.2 capture manifest: `paid_generation=1`, Warehouse stock=1 before/after reload; integration test PASS. |
| REG-01 | 21 focused regressions at the corrected source | **PASS 21/21** | Official Godot 4.7.2; clean isolated user profile for each test. |
| REG-02 | O9 multi-producer rehearsal | **PASS current / historical FAIL retained** | Current clean O9 M2 PASS. Initial 19/20 FAIL and separate 20/20 clean PASS retained; original variance cause unknown. |
| EVID-01 | Mine idle + active-worker screen | **PARTIAL** | Actual 1280×720 frame at `after_47b70427/mine_running_1280x720.png` shows real active work phase. Extended evidence harness failed its later one-batch settlement assertion. Do not treat that harness as a settlement PASS. |
| EVID-02 | Settled Mine batch screenshot and male V2 profile screenshot | **PENDING** | O3 test proves Mine settlement, but no successful GUI capture for the settled frame; male profile image was not captured. |
| PLAT-01 | Windows manual mouse acceptance | **PENDING** | GUI capture is automated; no manual player acceptance claimed. |
| PLAT-02 | Android landscape touch | **PENDING** | No physical-device evidence. |
| OWNER-01 | Owner visual approval | **PENDING** | Awaiting owner review of actual screenshots. |
| CI-01 | FULL / CI | **NOT RUN** | Explicitly outside this authorization. |

