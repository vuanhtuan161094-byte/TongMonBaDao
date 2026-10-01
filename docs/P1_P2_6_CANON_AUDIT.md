# P1.1 → P2.6 Canon Audit

Date: 2026-10-01
Status: CANON AUDIT LOCK

## Mục tiêu

Đối chiếu toàn bộ nền P1.1 → P2.6 với canon đệ tử mới: đệ tử procedural, Phẩm chất có thể đề thăng, sáu thuộc tính nền, Linh Căn/Huyết Mạch/Thể Chất/Thiên Mệnh tách biệt, thọ mệnh, nghề nghiệp, tổ chức và vòng chơi kiểu Evil Hunter Tycoon.

Nguyên tắc audit: **không đập lại những phase đã runtime PASS nếu có thể mở rộng bằng feature gate/composition**.

---

## Kết luận tổng

P1.1 → P2.6 **không cần viết lại**. Phần lớn hệ cũ là nền đúng và tái sử dụng được.

Hai refactor lớn là bắt buộc trong generator V2 nhưng phải feature-gated để không đổi baseline cũ:

1. P1.2 Recruitment hiện roll `combat_power` trực tiếp trước khi sinh nền móng. V2 phải sinh **con người trước**, rồi mới suy ra sức mạnh hiện tại.
2. P2.2 Spiritual Root hiện gắn chặt `root quality` với `element_count`. V2 phải tách **độ tinh thuần/phẩm chất Linh Căn** khỏi **số hệ/nguyên tố**.

Ba semantic lock cần áp ngay nhưng không đổi behavior:

- P1.5 `role_assignments` chỉ là **combat/adventure role**, không phải sect rank hoặc profession.
- P1.6 logistics cũ phải đọc role qua accessor combat-role, không phụ thuộc trực tiếp storage semantic.
- P2.6 `talisman` là **equipment accessory slot**, không phải Pháp Bảo tương lai.

---

# P1.1 — Goal + Personality

## Giữ nguyên

- `risk_bias`, `spend_bias`, `survival_bias` đang tạo khác biệt hành vi thật.
- `GoalSystem` có tầng mục tiêu dài hạn và survival override.
- Goal không phải class; phù hợp autonomy kiểu Evil Hunter.

## Mở rộng sau

- personality lõi vẫn giữ;
- `traits/quirks` là lớp khác;
- alignment/lập trường là lớp khác;
- Mị Lực, loyalty, tuổi/thọ mệnh có thể tạo modifier lên goal/decision;
- gần đại hạn có thể sinh goal tìm đột phá/thọ đan/truyền thừa.

## Không cần refactor nền

P1.1 là nền đúng.

---

# P1.2 — Recruitment + Player Choice

## Giữ nguyên

- candidate pool;
- accept/reject;
- capacity;
- deterministic generation index;
- player choice.

## Sai semantic so với canon mới

Hiện `generate_candidate()` roll trực tiếp:

- `combat_power`;
- personality biases;
- rồi mới gắn root/workforce profile.

V2 phải đảo thứ tự:

`profile seed/source -> innate identity -> six foundation dimensions -> quality -> root/bloodline/physique/destiny latent state -> starting progression -> derived current combat power`.

`combat_power` không được là “gen bẩm sinh tổng hợp” của V2.

## Hướng V2

- mọi nguồn tuyển dùng chung một generator;
- ordinary recruitment / Chiêu Hiền-gacha / Nhân Duyên chỉ thay distribution/source rule;
- không reroll hidden state khi reveal;
- vẫn giữ candidate pool + accept/reject API nếu có thể để UI/flow cũ dùng tiếp.

---

# P1.3 — Relationships

## Giữ nguyên

- directed relationship;
- affinity/trust/respect;
- event-driven changes;
- relationship ảnh hưởng quyết định vùng/đội.

## Mở rộng sau

- Mị Lực ảnh hưởng tốc độ/biên độ quan hệ;
- personality/alignment ảnh hưởng loại event;
- loyalty với tông môn phải tách khỏi quan hệ cá nhân;
- sư đồ, bạn thân, kình địch, đạo lữ về sau có thể derive từ relationship + history.

Không rewrite.

---

# P1.4 — Consequential Memory

## Giữ nguyên mạnh

Bounded meaningful memory là nền rất tốt cho “đệ tử có lịch sử sống”.

## Event cần bổ sung về sau

- breakthrough success/failure;
- quality promotion;
- bloodline/physique/destiny awakening;
- heavy injury;
- Sect Master reward/punishment;
- master-disciple transmission;
- near-death/lifespan events;
- inheritance/death.

Không rewrite storage/model hiện tại.

---

# P1.5 — Organization + Teams + Leadership + Roles

## Giữ nguyên

- combat/adventure teams;
- leader/member relation;
- team support;
- roles `hunter/logistics/guard` as tactical/activity behavior.

## Semantic correction bắt buộc

`role_assignments` **không được** mở rộng thành:

- ngoại môn/nội môn/trưởng lão;
- Luyện Khí Sư/Luyện Đan Sư;
- Luyện Khí Đường/Dược Viên.

Ba trục phải tách:

1. combat/adventure role;
2. sect rank/authority;
3. profession/work group.

Giữ key save `role_assignments` để không phá persistence; expose tên API mới `combat_role_*` và legacy wrapper nếu cần.

---

# P1.6 — Sect Needs + Resource Pressure

## Giữ nguyên

- medicine;
- supplies;
- lodging;
- departure supply cost;
- rest recovery pressure.

Đây là nền tốt cho colony/sect-life.

## Refactor semantic nhỏ

`process_logistics_tick()` hiện đọc trực tiếp `role_assignments`. Phải đi qua accessor combat-role để storage cũ không bị hiểu nhầm là profession.

## Mở rộng sau

- injury consumes medicine/time and may need medical worker;
- Alchemy/Medicine professions replace abstract passive production gradually;
- lodging/rank/sect status can affect comfort/mood later;
- lifespan pills belong to alchemy/item systems, not generic medicine stock.

Không phá P1.6 baseline.

---

# P2.1 — Cultivation + Realms + Breakthrough

## Giữ nguyên

- deterministic stage progression;
- breakthrough success/failure;
- realm gives real HP/combat consequences;
- cultivation vs field directive;
- failure cooldown/cost.

## Hooks cần có trong V2+

- Tư Chất modifies cultivation gain;
- Căn Cốt/Thể Chất can modify body-side effects;
- major-realm metadata grants lifespan;
- breakthrough failure may later generate injury/foundation damage;
- near-death breakthrough can extend lifespan before death resolution.

## Không đổi locked P2.1 behavior khi V2 off

Các hook phải feature-gated/composed.

---

# P2.2 — Spiritual Roots

## Giữ nguyên

- roots materially affect cultivation, breakthrough, technique mastery/effect;
- element compatibility is real, not decorative;
- deterministic identity generation.

## Refactor bắt buộc trong V2

Hiện quality definition cũng quy định `element_count`:

- mixed -> 3;
- ordinary -> 2;
- earth/heaven -> 1.

Canon mới yêu cầu:

- `root_purity/quality` = độ tinh thuần/chất lượng;
- `root_elements` = tập nguyên tố;
- hai trục independent enough để có song linh căn rất tốt hoặc đơn linh căn trung bình.

Không sửa P2.2 legacy data path khi V2 off.

---

# P2.3 — Technique Economy + Library + Mastery

## Giữ nguyên

- sect library/manuals/fragments;
- technique rarity;
- technique gacha;
- personal contribution/spirit-stone costs;
- mastery by training;
- max learned techniques;
- root compatibility.

Technique gacha và disciple gacha là **hai hệ riêng**.

## Mở rộng sau

- Thông Tuệ affects learning/mastery;
- physique/bloodline/destiny can modify specific technique families;
- master-disciple teaching can reduce time/cost;
- rare comprehension can unlock derived skills/insights.

Không rewrite.

---

# P2.4 — Cultivation Paths

## Giữ nguyên tuyệt đối về triết lý

Sword/Body/Spell identity được derive từ hành vi/lịch sử, không fixed class.

Đây phù hợp canon mới hơn cả class system.

## Mở rộng sau

- innate traits/physique/root create biases/affinity, không khóa đường tu;
- Đạo/ý cảnh có thể emerge từ deep path history;
- quality không quyết định path.

Không rewrite.

---

# P2.5 — Realtime Combat + Independent Skills

## Giữ nguyên

- realtime deterministic autonomous combat;
- skill independent from technique;
- distance/movement/cast/cooldown/projectile/effects;
- cross-path learning allowed with compatibility differences.

## Extension points sau

- injury modifies real combat;
- bloodline trigger;
- physique mechanics;
- destiny rule modifiers;
- artifact charge/trigger/skill;
- shield/reflect/targeting policy.

Không chuyển sang turn-based chỉ vì game tham khảo dùng lượt.

---

# P2.6 — Forge + Equipment Tycoon

## Giữ nguyên

- hunt -> materials -> forge -> storage/shop -> disciple buy/manual allocation -> stronger hunt;
- autonomous purchase;
- manual equip + lock/unlock;
- closed-money internal purchase;
- compatibility and real combat-stat consequences.

## Semantic lock

`SLOT_TALISMAN` hiện là **equipment accessory slot**.

Pháp Bảo tương lai là object/system riêng nếu có charge/trigger/skill. Không coi talisman slot hiện tại là artifact system.

## Mở rộng sau

- body/trait/root may alter gear valuation;
- forging profession/worker already hooks in through P2.7;
- artifact system must coexist, not replace P2.6.

---

# State/Persistence audit

## Giữ nguyên

- SaveService v2 exact float strategy;
- canonicalization discipline;
- optional feature state;
- deterministic continuation tests.

## Quy tắc cho V2

- latent/hidden values persist from creation;
- reveal does not reroll;
- all V2 fields have canonical from_dict/to_dict typing;
- legacy factories remain behavior-identical with V2 flag off.

---

# Thứ tự implementation sau audit

1. Chạy P2.7 cumulative gate và khóa P2.7.
2. P2.8 Disciple Generation V2:
   - six dimensions;
   - quality;
   - age/base lifespan/max lifespan schema;
   - source-aware generator;
   - root quality/purity decoupled from element count;
   - starting progression -> derived combat power;
   - ordinary/gacha/fate sources.
3. Traits/quirks + hidden reveal framework.
4. Bloodline + Physique.
5. Injury/medical.
6. Loyalty + stipend/reward.
7. Sect rank/authority.
8. Master-disciple/teaching.
9. Destiny/awakening.
10. Full active lifespan/death/inheritance after pacing is proven.

Do not activate all future systems in one phase.