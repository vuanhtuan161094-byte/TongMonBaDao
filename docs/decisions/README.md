# Decision Records

Dùng cho **quyết định presentation/architecture có ảnh hưởng lâu dài**, không dùng cho mọi thay đổi nhỏ.

Nguyên tắc:

- một quyết định lớn = một file;
- file đã `accepted` không rewrite lịch sử quyết định; nếu đổi hướng, tạo ADR mới và đánh dấu `supersedes`;
- MD canonical hiện tại giữ trạng thái đang áp dụng; ADR giữ **vì sao** quyết định đó được chọn;
- tuning nhỏ, sửa typo, bổ sung asset variant không cần ADR.

## Trạng thái

- `proposed`;
- `accepted`;
- `rejected`;
- `deprecated`;
- `superseded`.

## Template tối giản

```md
# ADR-NNNN — Tiêu đề

Status: proposed
Date: YYYY-MM-DD

## Context
Vấn đề cần giải quyết là gì?

## Options
- A
- B

## Decision
Chọn gì và tại sao?

## Consequences
Điều gì dễ hơn, khó hơn, rủi ro nào còn lại?

## Links
Các spec/code/test bị ảnh hưởng.
```

## Index

- `0001-use-p3-presentation-authority-workflow.md` — accepted;
- `0002-adopt-git-lfs-for-production-art.md` — proposed, chưa bật cho tới khi kiểm trên máy Windows.
- `0003-fe00-godot-native-data-driven-frontend.md` — accepted (DESIGN ONLY; FE-01 not authorized).
