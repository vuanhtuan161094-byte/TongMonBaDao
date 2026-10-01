# NEXT CHAT HANDOFF — Tông Môn Bá Đạo

Date: 2026-10-01

Always inspect live `main` before editing.

## Runtime status

Real Windows + Godot 4.7.2 cumulative gate is green through P2.6:

- P0-P1.6: PASS
- P2.1 Cultivation: PASS
- P2.2 Spiritual Roots: PASS
- P2.3 Technique Economy: PASS
- P2.4 Cultivation Paths: PASS
- P2.5 Realtime Combat + Independent Skills: PASS
- P2.6 Forge + Equipment Tycoon: PASS

P2.6 final evidence included persistence diagnostic, forge/equipment contracts, equipment combat-stat consequence contracts and interaction scene smoke.

## Core game identity

The player is the sect master, not an invisible city-builder cursor.

The player controls sect infrastructure, recruitment, policy, resource allocation, production and direct interventions when desired. Disciples should still feel like people who live inside the sect: they cultivate, work, hunt, recover, form relationships and make autonomous choices according to their own state.

Direct control is allowed where it makes sense for a sect master, but routine micromanagement should not be mandatory.

## Locked stack through P2.6

- cultivation/realm
- spiritual roots
- cultivation techniques
- emergent Sword/Body/Spell path identity
- independent combat skills
- deterministic real-time autonomous combat
- forge materials, crafting and deterministic equipment
- autonomous equipment purchasing/equipping
- player manual equip + slot lock + return-to-auto
- internal equipment money conservation

## P2.6 persistence notes

- SaveService v2 lossless float64 format remains mandatory.
- `last_decision` integer fields are canonicalized after load.
- nested equipment instances are canonicalized after load.
- exact immediate P2.6 save/load equality PASS.

## Next design request from user

Do not immediately code P2.7.

First research and design how cultivation/sect-management games develop and assign individual disciples, especially:

- Amazing Cultivation Simulator
- The Lost Village
- 最强祖师
- Evil Hunter Tycoon

Focus on:

1. what makes one disciple different from another;
2. how a disciple develops over time;
3. how production/work duties are assigned;
4. how combat disciples vs production/logistics disciples differ;
5. how much the player orders directly vs how much characters do automatically;
6. how to combine those ideas with this game's existing autonomous simulation and the player's role as sect master.

The preferred direction is not a fixed class system. A weak combat disciple may still be valuable as a talented alchemist, farmer, smith, merchant, recruiter, logistics worker, etc.

P2.7 remains UNLOCKED until that design is agreed with the user.
