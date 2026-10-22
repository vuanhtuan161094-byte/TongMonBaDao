---
name: tmb-balance-lab
description: "Audit and simulate TMB's 30x10 realm and body progression, map farming, Spirit Field, pill economy, loot and multi-source Tu Vi against canonical game code."
---
# TMB Balance Lab — SKILL
## Start with actual source data
Load current DiscipleRealm/Body progression tables, character stats, Tu Vi flow, AlchemyRecipeRegistry, ResourceRegistry, Warehouse/production rates, map rewards and encounter data. Do not invent tier curves to fill missing tables. Label each number SOURCE, OWNER LOCK, PILOT, ASSUMPTION, or PROPOSED.

## Model the full loop
Map difficulty & farming policy -> genuine rewards/materials -> Spirit Field and other production -> real recipes/jobs -> Warehouse debits -> pill use -> HP/XP/state -> unlocked challenge. Preserve correct units: sim ticks, XP per sim minute, real wall-time at 1x, resource counts and HP ratio. Keep no direct kill XP unless a new owner-authorized canonical reward source exists.
The 1000 XP/min base is a baseline, NOT the lifetime progression rate; do not claim 48 billion / base speed is the final full-game time. Distinguish realm-specific pills and materials from today's starter Hoi Xuan +55 and Tu Khi +10000.

## Analysis protocol
1. Create 4-6 snapshots spanning early, mid and late realms, body cultivation and representative equipment. Compare medicine power relative to max HP and next-tier XP need, not only absolute values.
2. Audit faucets/sinks by explicit resource ID: field, mine, forest, map, loot, alchemy, jobs and usage. Check craft arbitrage, bottlenecks, dominant farming map, stock saturation and dead-end progression.
3. Simulate 24-hour/7-day/30-day canonical-time trajectories and a representative 1000-3000 disciple policy. Include auto-heal, cooldown, absence and One Active Job conflicts.
4. For stochastic loot, use deterministic seeded Monte Carlo when authorized and feasible; report n, seed, percentiles, mean, tail outcomes, fail rates, and sensitivity. Random simulation is not proof of a live implementation.
5. Detect exploits: repeated click before receipt, save/load day reset, negative stock, phantom medicine, duplicate XP/loot, free retries, illegal cross-realm breakthroughs.
6. Provide proposed progression tables with formulas and units for owner review. Do NOT rewrite canonical balance from proposed outputs until CODE authorization.

## Hard acceptance constraints
Shared pill satiety = 100000/day/disciple, canonical day floor(tick/1440); Hoi Xuan 10, Tu Khi 25. A transaction crossing cap fails BEFORE stock debit or HP/XP effects. No surprise diminishing returns or second per-pill count cap. Later tiered pills, higher map rewards and Spirit Field grades must be designed together and approved before code.
Display impact: %max HP healed, %next-layer XP granted, minutes of active cultivation saved, real material cost, ROI and economic side effects.

## Sources
Concepts adapted, not blindly copied, from NVlabs/Skill2Env game-balance-check and setcodes/gamedev-skills game-designer; the original balance configuration of TMB overrides generic free-to-play or monetization templates.
