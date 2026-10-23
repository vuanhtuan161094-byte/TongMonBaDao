# TÔNG MÔN BÁ ĐẠO — MỘT MAIN, MỘT GAME: CHÍNH SÁCH TÍCH HỢP SAU RECOVERY

**Lập ngày:** 2026-10-23 · **Loại:** ĐỀ XUẤT QUY TRÌNH ĐƯỢC OWNER ĐỒNG Ý VỀ HƯỚNG, **chưa có hiệu lực thay AGENTS.md trên main**; docs-only, không code, không CI/FULL, không merge.  
**Repository:** `vuanhtuan161094-byte/TongMonBaDao`. **Gốc tài liệu này:** `main@29b5fba448b0178cb520a4ada44b375b4b934e31` (lúc lập). **PR #24 và #25:** draft/stacked, chưa merge. Đợt MASTER RECOVERY do phiên Codex riêng thực hiện, **không động đến nhánh/worktree của Codex**.

## 1. VẤN ĐỀ GỐC VÀ MỤC TIÊU

Trước 23/10, hai dòng phát triển bị tách: **PR #18→#19→#20** chứa Source A/MAP25/G1 sản xuất và UI đã từng tốt; **main→PR #24 CARE→PR #25 P3.2** chứa gameplay săn/Care, nhưng chạy presentation từ P3.1 cũ. Combat V5/V5.1 còn nằm ở nhánh/worktree/ZIP riêng. Khi PLAYABLE đạt test gameplay, UI/map/sản xuất/Combat presentation trở về placeholder vì không có cổng tích hợp/asset non-regression chung. **Code pass ≠ visual pass.**

Mục tiêu: **một nhánh chính lâu dài `main`**, một ứng dụng/playable game, một bảng quyết định đã khóa, nhánh CODE/docs ngắn hạn và vòng tích hợp bắt buộc. Không có nhánh `integration` hay `docs` nào là “main thứ hai”.

## 2. TRẠNG THÁI CHUYỂN ĐỔI — KHÔNG TỰ ĐỘNG ĐƯA MAIN CŨ LÊN

- **Recovery đang làm**: không tạo một code writer khác, không reset/clean local V5/G1/Source A, không merge hàng loạt PR, không tự push `main`. Codex giữ worktree riêng và báo mốc R0–R6/thiếu asset với SHA.
- **Trước main cutover**, chủ dự án cần xem được ONE playable recovery: map **192×192**, starter **48×48** tại (72,72), chunk **16×16**, isometric/camera, Source A đã xác minh, G1 timeline Mỏ/Linh Lâm/Linh Điền, đệ tử V2 số thật, Combat V5 presentation trên chính CARE/Combat V2, canonical Kho/clock/One Active Job/SaveService.
- **Không coi** “đã có mã ở PR#20/V5”, “HEAD mới”, “13 focused PASS”, hoặc “có 10 ảnh” là proof rằng nhánh khôi phục đã tích hợp xong; phải có focused regression thực tế, diff provenance, ảnh/clip viewport 1280×720 và owner visual signoff.
- **Cutover**: sau QA, review phụ thuộc PR #24/#25/recovery; giải quyết base/merge conflict; owner **phê duyệt từng merge**. Việc cần nhiều commit có thể merge theo thứ tự, nhưng không được tạo bản `main` hỗn hợp chưa test.
- **Một khi cutover được owner duyệt**: `main` là nguồn gameplay/presentation/docs chuẩn. Nhánh khác chỉ là task đang review, không được gọi bản game mới nhất.

## 3. TRUNK-BASED NGẮN HẠN / CHỐNG PHÂN KỲ

| Nhánh | Cách dùng | Quy tắc |
|---|---|---|
| `main` | **MỘT bản tích hợp chính** | protected branch, code/review/tests và owner approval trước merge |
| `feature/<ticket>`, `fix/<ticket>` | một gói CODE đã được owner cấp phép | tạo từ main **SHA mới nhất**; tối đa một writer ở file chung; PR ngắn, rebase/refresh trước merge |
| `docs/<ticket>` | nghiên cứu backend độc lập | tạo từ main **SHA mới nhất**, không dùng nhánh docs khác làm gốc dài hạn; chờ owner duyệt rồi đưa nội dung đã duyệt về main; không đổi gameplay |
| `integration/<recovery>` | trường hợp đặc biệt ngắn hạn | chỉ tồn tại tới khi đủ QA/cutover, không phát triển roadmap dài hạn trên nhánh này |
| `archive/<...>` hoặc Git tag | backup code/asset lịch sử | ghi mapping SHA + tag và đảm bảo không còn untracked chưa lưu trước khi archive/delete |

### Cổng trước mỗi CODE task

1. **Fetch & inventory**: main HEAD, open PRs/stack dependencies, active worktrees/asset packs, decisions; tuyệt đối không coi main cũ là nơi duy nhất có thành quả.
2. **Source-of-truth matrix**: module đang live, bản tốt nhất đã chứng minh trên branch/ZIP, owner-locked law, status **DESIGN LOCKED / CODED / TESTED / VISUAL ACCEPTED / BLOCKED**.
3. **Impact analysis**: những feature nào có nguy cơ regress (map, G1 timeline, V5 art, UI Lục Duy, Combat V2, One Active Job, Warehouse, save), paths owner/allowlist và tập tests.
4. **Owner code permission** riêng: ticket, exact branch/base SHA, allowed paths, rollback/migration, forbidden systems, CI/FULL budget. Approval of design does **not** authorize code.
5. **Small patch**: one runtime, one clock, no new duplicate UI game reward authority; relevant focused QA Godot official 4.7.2 clean userdata; screenshot for presentation; log/exit/marker and SHA.
6. **Merge gate**: check diff vs **current** main and reference screenshots/baselines; tell owner what changed, what is not proven; merge only after requested signoff.
7. **After merge**: update main docs/decision log/checkpoint and archive PR; next task starts from the new main, not an old stacked PR.
8. **No second active gameplay main**: if blocked by long recovery, parallel docs research only; CODE tasks overlapping P3.2/source/CORE are queued.

## 4. DOCUMENT AUTHORITY IN MAIN (PROPOSED)

After owner accepts recovery, have **three compact indices ON MAIN**, referencing existing canonical specs rather than duplicating or rewriting them:
- `docs/governance/OWNER_DECISIONS_INDEX.md`: date, subsystem, exact owner choice, canonical reference, status, supersedes fields. Approved decisions **include** map 192×192/starter48/chunk16; Combat V2 authority; Source A style; G1 production UI; One Active Job/Injury120; 30×10 Tu Vi+Body; S2/F1/Q1; **X1 D2=A,D3=A,D4=A,D5=A**; **normal mobs materials/appropriate gear; Elite/Boss rarities/manuals**; owner XP direct valid kill once. Do **not** re-approve these.
- `docs/governance/CURRENT_IMPLEMENTATION_INDEX.md`: source SHA/path, implemented vs unmerged vs tested, local ZIP/worktree provenance and whether asset visual accepted. **Must not promote design to code status**.
- `docs/governance/INTEGRATION_NONREGRESSION_MATRIX.md`: one page of *map + G1 timeline + Source A + V5 + CARE + stats + Warehouse/save* acceptance gates; exact evidence pointers and owner PENDING reasons. Should be auto-checked in PR process when tooling later permitted.

**Conflict resolution always follows existing `AGENTS.md` owner/newest decision precedence.** Those proposed index paths are not magically authoritative merely from this document; need approved publication/cutover.

## 5. DESIGN BRANCHES: MANY RESEARCH STREAMS, ONE ORIGIN

- Allowed to study **D-ECO economy**, **D-ITEM item taxonomy+loot/forge**, **D-TECH technique rarity/pool/source**, **D-ALCH medicines/recipes**, **D-CONTENT realm content closure**, and Boss contribution **concurrently as docs**. Each from latest known main SHA, even if main is currently old, and has explicit “BASE_SHA, OWNER LOCKS, PROPOSAL/ASSUMPTION” banner.
- Research branches can propose new data but **may not set new canonical balance**. The owner chooses; accepted decisions are brought into main in reviewed docs PR **after recovery cutover**, rebased against newly integrated code/docs. If runtime ref is still draft PR, cite it explicitly as a *source to verify again*, not as merged main.
- Prefer **one shared contract of data identity** (see `docs/design/TMB_FOUNDATIONAL_CONTENT_TAXONOMY_AND_DROP_ECONOMY_FRAMEWORK_2026-10-23.md` on same branch), then independent domain specs; do not each invent incompatible resource/realm/item grade fields.
- Suggested design naming: one doc branch = one topic; no branch stacking off another docs branch; cross-dependencies as links; each owner-locked small decision added to shared canonical owner decisions index on main when cutover.

## 6. FAILURE MODES BLOCKING MERGE

- Regain CARE but regress Source A/G1/map/visual to rectangles/circles.
- Bring Source A/G1 but accidentally replace Combat V2 damage/kill/reward or an additional clock/warehouse.
- PR claims FULL PASS when log is incomplete, or screenshot capture automation called physical Windows/manual.
- Change item rarity/material IDs without provenance; break P2 compatibility or duplicate result receipts.
- Use 60/40 personal Stone distribution while Boss co-op exact split remains OPEN.
- Import high-grade procedural stats/affixes/techniques with no live consumer or sanctioned drop source.
- Drift of approved mechanics by copying old Markdown with outdated “still OPEN” statements.

## 7. IMMEDIATE ACTION / LATER EXECUTION PROMPT

**Now:** do not interrupt Codex's one recovery writer with a new CODE PR. This branch is docs-only.  
**After recovery QA:** owner reviews recovered playable, checks physical/manual/Android deferred reasons, authorizes ordered PR merge into main; then commission the three compact index docs and short-branch protection/checklist.  
**Independent next research:** ground-first loot and content taxonomy, then economic balance—not another 84 arbitrary item spreadsheet.

```text
TÔNG MÔN BÁ ĐẠO — SAU MASTER RECOVERY: ÁP DỤNG SINGLE-MAIN GOVERNANCE.
Đọc AGENTS.md và docs/governance/TMB_SINGLE_MAIN_TRUNK_AND_RECOVERY_GATE_2026-10-23.md ở nhánh docs/mainline-governance-content-foundations-20261023. Chỉ sau khi owner xác nhận recovery QA, kiểm tra main/current PRs; chuẩn bị một kế hoạch merge tuần tự #24/#25/nhánh recovery theo đúng dependencies, regression map 192x192/G1/V5/CARE, không force-push và không xóa worktree. Soạn 3 index docs canonical cho main. Chờ owner duyệt từng merge; không tự merge hay chạy FULL/CI.
```

**Không có thay đổi CODE trong hồ sơ này.**
