# P1.4 — Memory with Consequences

## Goal

Add bounded long-term memory that changes simulation decisions. Memory is not accepted as a narrative-only feature.

## Scope

- P1.4 builds on locked P0 + P1.1 + P1.2 + P1.3.
- Memories are created only from meaningful combat/social experiences.
- Repeated identical experiences consolidate into the existing memory instead of creating unbounded rows.
- Each disciple stores at most 24 memories.
- Memory importance is shaped by personality.
- Negative experiences are remembered more strongly by survival-oriented disciples.
- Positive victory experiences are remembered more strongly by risk-oriented disciples.
- Memory influence weakens with age but retains a long-term floor.
- Place memories directly affect region utility.
- Social memories directly affect region utility when the remembered person is present/targeting that region.
- Player-created companion experiences receive extra importance and can continue affecting behavior after the companion order is cleared.
- Memory state must persist through save/load and deterministic continuation.

## Meaningful memory events

- personal victory;
- personal retreat;
- personal defeat;
- shared victory;
- witness retreat;
- witness defeat.

Every stored event type has a measurable behavioral consequence through place or social region utility.

## Scale contract

- maximum 24 stored memories per disciple;
- repeated signatures consolidate;
- no global all-memory scan;
- a decision reads only the acting disciple's bounded memory list;
- memory formation only occurs on meaningful events, not every simulation tick.

## Player agency contract

Companion assignment already changes immediate behavior in P1.3. In P1.4, meaningful shared experience while assigned can create a stronger player-linked memory. Clearing the assignment removes the immediate order but does not erase the experience, allowing the player's earlier decision to have a lasting consequence.

## Exclusions

P1.4 does not add romance, marriage, mentor/disciple hierarchy, sworn siblings, factions, betrayal/leaving, internal combat, cultivation realms/techniques, bosses, premium currency, or production art.

## Verification

`Sync-P1-4.cmd` must keep every earlier gate green, then prove:

1. memory changes a region decision;
2. positive and negative place memories have opposite behavioral effects;
3. personality changes memory importance;
4. repeated experience consolidates;
5. the 24-memory cap holds;
6. player-linked shared experience can continue affecting behavior after clearing the companion order;
7. same-seed memory formation is deterministic;
8. save/load preserves memories;
9. deterministic continuation remains stable;
10. invariants and money conservation remain green;
11. the P1.4 memory scene launches successfully.
