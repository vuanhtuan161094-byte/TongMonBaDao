# Next Codex Task — Combat V3-S2 Planning / Owner Decisions

This is a follow-up prompt only. Do not begin it until the owner explicitly authorizes Packet B. The completed Packet A fix is on `fix/combat-v3-s1-official-qa-20261024`, in [draft PR #30](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/30), stacked above PR #29. Read the official report and inspect the final draft PR before planning any follow-up.

## Prompt to paste for the next task

Continue Tông Môn Bá Đạo combat work from the reviewed Combat V3-S1 Packet A result. First inspect PR #29 and the stacked Packet A draft PR, read `docs/handoffs/TMB_COMBAT_V3_S1_OFFICIAL_QA_REPORT_2026-10-24.md`, and confirm exact branch heads before editing. Do not merge either PR.

Before changing behavior, ask the owner to decide these two unresolved compatibility/semantics questions:

1. Should burn damage continue after its caster is downed, or should the current pilot clear-on-caster-death rule remain?
2. Is a real historical v2 binary save fixture required for compatibility sign-off? The repository did not contain one; the Packet A v2 fixture was derived from the v3 payload and old schema fields.

Until those decisions and explicit Packet B authorization arrive, perform read-only planning only. Keep Packet A boundaries: do not alter UI/UX, Source A, D7, economy or medicine, HP×100, Combat×100, or unrelated PRs. If Packet B is later authorized, use its exact allowlist and focused official Godot evidence workflow; report blockers with exact file/line and never claim PASS without official Godot logs, valid exit code, and completed tests.

## Handoff state

- Packet A focused result: 14/14 PASS and 56/56 edge assertions PASS on tested source `4fe466d8efc192aa93738811041de795baadb22a`.
- Godot: `4.7.2.stable.official.ed1daf0bf`; import and tests exit 0. Isolated profile stderr includes a root certificate store diagnostic; see report.
- S1 scope blockers observed: none.
- No physical Android/visual QA, full CI, S2, or merge was performed.

