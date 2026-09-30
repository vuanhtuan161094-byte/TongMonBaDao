# NEXT CHAT HANDOFF — Tông Môn Bá Đạo

Date: 2026-09-30
Current main: `7a29da7d9f3e76f7078d9bb27bb2d726094373e6`

## Read first

Before changing code, read:

1. `AGENTS.md`
2. `CURRENT_CHECKPOINT.md`
3. this file
4. live code/tests for the active phase

Do not rely on old chat wording when it conflicts with the repository/checkpoint.

## Runtime status

PASS / LOCKED with real Godot 4.7.2 evidence:

- P0 Foundation
- P1.1 Goal + Personality
- P1.2 Recruitment
- P1.3 Relationships

IMPLEMENTED / AWAITING RUNTIME GATE:

- P1.4 Memory
- P1.5 Organization
- P1.6 Sect Needs
- P2.1 Cultivation + Realms + Breakthrough
- P2.2 Spiritual Root Quality
- P2.3 Technique Economy + Tàng Kinh Các + Mastery
- P2.4 Cultivation Paths / Character Dao Direction

Never call P1.4–P2.4 PASS until the user runs the real Godot gate. Current authoritative local command is `Sync-P2-4.cmd`.

## Core game philosophy

The player does not puppet every disciple. The player controls the sect, priorities, investment and opportunities; characters react autonomously based on personality/state/history.

Every mechanic must have measurable simulation/player-decision consequences. Do not add decorative bars, labels, titles, rarity, lore or state that does not change behavior/outcomes.

New phases must be opt-in through a new factory so older locked paths remain behavior-compatible.

## Current progression stack

- P2.1: cultivation progress -> breakthrough -> realm -> effective combat power + HP -> AI/combat/region changes.
- P2.2: root quality Tạp/Phàm/Địa/Thiên changes cultivation speed + breakthrough probability; no hard realm cap.
- P2.3: sect-owned technique economy. Player gacha uses sect spirit stones. Disciples farm personal spirit stones, technique fragments and upgrade materials. Manuals can be sold or consumed to archive permanently in Tàng Kinh Các. Learning costs personal Contribution + personal spirit stones. Max 3 learned techniques, only 1 active. Cultivation increases technique mastery; level upgrades need materials. Techniques carry rarity + path (Kiếm/Thể/Pháp) + element + role. Elemental root affinity affects technique efficiency but never forbids learning.
- P2.4: no fixed class. Each disciple accumulates Sword/Body/Spell path XP from actual technique usage. Cultivation +10 path XP, combat win +4, retreat/defeat +1. Old XP never resets. Identity is derived from history (Kiếm tu, Kiếm–Pháp song tu, etc.). Deep Sword improves combat, Body improves defense, Spell improves cultivation; matching path also improves same-path technique effectiveness.

## Decision made immediately before switching chats

Do NOT implement Master/Disciple next.

Master/Disciple was deliberately deferred because at this stage it would mostly become a training-percent system. It should return later after disciples have more things worth transmitting: techniques, combat moves/skills, path experience, combat history and potentially professions.

## NEXT PHASE: P2.5 — Combat Moves / Skills

This is the agreed next phase.

Goal: make Kiếm / Thể / Pháp feel mechanically different in combat instead of mostly differing through coefficients.

Direction discussed:

- Techniques should unlock or provide access to combat moves/skills.
- Example Sword moves: Thanh Phong Trảm, Ngự Kiếm, Phong Kiếm Liên Kích.
- Example Body moves: Kim Cương Hộ Thể, Chấn Sơn Quyền, Bất Động Thân.
- Example Spell moves: Hỏa Cầu, Liệt Diễm, Hỏa Vũ.
- Moves must change actual combat decisions/outcomes; do not implement them as text-only abilities.
- P2.5 should build on P2.3 technique `path`/element/role and P2.4 accumulated path expertise.
- Do not yet implement Master/Disciple, equipment/artifacts, secret realms, bosses/factions or full combat-team V2 unless strictly required by P2.5.

## Before implementing P2.5

Inspect current `main` exactly. Design the narrow vertical slice first. Recommended questions for the implementation itself (do not ask the user unless truly necessary):

- how many move slots are needed initially;
- how techniques unlock moves;
- how AI chooses moves autonomously;
- costs/cooldowns/resources for moves;
- how Sword/Body/Spell differ measurably;
- how P2.4 path expertise improves same-path moves;
- deterministic combat RNG preservation;
- save/load + invariants + old gate compatibility.

Create a new P2.5 factory, tests, scene, verifier and `Sync-P2-5.cmd` chaining P2.4. Since the user currently cannot use the Windows machine, mark P2.5 only `IMPLEMENTED / AWAITING RUNTIME GATE` until real Godot output is supplied.
