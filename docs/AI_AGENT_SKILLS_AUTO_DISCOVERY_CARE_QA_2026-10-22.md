# TÔNG MÔN BÁ ĐẠO — AUTO-DISCOVER AGENT SKILLS / B3 CARE HANDOFF QA

**2026-10-22 — docs-only integration, NOT gameplay authorization.** Repository `vuanhtuan161094-byte/TongMonBaDao`; branch `docs/tmb-agent-skills-20261022`. Source of authority remains latest OWNER request > repository `AGENTS.md`/architecture > checkpoint/active packet > live code. Nothing here installs a persistent skill in ChatGPT or modifies the user's local machine.

## 1. What is available, and where

Six real, project-specific Agent Skills live under:
- `.agents/skills/tmb-project-director/SKILL.md` — scope, authority, select specialist;
- `.agents/skills/tmb-balance-lab/SKILL.md` — 30×10 Tu Vi/Luyện Thể, map, field, pill simulations;
- `.agents/skills/tmb-autoplay-ai/SKILL.md` — auto-hunt, injury, FSM/utility, NPC teams;
- `.agents/skills/tmb-godot-evidence/SKILL.md` — official Godot tests, crash/save, receipts, performance;
- `.agents/skills/tmb-asset-gate/SKILL.md` — Source A/JX manifests, Spine, animation, Godot QA;
- `.agents/skills/tmb-ui-playtest/SKILL.md` — Android landscape 1280×720, camera and UI usability.

All six use standard YAML frontmatter with concrete English/Vietnamese triggers. Their content is original, project-specific guidance adapted from inspected public repository skills; **not** an additional gameplay authority.

## 2. How to use efficiently — one routing step

The correct default is `tmb-project-director` + **one** specialist; max two specialists if changes cross domain boundaries.

| Request | Use | Mandatory minimum evidence |
| --- | --- | --- |
| Owner says “tiếp quản checkpoint / lên kế hoạch” | `$tmb-project-director` | source branch / SHA, status code vs docs vs user acceptance |
| “Cân bằng Tu Vi, map, Linh Điền, đan” | `$tmb-balance-lab` | canonical cost curves + actual producer/consumer rates, clearly labeled assumptions |
| “Tự săn, hồi phục, nhóm 3000 đệ tử” | `$tmb-autoplay-ai` | one scheduler, One Active Job, world ID, safety guard |
| “Kiểm thử Codex / bug save / bão hòa / gameplay” | `$tmb-godot-evidence` | ZIP manifests, changed paths, exact SHA, tests, rollback, non-duplicated receipts |
| “Asset đúng nhân vật, môn phái, animation” | `$tmb-asset-gate` | source, hash, clip, frames, pivot, test screenshot; missing != fabricated |
| “Chữ bé, UI xấu, camera, thanh tiến độ” | `$tmb-ui-playtest` | real 1280×720 shot and interaction, no UI-invented state |

**Do not load every SKILL.md for every task**; that wastes context and degrades authority checking. Skill can propose tests and solutions but never expand owner code allowlist. Prefer direct read of the two relevant skills and actual canonical source.

### Codex local / IDE
Codex discovers repository `.agents/skills/<name>/SKILL.md` in its **CURRENT checked-out worktree** (and ancestor dirs), can select by description, or use explicit prompts such as:
- `$tmb-project-director $tmb-godot-evidence Kiểm toán kết quả B3 CARE ZIP ...`
- `$tmb-project-director $tmb-balance-lab Thiết kế map farm/Linh Điền/đan 300 tầng; chỉ docs ...`

**Important:** these files currently exist on docs branch ONLY. The Codex B3 CARE worktree based on local `35ffa85f...` does not magically see them and MUST NOT be interrupted. After CARE handoff is archived, **on an isolated NEW worktree** have Codex fetch the docs branch and copy **only** `.agents/skills/tmb-*/SKILL.md` and the small AGENTS skill-routing note, preserving all existing root AGENTS rules. It must show git diff and stop before changing gameplay. One writer per overlapping file. No administrator login, no installation to `C:\Users\Admin`; use project's existing E: workspaces. Cloud Codex may not list repo skills in some environments; use explicit file paths if unavailable.

### ChatGPT / Work
The already-connected GitHub can read these skill documents per task; this is what current conversations can do now. **Repository files are NOT automatically installed into the global ChatGPT skill registry.** ChatGPT Work has its own skill-creation workflow if the user chooses to import these instructions. This branch makes them retrievable and reusable without retyping; never claim the installation happened.

## 3. New B3 CARE evidence — facts and conflict

Owner uploaded `B3_CARE_FASTTRACK_HANDOFF.zip` in conversation on 2026-10-22. Inspection of ZIP in session:
- 74 ZIP entries, `SHA256SUMS.txt` lists **73 valid entries, 73/73 recomputed SHA-256 match**.
- Commit embedded `35ffa85fd45da42e43722e7ac74b7423602d4491`; base `1d686dc8e202f4831fa51373c15e6666f44702f9`, local Codex branch `feature/b3-care-pills-autohunt-20261022` (not known pushed to remote).
- `FOCUSED_RESULTS.json` lists 15 focused runs on official Godot `4.7.2.stable.official.ed1daf0bf`, each PASS / exit0 / marker. **This is provided artifact evidence**, not a new independent Godot run by ChatGPT.
- Local Codex reports authentic alchemy recipe/ticks, fixed Tu Vi pill +10000, HP0→HP1/Injury1→heal/REST→tick120 reentry same world, another 2 genuine kills, total 4 `tinh_lang_bi` in Sect Warehouse; crash/retry/save tests PASS per logs. Manual Windows player acceptance and physical Android remain **PENDING USER**. Not FULL, CI, merge or push.
- **RESOLVED 2026-10-22 owner correction:** previous **100000** was a typo missing a zero. Owner directly approved **1000000 satiety/day/disciple**, which matches the ZIP code `const CAPACITY := 1000000`, test labels and README. Technical 15/15 focused evidence is retained; still PENDING physical Windows and Android/manual user acceptance. No CAP repair packet is required on this evidence.
- Do not revert valid 1000000-day ledgers to the previous mistaken 100000. Keep one canonical-day ledger, atomic medicine/XP effects and receipt replay-protection; don't edit CARE code without integration authorization.

## 4. Recommended single Codex follow-up (after CARE is archived; not sent)

```
TÔNG MÔN BÁ ĐẠO — INTEGRATE AGENT SKILLS DOCS-ONLY. CARE handoff has already been produced at commit 35ffa85fd45da42e43722e7ac74b7423602d4491; do not alter its code/worktree. In a NEW isolated worktree under E:, use repo branch docs/tmb-agent-skills-20261022 and import ONLY .agents/skills/tmb-* skill folders, with minimal additive AGENTS.md routing stanza if necessary. Read root AGENTS.md and owner decision first. Validate six SKILL.md frontmatters/names/trigger descriptions, run no installer/binary/FULL/CI, and show diff with only the skill/docs paths. No CODE, no main push or merge, no Source A. Afterwards show Codex skill discovery or exact file-read evidence; when automatic discovery absent, use explicit $tmb-project-director and one specialist. STOP if it needs to change runtime, save, economy or CARE.
```

## 5. Next B3 acceptance decision

1. Owner directly approved **1000000** on 2026-10-22; CAP discrepancy is resolved.
2. Check B3 CARE focused+save evidence against exact commit and canonical rules.
3. Physical Windows/Android acceptance remains pending, distinct from integration criteria.
4. CARE integration to main requires dedicated integration branch, regression gates and preserved old save semantics; don't infer it has already merged.
