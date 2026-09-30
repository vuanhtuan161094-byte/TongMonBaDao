# P1.5 — Organization, Teams, Leadership, and Roles

Status: IMPLEMENTED / AWAITING RUNTIME GATE

## Goal

Turn the sect from independent autonomous individuals into a player-shaped organization without removing disciple autonomy.

Every organizational mechanic must change measurable simulation behavior. Titles with no consequence are out of scope.

## Scope

### Teams

- A disciple may belong to at most one team.
- Team lookup is direct through `disciple_team_ids`; decisions do not scan the full sect.
- Team size is capped at 6.
- Initial P1.5 state creates two deterministic small teams from the existing population.
- The player may move a disciple between teams.

### Leaders

- Every non-empty team may have one leader who is also a team member.
- A leader's current/target region adds organizational utility to members considering that region.
- Leadership influence is shaped by the member's trust and respect toward the leader.
- Very low trust/respect can make the leadership modifier negative.
- P1.4 social memories remain independent modifiers, so good/bad history with the leader can reinforce or counter the immediate leadership effect.
- The player may replace a team leader.

### Roles

P1.5 contains only three functional roles:

- `hunter`: increases hunting utility and favors dangerous/profitable regions.
- `logistics`: lowers hunting priority and increases buying/selling/recovery utility while favoring safer regions.
- `guard`: favors safer regions and provides bounded regional support to teammates when present/targeting the same region.

Roles are player assignments. A role is not complete unless its behavioral modifier is measurable.

### Player agency

The player can:

- move a disciple to another team;
- appoint a team leader;
- assign hunter/logistics/guard roles;
- clear a role.

These operations change simulation state immediately, while disciples still choose actions through the existing AI utility system.

## Interaction with earlier systems

- P1.1 personality and goals remain active.
- P1.2 recruits can be assigned to teams and roles after recruitment.
- P1.3 trust/respect modulate leadership influence.
- P1.4 memories continue to modify region choice independently and can reinforce or oppose a leader's influence.
- P0 economy conservation remains unchanged.

## Scale rules

- No full-population team scan per decision.
- One direct disciple -> team lookup.
- Maximum 6 members per team.
- Leadership calculation reads one leader relation.
- Guard support scans only the acting disciple's bounded team.
- No N x N organizational matrix.

## Verification contract

1. Full P0/P1.1/P1.2/P1.3/P1.4 gates must pass first.
2. Same seed must create the same teams/leaders.
3. A disciple cannot belong to multiple teams and team size cannot exceed 6.
4. Changing the team leader must measurably change a controlled member's region decision.
5. Trust/respect toward the leader must measurably change leadership influence.
6. A strong negative memory about a leader must be able to counter otherwise positive leadership influence.
7. Logistics role must be able to change an action decision from hunting to buying in a controlled probe.
8. Hunter role must measurably increase hunting utility.
9. Guard role must create measurable bounded support for teammates in the same/targeted region.
10. Moving a member between teams must measurably change organizational influence.
11. A recruited P1.2 disciple must be assignable to a team and role.
12. Team, leader, role, lookup, and change-count state must survive save/load.
13. Continuation after save/load must remain deterministic.
14. Invariants and money conservation must remain green.
15. The P1.5 interaction scene must launch in Godot 4.7.2.

## Exclusions

P1.5 does not add sect needs/upkeep, buildings, morale, salaries, mentor/disciple hierarchy, romance, factions, betrayal/leaving, cultivation realms/techniques, bosses, premium currency, or production art.
