---
name: tmb-autoplay-ai
description: "AI tự động Tông Môn Bá Đạo: auto hunt, hồi phục Injury120, tự uống đan/nghỉ, chọn map, đội hình Boss, đệ tử 1000-3000, policy, FSM, utility AI, pathfinding; for autonomous logic design only unless CODE explicitly authorized."
---
# TMB Smart Autoplay & AI — SKILL
## Model hierarchy first
Player sets policy for team/group/workforce. Simulation scheduler owns valid transitions; policy makes recommendations/commands, never mints rewards. Use a simple finite-state machine for the B3 pilot: AT_SECT -> DEPLOY_ELIGIBLE -> HUNTING -> DOWNED -> RECOVERING -> REDEPLOY_ELIGIBLE or MANUAL_PAUSE. An injury cannot clear early. Auto OFF and manual return must win over auto reentry.

## Two-stage decision
1. Safety and hard rules BEFORE scoring: injury=0; canonical HP ratio at least allowed threshold; at sect; One Active Job free; not reserved for PvE/job/training; genuine V2 profile; previous kill receipt durably settled; adequate medicine/warehouse; world still valid.
2. Among permitted tasks, evaluate a transparent Utility score for heal/rest/farm/retreat/work from health, danger, role, distance, yields, resources and owner priority. Hysteresis/cooldown avoids ping-pong. Scores never bypass hard constraints. Prefer deterministic tie-breaking and a documented scheduler interval, not a second wall-clock timer.

## Scale without lag
Group 1000-3000 disciples into teams/work cohorts; schedule coarse policy decisions on canonical ticks with partitioning/budgets, not hundreds of new AI trees every rendered frame. Separate logical intent, navigation/path request and animation/presentation. Cache path until target changes meaningfully; recompute sparingly. Offscreen simulation must agree with the same authoritative rules and not create ghost rewards.
For combat teams consider tank/defend, damage, healer, support, target threat, retreat and crowd control; don't invent unapproved roles as production features. Boss/multi-team reward allocation is a future design packet, not a pilot feature to sneak into CARE.

## Validate dangerous transitions
Death/HP0 -> HP1 and Injury1 once; 119 ticks cannot redeploy; tick120 with all gates may redeploy same surviving world; auto OFF stays stopped. Save/restart mid-hunt, mid-Injury, mid-rest, and after kill settlement must preserve world ID, target/spawn, cooldown and inventory receipts. B3 use exactly one canonical simulation tick owner. Repeated policy evaluations should be idempotent and not add extra XP.
Record decision reason, actor ID, world ID, authority tick, gate result and action receipt for reproducible QA, without logging per-frame floods.

## Sources
Decision/steering/path layering adapted from bgrenat/godot-game-dev-studio gamedev-game-ai and gamedev-skills/awesome-gamedev-agent-skills ai-behavior-trees-utility-ai. Do not paste their generic code into Combat V2.
