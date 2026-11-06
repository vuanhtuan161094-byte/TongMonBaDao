# Master backlog source intake — RESOLVED (2026-11-06)

The owner-provided sources were read from `D:\Downloads`:

- Prompt: `TMB_PR72_MASTER_QA_CODEX_PROMPT_20261106.md` — SHA-256 `287e735b25e91e669c7e47f9499461e8ca546ad281e42a607ecb7d2982a412bb`.
- Workbook: `TMB_PR72_MASTER_FEATURE_QA_20261106.xlsx` — SHA-256 `304d4dc2bff846824762f2cb62df10cb9c0b18dcfc3f4729e8d1f33998574c1d`.

## Intake integrity

The workbook contains 35 requirement IDs (`REQ-01`–`REQ-35`), 158 QA IDs (`QA-001`–`QA-158`) across 18 systems, 10 journeys (`J01`–`J10`), and 15 gaps (`GAP-01`–`GAP-15`). The acceptance matrix retains all 11 original `QA_CASES` columns and adds five execution/evidence columns. A cell-by-cell comparison of all 158 rows and 11 source columns against the workbook returned **0 mismatches**. The workbook's declared baseline SHA is `fa872eaa07b2abc27240ecd754de13fd4774a8cc`.

## Current branch and evidence boundary

- PR #72 remains Draft on `integration/pve-p0-playable-ui-20261103`; live GitHub HEAD at intake: `857ce164442a3a845d554b6ab1315abf92c85281`.
- Gameplay/test evidence referenced by the register: `5ef179b81dfef6f2d72a38d866e94fc828e179eb`; P3.2/density/P3.4B/O3 source tests: `374f2d47d887c828218e3a296b6c8370aff070e7` (runtime files unchanged through 5ef).
- In the 158-row matrix, current annotations are 11 `PASS_HEADLESS`, 2 `PASS_GUI_HARNESS`, 9 `IN_PROGRESS`, and 136 `CHUA_NGHIEM_THU`. These are row-level evidence annotations, **not** a whole-game acceptance result.
- All 10 E2E journeys remain incomplete: six are `IN_PROGRESS`, two `BLOCKED_SOURCE`, two `CHUA_NGHIEM_THU`. Physical Windows mouse/UI and Android remain pending. No balance/content gap was filled by inference.
- The earlier “sources unavailable” checkpoint is superseded. The existing execution subset remains a subset and is not replaced by the full matrix.

## Source artifacts

- [Requirement register](../TMB_PR72_REQUIREMENT_REGISTER_20261106.md)
- [158-case acceptance matrix](../TMB_PR72_FEATURE_ACCEPTANCE_MATRIX_20261106.csv)
- [10 E2E journeys](../TMB_PR72_E2E_JOURNEYS_20261106.md)
