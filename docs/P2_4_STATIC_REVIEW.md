# P2.4 static review

Runtime status: NOT RUN. Godot 4.7.2 local gate remains required.

Reviewed contracts:

- P23Factory remains path-disabled.
- P24Factory enables paths only after P2.3 initialization.
- P2.4 introduces no RNG and therefore does not consume combat/recruitment/gacha RNG streams.
- Path identity is derived from accumulated XP; no fixed class field exists.
- Switching active technique changes future XP target without clearing old path XP.
- Sword path feeds effective combat power; Body path feeds incoming damage; Spell path feeds cultivation gain; all three feed autonomous action utilities.
- Matching path history amplifies active same-path technique effects.
- Save/load fields use backward-compatible defaults.
- New recruits can start with empty path XP and accumulate normally.
- P0 money and P2.3 spirit-stone state are not mutated by P2.4 path progression.

This review is static only and is not runtime evidence.
