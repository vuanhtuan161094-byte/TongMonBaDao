# P2.8 — Disciple Generation V2 + Phẩm chất + Recruitment Sources

Date: 2026-10-01
Status: DESIGN LOCK / IMPLEMENT ONLY AFTER P2.7 RUNTIME GREEN

## Mục tiêu

Thay mô hình candidate “roll combat_power trước” bằng một generator procedural tạo **một con người hoàn chỉnh**, sau đó mới suy ra sức mạnh hiện tại.

P2.8 không làm toàn bộ Huyết Mạch/Thể Chất/Thiên Mệnh gameplay. Nó chỉ tạo nền identity đúng để các phase sau gắn vào mà không rewrite.

## Feature gate

P2.8 phải opt-in. Khi `disciple_generation_v2_enabled == false`:

- P1.2 recruitment cũ không đổi behavior;
- P2.2 roots cũ không đổi behavior;
- P0-P2.7 exact regression phải giữ xanh.

## Generator order canon

Một cá thể V2 được sinh theo thứ tự:

1. deterministic `profile_seed` + `recruitment_source`;
2. identity: name/race/sex/origin;
3. six permanent foundation dimensions;
4. derived quality tier;
5. personality core + biases;
6. spiritual-root elements + purity/quality as separate axes;
7. profession talent/quirk subset;
8. latent IDs/seeds for future bloodline/physique/destiny if included in schema;
9. age + base/max lifespan schema;
10. starting realm/progression;
11. derive current base combat power from foundation + starting progression;
12. persist once; reveal never rerolls.

## Six dimensions

P2.8 activates storage and generation for:

- aptitude / Tư Chất;
- constitution / Căn Cốt;
- fortune / Cơ Duyên;
- comprehension / Thông Tuệ;
- charisma / Mị Lực;
- potential / Tiềm Lực.

Initial value range should be readable and deterministic; exact balance may be tuned after runtime distribution reports.

Only dimensions with currently available consequences must affect simulation immediately:

- Tư Chất -> cultivation gain hook;
- Thông Tuệ -> workforce learning and technique-learning hook when appropriate;
- Căn Cốt may remain stored until a real consequence is added, unless P2.8 introduces one measurable body/stamina consequence.

Do not add fake modifiers just so every stat is “active”.

## Phẩm chất

Working tiers:

1. Phàm Thường
2. Xuất Chúng
3. Thiên Kiêu
4. Tuyệt Luân
5. Nghịch Thiên

Quality derives from permanent foundation score/thresholds. It must be recomputable and deterministic.

Do not count directly:

- gear;
- current realm;
- sect rank;
- profession XP;
- temporary buffs;
- wallet/resources.

Quality promotion API must allow permanent-foundation improvement to cross a tier threshold.

A lower-quality disciple must still be able to have a superior profession talent/root combination for a specific role.

## Recruitment sources

At least three source types in the vertical slice:

### Ordinary recruitment

Broad common distribution, cheap/free cadence, candidates arrive naturally.

### Chiêu Hiền / disciple gacha

Consumes an explicit sect resource. It improves distribution/guarantee rules but still generates a complete procedural individual.

No fixed duplicate-character fragment loop is required because ordinary disciples are unique procedural people.

### Nhân Duyên / fate source

Testable source representing event/bí cảnh/encounter recruitment. Can bias unusual roots/fortune/traits without promising high overall quality.

All three call the same generator API with source policy.

## Spiritual Root V2

Separate:

- `root_elements` — one or more elements;
- `root_purity/quality` — cultivation/effect strength.

Do not derive element count rigidly from quality.

Required proof: two generated profiles can have same quality with different element counts, and multi-element can still have good purity.

Existing P2.2 legacy logic remains when V2 off.

## Starting realm and combat power

V2 must stop treating combat power as the first random identity field.

Starting realm/progression is generated after foundation. Base/current combat power is then derived from at least:

- foundation/body contribution;
- starting realm/progression;
- existing cultivation bonus model.

Exact formula should preserve gameplay scale and not double-count P2.1 realm bonus.

If necessary, introduce an intrinsic/base-power derivation that feeds existing combat systems without rewriting P2.5.

## Age and lifespan schema

P2.8 may add persistent:

- age/current_age;
- base_lifespan;
- max_lifespan;
- lifespan bonus history/counters if needed.

P2.8 does **not** need to activate death processing yet.

Major-realm lifespan grants and longevity-pill gameplay belong to the lifespan phase unless a minimal hook is required for schema correctness.

## Hidden future identity

P2.8 may reserve deterministic latent identifiers/seeds for:

- bloodline;
- physique;
- destiny;
- hidden quirks.

If stored, they must be deterministic and persistent. Do not expose decorative names with no gameplay consequence yet.

Reveal later reads existing latent state; it never rerolls.

## Existing-system hooks

### P1.1 Personality

Keep archetype/bias system; generator chooses it as one layer.

### P1.3 Relationships

No rewrite. Future Charisma hook can modify relationship event deltas/probability.

### P2.1 Cultivation

Tư Chất multiplier may apply only with V2 enabled.

### P2.3 Technique

Technique gacha remains separate from disciple gacha.

### P2.4 Paths

Innate identity may bias efficiency, never fix class/path.

### P2.6 Equipment

Quality of disciple and quality of item are separate namespaces/concepts.

### P2.7 Workforce

Current `comprehension` should migrate/alias to canonical Thông Tuệ rather than become a duplicate stat.

## Persistence

Every V2 field must round-trip exactly.

Required:

- same seed/source/index -> exact same candidate;
- save/load exact equality;
- continuation deterministic;
- hidden fields persist before reveal;
- feature off -> prior snapshots/behavior unchanged.

## Gate contracts

1. V2 is opt-in and legacy P1.2/P2.2 behavior is unchanged when off.
2. Same seed + source + index generates exact same full profile.
3. Different source policies alter distributions/rules but use same profile schema.
4. Six base dimensions are valid and persisted.
5. Quality is derived only from permanent foundation and is unaffected by equipment/rank/current profession/current realm.
6. Permanent foundation increase can promote quality.
7. Lower-quality candidate can still beat higher-quality candidate on a specific profession/root suitability probe.
8. Root purity/quality is independent from element count.
9. Starting combat power is derived after identity/progression, not a standalone generator roll.
10. Ordinary recruitment returns complete individuals.
11. Chiêu Hiền/gacha returns complete individuals and consumes explicit resource correctly.
12. Nhân Duyên source returns complete individuals under its own source policy.
13. Candidate -> accepted disciple preserves identity exactly.
14. Exact save/load + deterministic continuation PASS.
15. P0-P2.7 cumulative regression PASS.

## Explicitly deferred

- full bloodline mechanics;
- full physique mechanics;
- destiny effects;
- loyalty/stipend;
- injury system;
- death/inheritance;
- master-disciple;
- marriage/dual cultivation;
- mass gacha pity/monetization balancing;
- full UI polish.

P2.8 is about **correct identity generation**, not activating every future system.