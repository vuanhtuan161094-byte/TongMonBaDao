# TÔNG MÔN BÁ ĐẠO — B3 V2: CHIẾN LỢI PHẨM, BOSS & PHÁT TRIỂN ĐỆ TỬ

**Ngày:** 22/10/2026 · **Tình trạng:** THIẾT KẾ CHI TIẾT / OWNER REVIEW. **Chưa triển khai gameplay, không merge, không sửa nhánh Source A đang chạy Codex.**
**Repo:** `vuanhtuan161094-byte/TongMonBaDao`. GitHub `main` đã đọc @ `461caca1171462e0da092f21108c5c1733157ad9`.
**Nhánh tài liệu:** `docs/b3-v2-architecture-redesign-20261022`.
**Căn cứ:** `docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md`, `COMBAT_SKILLS_V2_SPEC.md`, `WEAPON_EQUIPMENT_V2_SPEC.md`, `EQUIPMENT_SETS_V2_SPEC.md`, `EQUIPMENT_FORGING_UPGRADE_V2_ROADMAP.md`, `GAME_SYSTEM_ARCHITECTURE.md`; 3 contract B3 V2 World/Team AI/Monster AI; ZIP B2.4 được cung cấp ngày 22/10 (source snapshot, không phải main).
**Mục tiêu sản phẩm:** “Cày quái liên tục — đệ tử trưởng thành — đồ rơi đáng săn — Boss là cơ hội/sự kiện — tông môn có nền kinh tế thật”. Một hệ thống có chiều sâu mà Chưởng Môn có thể điều hành bằng đội/chính sách, không click nhận từng rương.

## 0. Quy tắc authority — không gộp luật đã chốt với đề xuất

### A. ĐÃ KHÓA trong spec/owner gần nhất

1. PvE **thời gian thực liên tục kiểu Evil Hunter Tycoon**, không giới hạn 90s, không chuỗi finite encounters, không kết thúc wave, quái chết/rơi/hồi **từng con**; Combat V2 là nguồn tính toán duy nhất. Boss/Elite có thể cùng xuất hiện trên cùng world; nhiều đội tồn tại đồng thời, mỗi quái một HP.
2. **Một Kho tông môn** cho stack vật liệu; gear/pháp bảo/bí kíp unique có registry/tài sản tông môn tương ứng; đồ rơi **không sở hữu riêng đệ tử**, không loot warehouse hoặc túi nhận thưởng theo đội. Trang bị 100% tông môn sở hữu, chỉ cấp phát/sử dụng.
3. **Phần thưởng cá nhân:** Tu Vi, skill/path mastery, Contribution, phần Linh Thạch cá nhân; **phần thưởng tông môn:** vật liệu, trang bị, bí kíp, tài nguyên, phần Linh Thạch tông môn. Không phải mọi kênh đều bắt buộc có ở mọi quái; cần authored source.
4. Tu Vi săn có dạng **yêu cầu EXP tầng hiện tại × basePct × realmMult × gradeMult × challengeMult × participationMult**. Chênh lệch rank, phẩm quái và mức tham gia **đã được mô tả trong spec**, các số V1 là starting design/tuning, **không phải rate production đã code**. Mục tiêu trung bình săn quái phù hợp ~**10–20×** tốc độ Tu Vi lao động thường, qua giờ thực và xét downtime, không phải nhân 20 mỗi con.
5. **30 cảnh giới × 10 tầng** cho Tu Vi và Luyện Thể; **không tự vượt đại cảnh giới ở tầng 10**. `DiscipleRealmProgressV2.grant_xp` trả `unapplied_overflow`, hiện **không có kho EXP dư tự động**. Không phát Luyện Thể XP trực tiếp từ quái nếu không có nguồn/cơ chế riêng được cho phép.
6. Mastery có **Sơ Học/Nhập Môn/Tiểu Thành/Đại Thành/Viên Mãn**, phải dựa hành động có hiệu quả: hit gây damage, heal thực, shield hấp thụ, buff hữu ích, debuff/control tác dụng. Chỉ skill đã học/đã thực sự dùng mới nhận mastery. Không spam cast rỗng, không đổi nguồn thành XP bằng animation.
7. **10 ô trang bị thường, 12 phẩm, 24 dòng bộ** (18 combat+6 nghề), mỗi bộ 4 món vị trí quy định, mốc **2/3/4**, cho phép **3+3**; ba Phù, hai Pháp Bảo nằm ngoài 10 ô, bốn vị trí consumable riêng. Trang bị thuộc tông môn; luật đồ bộ không tự tạo kỹ năng; tỷ lệ rơi/roll phẩm chưa được khóa.
8. **One Active Job**, đội <=6, Injury production **0/1/120 scheduler ticks**, không xóa đệ tử khi bị hạ; refund/credit/save exactly once, không camera/VFX/Source A ảnh hưởng gameplay. Một đồng hồ simulation, có kế hoạch offline nhưng không loot ước lượng tự sinh.
9. Sản xuất Mỏ/Linh Lâm/Linh Điền, profession/crafter/Y Quán và tiêu hao logistics **tiếp tục cần thiết**; săn không độc quyền mọi tài nguyên. Tốc độ sản xuất Economy V2 đã có quyết định riêng, không thay bằng công thức B3.

### B. IMPLEMENTED / ĐÃ XEM trực tiếp

- `main` có `HuntingMapV2.claim_reward` theo **WIN encounter**, 3 map 5 cấp thử nghiệm với `linh_tuy` bảo đảm từ số lần thắng; `SimulationScheduler` legacy `COMBAT→LOOT→pending_loot`, `EquipmentSystem.forge_loot_for_victory` theo species. Không được mở **hai** đường trả thưởng cho B3 kill.
- `EquipmentSystem` trên main: **3 slots** `weapon/armor/talisman`, **3 quality**, **5 recipes**, `craft()` synchronous; chưa phải 10/12/24 hoặc forge order có thời gian. `ResourceRegistry` canonical định nghĩa mã tài nguyên thật; `WarehouseSystem` có `MAX_SAFE_STACK` kỹ thuật và `available_quantity` xét lock/reserve **khi chi**.
- `DiscipleRealmProgressV2.grant_xp(disciple,track,amount,gain_type,floor_costs,...,dry_run)` hỗ trợ source bonus và chặn ở major realm. **Thiếu bảng floor_costs production có thẩm quyền hoặc logic tiêu thụ tương ứng sẽ fail-closed**, không tự đoán giá EXP.
- `CombatSkillSystem.record_combat_path_experience` trên main chỉ có **outcome finite** win/retreat/defeat và skills_used, không tương đương mastery theo mỗi hành động/world kill. Chưa nhận rằng mastery V2 đã chạy đầy đủ.
- B2.4 local `PerKillLootResolverV1` chỉ roll `resource_id` stackables từ `per_kill` table, chance dạng **basis points 0..10000**, số lượng min/max, private RNG; `KillReceiptLedgerV1` mới preflight/rollback **Warehouse resources**, chưa commit multi-channel Tu Vi/unique/Boss. Source test 100% `linh_moc` chỉ sandbox, tuyệt đối không lên production.
- Có `SpawnDirectorV1` slot/generation, `MapBattleV2.continuous_mode` opt-in ở local ZIP nhưng main chưa chứa; Source A Codex đang nghiên cứu full extraction, **không có yêu cầu dùng asset cụ thể từ nó ngay**.

### C. CẦN OWNER DUYỆT trước khi khóa gameplay

Phần thưởng cá nhân khi nhiều đội cùng Boss; có hay không bảo đảm mảnh/“pity” và giới hạn kỳ vọng; Boss refresh/contest; split Linh Thạch; dự luật CONTRIBUTION khi đồ hiếm được trả về Kho; “direct gear drop” so với material forge; đánh giá cấp đồ tự động; loot tables, chất lượng/affix; thời gian forge; XP basePct/rates; anti-leech cutoffs; xử lý offline backlog. Mọi bảng numeric trong file này ghi rõ FIXTURE, không tự thành nguồn cân bằng production.

## 1. Vòng lặp có ý nghĩa — 3 nhịp thưởng khác nhau

| Nhịp | Người chơi nhìn thấy điều gì? | Luật thiết kế |
|---|---|---|
| **Ngắn: mỗi quái** | Đệ tử đánh liên tục, Tu Vi nhỏ/skill mastery hợp lệ, vật liệu hoặc Linh Thạch vào kho, có lúc rơi đồ/fragment. | Không màn tổng kết, không cần click nhặt/Claim. Một kill=1 receipt provenance. Quái có thể rơi ít hoặc 0 theo table. |
| **Trung: mỗi phiên săn** | Thanh tiến triển tầng/công pháp/kỹ năng; món đồ/fragment đáng dùng; hồi phục và chuẩn bị vào vùng khó hơn; Kho tích lũy theo nhóm nguồn. | Không thưởng “win encounter”, không ngắt world. HuntSession là thống kê/view về một quãng săn, không là nguồn phát thưởng thứ hai. |
| **Dài: nhiều phiên/Boss** | Săn Boss/Elite đúng build; hoàn thành bộ/gear đặc trưng, bí kíp, cải thiện tông môn và cân nhắc đổi đội. | Rare chase không chỉ RNG mù; có nguồn nhắm đến, đường tiến triển chậm xác nhận được (nếu owner phê duyệt fragment/pity), chi phí thật. |

**Không áp đặt “cứ N con chắc chắn rơi trang bị cực phẩm”**. Nguồn một gear có thể là: **direct drop template** đã authored, **recipe/material + forge** hoặc **Boss-specific fragment/blueprint** khi có dữ liệu; phần lớn đồ thường đến từ nguồn hợp lý, không phải mọi vật phẩm đều Boss-only. Các nguồn này không được mint cùng một sự kiện nhiều lần trái bảng.

### Tính chất hiếm phải có mục tiêu, không biến thành slot machine trống

**Design proposal:** mỗi vật phẩm chờ săn hiển thị provenance: `source_type` (normal/elite/boss/zone), vùng, yêu cầu cảnh giới, trạng thái table chưa authored và đường thay thế (forge/fragment/tương đương). Khi không có source hợp lệ, UI hiện “chưa có nguồn”, không hứa Boss X chắc chắn rơi phẩm 12. Sự hiếm từ xác suất roll, yêu cầu vật liệu, sức mạnh Boss, thời gian hồi và đội hình; **không khoá tiến trình cơ bản sau xác suất hiếm cực thấp**. Source A chỉ cung cấp visual metadata, không được dùng tên rig để chứng nhận table.

## 2. Loot architecture: nhiều kênh trên cùng một death receipt

### 2.1 Domain event

```text
CombatV2WorldStep: MonsterInstance HP > 0 → <=0 (world,region,slot,generation)
  → immutable Killed domain event (real actor/participation evidence)
  → RewardEligibility (source,contentRev,tableRev,party/reward-policyRev)
  → deterministic independent RewardRoll once (NOT Combat V2 RNG)
  → immutable RewardEnvelope PENDING
  → atomic canonical settlement: all recipients or none
  → COMMITTED in SAME SaveService canonical snapshot
  → read-only LootNotice + UI VFX, no gameplay mutation
```

**One kill key** is `B3_WORLD_KILL/world_id/region_instance_id/slot_id/generation`. Boss with 2 teams has **one** kill key and one roll. Do not create per-team boss table rolls by default. A kill can have many personal reward entries under the same immutable envelope; no separate item roll per person unless an explicitly distinct authored source is introduced in future.

### 2.2 RewardEnvelopeV1 — proposed fields (single authoritative owner)

```yaml
receipt_id: B3_WORLD_KILL/world/region/slot/generation
world_step: int64
killed_monster_instance_id: world/region/slot/generation
source:
  monster_species_id: canonical
  monster_tier: normal|elite|boss
  monster_realm_rank: canonical
  spawn_def_revision: string
  content_revision: string
  loot_table_revision: string
  boss_content_id: optional
  reward_policy_revision: string
rng:
  reward_seed_domain: immutable independently derived from world seed + kill id
  result_hash: hash of immutable resolved payload
eligibility:
  participant_evidence_by_disciple: damage/heal/shield/support/tank/valid-time
  team_ids: canonical unique ids
  eligible_disciple_ids: sorted ids
sect_stacks: {canonical_resource_id: nonnegative_int}
sect_unique_items: [{instance_id,template_id,tier,quality,affixes,set_lineage,source_id}]
sect_manuals_or_fragments: {registered_id: count}
sect_spirit_stones: nonnegative_int
personal:
  disciple_id:
    cultivation_xp_proposed: nonnegative_float
    body_xp_proposed: 0 unless separately authorized
    mastery_deltas: {learned_skill_id: candidate_amount}
    path_xp: candidate_amount
    contribution: nonnegative_int
    personal_spirit_stones: nonnegative_int
    applied_xp: authoritative_after_preflight_amount
    blocked_overflow: reported_not_banked
receipt_state: PENDING|COMMITTED|BLOCKED
settlement_revision: integer
```

**Classification is illustrative:** an authored material/manual may be a registered stack instead of a unique registry entry; actual storage consumers decide. Do not mix `sect_spirit_stones` with `sect.treasury` legacy `money` or disciple `wallet` without explicit migration. Per-kill non-stackable equipment must receive deterministic globally unique item_instance_id (not `equip_%06d` collision against existing forge index).

**Atomicity**: stage all new Warehouse quantities, unique IDs, personal money/progression/skill EXP and receipt COMMITTED before mutating live state; validate with pure dry-run consumers where available; publish save barrier containing all values. If item/XP/currency invalid, fail whole envelope, keep same PENDING frozen result; **no partial loot and no reroll**. `SaveService` tmp/backup supports coherent snapshot but actual atomicity/power-loss fault tolerance must be measured, not claimed.

**Technical nuance on XP overflow:** `grant_xp` returns `gained` and `unapplied_overflow`; the earned offered amount, XP *actually applied*, discarded overflow and major gate must be separately tracked. Do not present `offered` as `applied`, do not silently deposit overflow in a hidden bank, do not trigger breakthrough by collecting Boss loot. If a pending receipt spans an unauthorized growth consumer, fail-closed per owner-approved transaction policy; do not skip the XP silently and still mark full grant.

**Data lineage**: freeze loot table content and reward policy revision at eligibility/roll time, including exact source IDs. A patch changing a drop table cannot reroll a PENDING receipt after save/restart.

### 2.3 Separate legacy modes

| Gameplay mode | Source and payout | B3 treatment |
|---|---|---|
| P2 scheduler hunt | COMBAT→LOOT personal pending loot, later deposit | Preserve untouched until explicit migration; cannot also pay B3 kills. |
| V2 finite Hunt Map | Claim reward once after encounter WIN, old 4-WIN guarantee for Linh Tủy | Preserve old save/claim records; **DO NOT translate “4 wins” into 4 individual kills**. |
| B2.4 sandbox | PerKillLootResolverV1 resource stacks only + cloned Warehouse | Reuse validated seed/receipt concepts, not test odds, not live Save/gear/XP. |
| B3 continuous production | Individual HP0 domain kill event + multi-channel atomic commit | Only active after versioned opt-in migration and real tables. |

**Loot_notice is not receipt**; UI may show per-kill/aggregate notifications, but player never presses Claim to make canonical Kho data valid. Unique item drop is stored in Sect registry, not a personal stash. Locked inventory rules prohibit spending reserved items, not depositing a legitimate kill reward.

## 3. Bảng nguồn đồ — thế giới mở rộng thay vì 3 vùng/5 recipes

**Design proposal content registry**:
- `MonsterDef`: species + valid tier/realm rank, skills/HP/element from Combat V2, drop-source refs.
- `LootTableDef`: table_id, version, source entity, channels, stack/unique/fragment source pools, quantity, rarity bands, authorized eligibility and RNG stream, uniqueness/exclusion rules.
- `ItemTemplateDef`: registry ID, item slot, source family, realm tier 1..30, grade eligibility 1..12, legal affix pools, set lineage/generation if any, level/equip restrictions, non-stackable instance rules.
- `BossSourceDef`: spawn/realm/risk/cooldown/loot family, normal/elite/boss distinction, phase/skill refs only when **implemented**.
- `Craft/ForgeRecipeDef`: registered inputs, crafter/profession/building + real duration, output slot/tier/grade policy; separate from drop rarity.
- `ProgressionSourceDef`: reward basis per valid enemy, actual participant window, condition/track/dry-run grant consumer, contribution + personal stones as defined policies.
- `EconomySourceSinkDef`: material sources (base/hunt), item service sinks and capability; never pseudo currency.

**No unapproved content:** B2.4 `schema_v2.json` presently supports spawn/loot stack drop table; unique gear/manual/mastery demands **separate schema versioning and focused validation** before production. ResourceRegistry currently verifies real stack IDs; unknown IDs fail closed. The five `EquipmentSystem.RECIPES` and legacy 3-region source are **fixtures**, not limits or valid product economy rates.

**Recommended sourcing:**
- Normal: stable sources for ordinary monster materials + lower-risk Tu Vi/mastery; some ordinary gear/skill manual sources IF authored; valuable to routine farming without Boss monopoly.
- Elite: harder but more distinctive materials/blueprints/rare-drop opportunities; no obligatory every-elite guarantee.
- Boss: high challenge + long-cycle targeted lineage/template/rare sources, possibly guaranteed useful floor or long-chase shard/pity **ONLY if owner approves**. No guaranteed Chí Tôn or high-grade set from generic boss.
- Base economy: crafted supplies, reliable construction/ore/wood/herbs, forge/support, medical recovery, work EXP. **Boss rewards cannot replace full Sect infrastructure**.
- Progression bands: 30 realm ranks ×10 clusters **future design projection**, each region or family must have authored unlock/loot/effective farming sources; early game must be viable with existing real sources and no missing-content dead ends.

## 4. Tu Vi, skill, Luyện Thể và hội nhập năng lực đệ tử

### 4.1 Canonical reward for Tu Vi

For disciple `i` and monster `m`:
```text
offered_cultivation_xp(i,m) =
  current_floor_requirement(i)
  × base_pct(source,tier,loot/progression revision)
  × realm_multiplier(monster_rank - disciple_rank)
  × grade_multiplier(normal/elite/boss)
  × challenge_multiplier(real fight difficulty vs eligible team)
  × participation_multiplier(valid actions/time)
```

The **formula and curve shape already exist** in the P3.7 spec. `base_pct` and final numeric curves are **NOT runtime approved**; do not select literal per-kill values without an authored cost table and time/kill throughput benchmark. Use stable monster `realm_rank` metadata, NOT textual “Kim Đan” exception strings or `combat_power` as Combat V2 damage authority.

Existing spec starting values (REFERENCE ONLY, not new proposal): relative rank -4→0.02, -3→0.05, -2→0.15, -1→0.45, equal 1.00, +1→1.35, +2→1.75, +3→2.20, >=+4 cap ~2.60–3.00. Grade normal1/elite3/boss10–15. Challenge appropriate ~1, overpowered below 1, dangerous somewhat above 1, with actual survival risk. **These are tuning hypotheses, not production rates.**

**Critical no double scaling:** relative multiplier + challenge + grade + participation can compound strongly. Benchmark **per-hour effective XP** (fight uptime / travel / injuries / recovery / respawn contention / waiting) and compare actual progression speed targets: workers roughly `0.04–0.06%` current requirement/hour vs healthy appropriate hunting `0.5–1.0%`/hour. Boss grants burst, not a repeatably optimal no-risk 24h XP pipeline. Don't apply each multiplier again separately on actual grant() result.

**Track integrity:** routine hunting awards **Tu Vi** when applicable, not direct **Luyện Thể** XP without separately registered source. Monster body material/technique may be a separate item source for dedicated Luyện Thể service; this is not free XP. Sync current floor/gate, no cross-major-realm auto breakthrough. Skill use/mastery cannot raise cultivation rank itself without authored consumer.

### 4.2 Stage-cap / major breakthrough

When an encounter kill awards XP at the 10th floor:
1. freeze offered XP and existing player stage requirement;
2. dry-run `DiscipleRealmProgressV2.grant_xp()` on valid `floor_costs`;
3. commit only actual persistent XP/floors with authoritative XP source, surface `unapplied_overflow` as **not banked**;
4. if major gate reached, UI shows available breakthrough path, NOT an automatic next realm; actual breakthrough uses the authorized separate consumer and materials/gates.
5. If the grant lacks `floor_costs` content, BLOCK settlement; never invent price table or paper over with old P2 fixed XP.

**Potential design question:** if one kill spans level-up, using `R_i` locked at kill-start or kill-resolution; propose **snapshot at moment of death** plus ordered reward resolution, not current stage retroactively changed on reload. The P3.7 rule says current stage, and exact timing must be frozen in integration packet.

### 4.3 Skill mastery and path XP must be event-based not spam

Only count meaningful real Combat V2 contributions:
- damage: applied HP damage to a legal nontrivial target, ignoring attacks into corpse/immune/no meaningful effect;
- heal: effective restored HP, not overheal;
- shield: actual absorbed damage, not repeated shield-cast spam;
- buffs/debuffs/control: validated influence on later legal combat effects when implemented; no invented debuff/DoT from skill labels;
- guard/tank: actual damage mitigated/absorbed or legitimate protection, not idle threat stat; active support can count without DPS;
- movement: documented tactical move to reach valid position; don't award mastery from perpetual patrol loops.
- passive static skill: only when learned and authored conditions/trigger or study consumer legitimate. No source from animation, GUI or VFX.

**Distinct ledgers:** `CombatActionContribution` (event-sourced, transient + deterministic, capped), `SkillMasteryCandidate` and `DiscipleHuntReward` (per death) have separate responsibility; **one receipt** should reference normalized committed contribution snapshot. Mastery from a skill action can be earned at action completion independently of kills only if it uses its **own stable action ID and exactly-once ledger**. **Do not accidentally grant mastery both per valid action and per subsequent kill**: choose exclusive consumer/credit authority per mastery category before CODE.

**Current implementation warning:** main `CombatSkillSystem.record_combat_path_experience` updates path XP from **encounter outcome** and skills_used; that is legacy and not sufficient to count valid per-kill performance. B3 must retain mode separation/migration, not call legacy function once **per monster** or inflate path XP.

### 4.4 Personal rewards and anti-leech

Use **meaningful contribution evidence** from Combat V2:
- damage dealt / real HP reduced;
- valid tank/guard/protection, damage absorbed;
- effective heal/shield on engaged ally;
- applied debuff/control and its real effect; buffs on participants;
- relative active combat time/eligibility at source target; no infinite passive proximity.
**Participation range in the P3.7 design:** meaningful ~0.8–1.0, low ~0.4–0.7, essentially carried lower; this is balancing reference, not required thresholds. A six-person party must not multiply the sect's material drop by six or grant 100% progression to an AFK teammate.

**Proposed fairness rule:** distinct `eligible_participants` have channel-specific participation for XP/Contribution and spirit stones; don't use last hit alone, and don't ignore healer/tank. A disciple who died earlier may earn proportionate credit for meaningful pre-death contribution if eligible, but never continues earning after HP0. A non-engaged passerby sees Boss death but doesn't get personal payout. Deterministic tie-break + time window prevents tagging at 1 HP as full credit. Exact contribution thresholds, final XP distribution, share vs independent XP per participant are OPEN.

### 4.5 Progression breadth

Separate existing V2 axes (do not invent a catch-all character Level):
- Tu Vi (30×10);
- Luyện Thể (30×10 from dedicated legal sources);
- mastery per **learned** skill (5 named stages);
- pathway/technique mastery from legal authored actions;
- Contribution (personal Sect service currency, never decays passively);
- personal Spirit Stones (legal Sect policy split);
- profession EXP earned from real valid hunt/exploration tasks **when consumer exists**;
- sect-owned assigned equipment, set thresholds, manual/Pháp Bảo/talisman acquisition.
**Stable personal story**: per-disciple hunt history and notable Boss support stats/achievements are **view/telemetry**; they do not mint game rewards without authored sources.

## 5. Boss — sự kiện đáng săn, không phải “quái to + nhân rơi đồ”

### 5.1 Four Boss roles (DESIGN taxonomy)

1. **Elite local encounter**: rare/harder normal-region target, repeatable source with useful uncommon materials.
2. **Regional Boss**: real spawn point, team risk/respawn window, first meaningful set/blueprint chase.
3. **Special/rare Boss**: source-specific access/rare opportunity/content authored; no arbitrary spawn timers.
4. **Future challenge Boss**: long-term realm/generation gated content, may introduce new V2 skill if authored separately. **No assumption these four tiers are implemented today**; current runtime has normal/elite/boss only.

Boss experiences should differ via **known authored V2 skills/risk, telegraph, region ecology, material/loot families, recovery cost and scheduling**, not a secretly invented second damage formula or hard-coded guarantee.

### 5.2 Co-op Boss / two teams: one enemy, one Sect payout, multiple legitimate personal gains

**Proposed minimum eligibility contract:**
- **One BossInstance** identified by world/slot/generation; only one HP/skill state. Teams A/B can attack this actor in one world.
- Damage/cast/defense/status stack caps are global per Boss (not per-team copied); party-only buffs/heal remain within proper party unless authored wider scope.
- Boss death creates one `BossKillEnvelope` using a standard `B3_WORLD_KILL` receipt, not a bonus separate loot claim per team.
- Sect stackables, unique gear, manuals, fragments, and sect Spirit Stones roll **once**; then append personal credits for eligible contributors, no team duplication of source.
- Determine personal participants by actual Combat V2 events (damage, tanked hits, effective heal/shields/support, time), freeze evidence at death.
- **Do not define “last hit owns Boss” by default.** It ignores heal/tank and can reward leeches. Team leader can influence credit **only if** an explicit Sect policy says so (default simpler equal-after-sect-cut from spec).
- If one team withdraws while another continues, prior meaningful contribution may remain eligible **within an approved participation window**; exhausted/wiped teams never auto-claim separate win.
- Two teams competing for same Boss/last hit cannot cause double loot. Sect owner is one tông môn; if different Sects/PvP eventually exist, **out of current scope**.

**Suggested personal Stone split algorithm (not locked):** take authored `gross_stones`; transfer an approved Sect share once; among eligible disciples use **equal share** initially, deterministic rounding remainder ordered by ID; optional weighted participation/leader bonus only after gameplay feedback. No mixing personal `wallet` and `personal_spirit_stones` until migration.

**Boss control policies:** ALLOW_WHEN_SAFE/NEVER/OWNER_TARGET according to Team AI; actual risk gate still mandatory; Boss may have respawn countdown, but players should see source and readiness rather than farm a dead location forever. Aggro/leash/reset policy unresolved; abandoning combat cannot cash out a “partial defeat reward” without authored source. Boss spawn/loot rate, personal participation window, pity, token source and multi-team loot eligibility **OPEN**.

### 5.3 Boss reset exploit and other abuse cases

- **Pull-reset farming**: cannot force Boss to heal/reset and repeatedly award on HP thresholds because `Killed` requires single HP>0→0 per generation. A boss that returns home is **same generation**, no reward.
- **Tag-leech:** one tiny hit is not automatically full Boss XP/rare item; participation proof needed. Supplying without meaningful combat contribution no reward.
- **Heal spam**: healing a full-HP ally gives zero effective heal contribution.
- **Infinite shield/buff**: credit only when actual effect useful and bounded.
- **Retreat and re-enter**: no fresh once-per-kill enrollment or redraw of Boss random reward while same generation alive.
- **Kiting**: player may move without physical walls, but no safe infinite free damage exploit from leash/untouchable reset; precise leash/return rule pending separate signoff.
- **Offline Boss farm**: credit only when real authorized world combat is advanced; if app closed and world backlog pending, do not simulate free Boss catches by multiplying elapsed minutes.
- **Death/cast race**: projectile targeting generation12 must not damage generation13; high damage AoE hitting two separate monsters gives two receipts, same boss receives one.
- **Lag/close/save mid kill**: avoid reroll; pending receipts and state committed as one snapshot; fail closed if invalid.
- **Farm bosses with a max disciple doing all damage**: scale XP/participation for carried low-tier allies per actual P3.7 relative challenge, no full XP from idle party membership.

## 6. Đồ hiếm, phẩm chất, bộ, Chân Văn — không phá đồ đã khóa

### 6.1 Equip source and legality

Every instance has **unique identity + registered item template + realm tier + quality + legal stat lines + optional set lineage/generation + source receipt ID**. Quality 1..12, affix capacity as locked in Equipment spec (Chí Tôn 6 ordinary, 2 rare stat-special, optional **individual Chân Văn slot**). A rare-stat affix must not create its own attack/skill; Chân Văn is separate. Nothing in Boss loot automatically grants Chân Văn Cộng Hưởng.

**6 eligible set positions** Mũ/Giáp/Phi Phong/Hộ Uyển/Đai Lưng/Giày; four piece templates/lineage, thresholds 2+3+4 cumulative; **3+3 legitimate** (both 2+3). The 10 ordinary slots are not the “old five+Phù+Pháp Bảo”; no false visual equip done to satisfy this count. A drop cannot be assigned to a slot whose V2 legality has no true stat consumer, or silently convert old `owner_id` to personal property.

### 6.2 Different acquisition routes (proposal, content-authorable)

- Direct ordinary gear drops: show source, tier and role; reasonable early progression.
- Elite/Boss-specific item drops: allow targeted pursuit of selected lineage/slot/rare material; not guaranteed quality 12, not Boss-only path to all regular gear.
- Forge: real `ForgeOrder` through Luyện Khí Điện, canonical Warehouse materials and profession/building level, timed output owned by Sect. Current `EquipmentSystem.craft()` sync is only legacy.
- Manuals/fragments: new unlocks sent to Tàng Kinh Các/Sect catalogue according to canonical skill spec; first full archived source should unlock transmission without consuming a copy per disciple when system actually built.
- Duplicate item management: equip squad B, reserve for future 2/3/4 set, salvage/trade **only with explicit policy and implemented consumer**, never auto-salvage unique/high-tier just because individually lower score.
- Autoequip per role/team examines **total legal loadout and sets**, player slot locks, equipped_by and prospective group upgrade; staged assignment protects completed 4-set from opportunistic single-stat replacements.

### 6.3 Honest rarity and anti-frustration (proposed options, not locking pity)

A rare chase loop should provide intermediate progress, not just 1-in-huge random roll. Three designs for OWNER COMPARISON:
1. **Pure random rare roll**: simplest/most exciting; risk long dry streak and inflated hours.
2. **Fragment progression**: Boss drops a registered fragment on some authored schedules/loot table; recipe reconstructs legal item. Needs real fragment consumer, no universal token or guaranteed fabricated pieces.
3. **Pity/accounting guarantee**: after qualified kills target reward becomes more likely or guaranteed; must use **per-source** canonical counter and preserve across save/offline. Existing Linh Tủy guarantee every 4 *encounter wins* cannot be transplanted into per-kill Boss world.
**Recommendation:** mix 1+2 **when source/forge supports it**, not universal pity across 30×10. Pity only for one specific author-approved item/source when its economy simulation supports it. Do not invent final drop rates in documentation.

A good Boss reward can be a useful specific material, recipe, set piece, unlock and unique rarity roll; rarity should be meaningful without 12th-grade inflation. There should be transparent source provenance in the UI and lower-risk economic fallback.

## 7. Economy integration & sink/source budget

### 7.1 Economy consistency

- Farm: hunt produces realm-scaled monster materials/rare collectibles + progress/stones **when sourced**; base buildings produce stable wood/ore/herbs/medicine/forge output. Do not auto-turn every monster species into construction wood, and don't substitute all fields with beast drops.
- Character progression increases ability to farm harder sources, but extra monster power also raises medicine and recovery cost. No mystical noncanonical `phẩm lực` meter or second wallet.
- Currency: distinguish **Sect Spirit Stones**, **personal Spirit Stones** and legacy numeric `money/wallet/treasury` until explicit migration. No double tax/cut from share.
- Contribution: per valid kill service + possibly **additional registered loot-value service** (spec already allows), but each uses one receipt once. Same rare item should not grant contribution again on every reassignment, equipment lock, inventory view or return to Sect.
- Resource reserve/lock applies to **spending/crafting/auto allocation**, not to receiving legitimately earned stacks. `MAX_SAFE_STACK` is numerical safety guard, not player warehouse capacity.
- No paid entry fee for ordinary hunting; legitimate travel, medicine, stamina, injury downtime and future approved durability are costs. Consumable spending itself must be idempotent by action/source ID.

### 7.2 Economy balance must be empirical

For each region/tier/team/realm:
```text
Real hunting uptime = total simulated hours - travel - safe waiting - recovery - defeated/injured downtime
Kills/hour = actual authorized kills / total simulated hours
TuVi/hour = sum(applied_v2_xp) / current-stage cost / total simulated hours
Net common material/hour = legit stack additions - recipe/medical/repair use
Unique item/hour = committed real unique drops only
Boss meaningful rewards/hour = actual credited eligible kills with cooldown/source limits
```

Compare with worker output at Economy V2 values and promised ~10–20× TuVi speed after costs; run statistical trials seeded consistently and track **p50/p90/p95** hours to first useful upgrade and longer-tail dry spells for rare targets (not inferred from 1-minute synthetic sandbox). Budget target specifics **not signed**; never claim PASS without actual simulation.

Anti-inflation/anti-stagnation tests:
- normal-farming cannot replace all Mỏ/Linh Lâm/Linh Điền sources;
- highest-rate Boss must not be trivial immortal boss farm by strong 6-person party;
- no dead end if Boss source unavailable or low-difficulty farm yields zero prerequisites;
- material sinks scale with gear/medicine/forge, without hard farm cap or punitive slot limits;
- rare duplicate still valuable through multi-disciple assignment (1k–3k scale), not endless duplicate trash;
- Chưởng Môn sees reason for blocked item recipe, missing source and recommended realistic next target.

## 8. Giao diện điều hành Chưởng Môn — ít thao tác, nhiều quyết định thật

**Săn Yêu Điện overview proposal:**
1. **Teams**: farm mode, region, risk policy, current action/return condition, injuries, actor count, earnings/progress this expedition.
2. **Farming targets**: desired material/slot/set/manual; shows **verified source**, normal/elite/boss, expected uncertainty (if truly authored), quantity available vs reserved, no fake ETA from unapproved probabilities.
3. **Disciple progress**: actual % of current floor, blocked at breakthrough, skill mastery list, Contribution and individual Stone earned from receipts; no phantom growth if stage pricing not ready.
4. **Loot feed**: concise aggregation of ordinary stacks; specific notifications for rare unique gear/recipe/first Boss kill, item link to canonical Sect inventory; read-only.
5. **Boss board**: known boss sources, available/unavailable with accurate cause, recommended realm/risk and participating teams; no fabricated “respawn in 15m” without real schedule.
6. **Gear distribution**: Sect inventory, reserve/lock, assign best-fit to teams without corrupting 3+3 or 4-piece; manual override.
7. **Audit detail**: on-demand kill_id/source/table version/receipt apply/eligible participants for debugging—not cluttering base UX.

Three-step owner experience: **giao đội → nhìn họ tự săn và tiến triển → quyết định đổi vùng hoặc dành đồ/đánh Boss**. No modal Claim per monster, no 30,000 item manual clicks.

## 9. Scenario examples — fixtures ONLY (no unapproved live drop rates)

### S1 — Normal hunt useful without Boss
A legal five-member team in a starter wood/monster region engages 3 normal mobs. Two mobs die at distinct timestamps; each produces an immutable `kill_id`, TuVi and material only if registered content. Different disciples' XP depends on rank/participation and real action. One hunter below retreat HP returns; remaining members may continue per policy. Region spawn slots regenerate individually. Sect Warehouse immediate credit; no visual Pickup mutation, no wave WIN.

### S2 — Rank mismatch
Cultivation disciple with rank 12 kills monster rank 6 while being overpowered: same item source rules MAY give legal low-level materials but **Tu Vi multiplier sharply reduced** (reference -4 or lower ~0.02). Prevents cheap weak-mob power levelling; content/drop chance is independent and not globally “0 loot if weak”.

### S3 — Boss co-op and healer fairness
Team A has frontline/healer/DPS, team B joins. One Boss HP, boss AOE/cooldown real. Combat event snapshot: healer restored real HP, tank legitimately absorbed, DPS dealt damage; both teams’ contributors can be credited based on approved eligibility; bystander not. Boss down → **one Sect gear-or-material roll**, one committed receipt, normal personal reward distribution. If member changed teams midfight, contribution linked to persistent disciple ID and time, not whichever party UI currently shows.

### S4 — Loot gear slot and completed set
Boss source legitimately yields unique helmet from lineage Sát Tinh of valid tier. Item enters Sect registry; player lock holds it for a future 3/3 build or assigns to legal wearer. AI cannot break an existing completed Hộ Sơn 4-set just because isolated helmet has +1% Attack. Direct drop independent of Source A outfit/skin availability.

### S5 — Floor-10 cap
A disciple floor 10 obtains a large Boss cultivation award. `grant_xp()` only applies up to legal floor gate; excess returned as unapplied, **not saved as secret overflow bank** and **not force realm 11**. Visible UI shows “đã đạt giới hạn tầng / cần đột phá”, with offered/applied distinction. Reward receipt protects exactly-once even though some XP could not be applied.

### S6 — Boss retreat exploit
Boss still alive, Team A leaves while Team B continues; the Boss is not declared dead or respawned, no reward. If Boss returns home due leash, world rule may recover HP only under authorized policy; receipt unchanged. If actual HP0 later, one kill and one reward, regardless of number of attempts.

### S7 — Crash midway through mixed reward
Combat lethal already saved? Save attempt fails while stack+unique+personal XP are staged. Restart from previous coherent snapshot, replay deterministic time/kill or retry immutable PENDING with same payload. No combination “resource twice, XP once”, no duplicate unique IDs, no random item affix reroll.

### S8 — Skill spam and fake assists
Healer casts on full HP, another caster buffs an unengaged ally, boss is tagged at 1 HP. None automatically produce full mastery/participation. Real effective healing/damage/actual group support earns credit according to signed eligibility, not per-animation or per-click.

### S9 — Content revision and source mutation
A loot table changes while a PENDING Boss kill receipt remains. Frozen `table_revision` and original result must be committed, not re-rolled with new chance. An unsupported source blocks with reason, no hidden 100%-wood fallback. Unknown item IDs cannot enter Warehouse via JSON hack.

### S10 — Offline bounded catch-up
A long offline duration on low-RAM phone should not mint “X Boss kills/hour”. The single world clock processes legal events with a bounded backlog, queues unpaid time accurately, preserves 120-scheduler-tick Injury and prevents second actor job. When resumed, UI shows resolved **actual** loot/growth only, not hypothetical projection as claimable rewards.

## 10. Open decisions ranked by impact — proposed answers, NOT new locks

| ID | Open choice | Recommendation | Must verify |
|---|---|---|---|
| O1 | Boss personal credit across teams | Meaningful participation including tank/heal, not last hit; sect loot once | Anti-leech/ledger test and fairness scenarios |
| O2 | Spirit Stone policy | Sect cut once, equal eligible personal share V1 with deterministic remainder; optional later weighting | Does canonical V2 wallet/source exist? |
| O3 | Hunt TuVi numeric `base_pct` | Calibrate against 0.5–1% stage/hour and 10–20× work, using real fight/respawn/injury | Floor-cost authority/monsters per hour |
| O4 | Equipment target drops | Both direct and forge, plus Boss-targeted material/manual/fragment where authored | Actual 10/12/24 consumers and rate economy |
| O5 | Guarantee/pity | No universal pity; evaluate source-specific fragment path first | p90/p95 dry-streak simulation |
| O6 | Party members earn XP when not attacking | Require actual bounded meaningful participation/support; don't reject real healer | CombatV2 event evidence availability |
| O7 | Full ten-floor and breakthrough cap | Keep `unapplied_overflow` semantics; no hidden bank | Test apply versus offered |
| O8 | Boss split if 2+ teams participate | Single loot pool; any personal split policy freezes at kill | Stable teams and target counters |
| O9 | Offline long fights | Deterministic event processing with backlog if CPU cap, no estimates | Online/offline/save seeded parity |
| O10 | Salvage/autoassignment | Respect locks/2-3-4 and item ownership; don't force salvage | Unique registry migration and legal consumers |
| O11 | Noncombat contributions | Skill consumers only; support credit if real action performed | Debuff/shield/control not yet implemented |
| O12 | Source A art | IDs and manifests only; never RNG/loot from rig metadata | Codex Source A deliverable not yet available |

## 11. API shape — typed design only

```text
resolve_kill_eligibility(world, monster_instance_id, combat_evidence, source_revision)
  -> EligibilitySnapshot | BLOCKED

make_immutable_reward_envelope(kill_id, eligibility, loot_table_revision, rng_domain)
  -> RewardEnvelope(PENDING, rolled_once) | BLOCKED

validate_reward_grants(envelope, SimulationState, registries, canonical_progression)
  -> GrantPlan(canonical consumer dry-run results) | BLOCKED_WITH_REASON

commit_reward_envelope_once(grant_plan, canonical_state)
  -> COMMITTED(receipt_id, actual_gains, unapplied_overflow) | RETRY_PENDING

get_loot_source_catalog(sector, target_id) -> ReadOnlySourceTable
get_boss_progress(board_id) -> ReadOnlyCanonicalBossStatus
get_disciple_hunting_progress(disciple_id, tick_window) -> ReadOnlyProgressView
get_gear_allocation_options(item_id, sect_locks, current_loadouts) -> ReadOnlyOptionList

plan_boss_share_once(kill_id, eligible_participants, sect_cut_policy_rev)
  -> FrozenPersonalAwardMap (one source roll, deterministic rounding)

measure_hunt_economy(seeded_fixture, real_world_ticks, budget)
  -> p50/p90/p95 results without mutation of user save
```

**Only one code owner executes reward commits** after explicitly authorized migration. UI only projects already committed state and issues player intent; no loot grants from receipt preview, no duplicate settlement on auto resume, no second Combat RNG.

## 12. Code packets — not authorized; integrate in order with Source A separate

| Packet | Goal / tangible acceptance | Blockers / authority |
|---|---|---|
| **BLP-D0 (THIS SPEC)** | Decisions/formulas/architecture/fixtures; distinguish locked and proposal | Design only, no runtime tests |
| **BLP-C0 CONTENT SOURCE AUDIT** | Map every existing normal/Elite/Boss and stack resource into valid table/registration; item+personal channel consumers feasibility; fixture budget | Can be READ-ONLY before CODE, no new rate |
| **BLP-C1 KILL ENVELOPE FOUNDATION** | Extend B2.4 resource-only receipt to immutable typed mixed channels and one kill source; test deterministic ID/RNG and PENDING replay **without production payout** | Requires world HP0 event/W1/W2, exact allowlist and integration writer |
| **BLP-C2 CANONICAL REWARD TRANSACTION** | Real warehouse+unique+personal money/XP/mastery staged atomic commit, SaveService migration, no double settle in fault tests | Canonical `SectState`/item/progression APIs & floor costs; no fake source; one shared-file writer |
| **BLP-C3 REAL BASIC CONTENT** | One verified normal species/zone material, actual valid reward source; appropriate TuVi per-hour smoke; no legacy claim overlap | Separate owner signoff for table/rates and real actor content |
| **BLP-C4 BOSS MULTI-TEAM / PARTICIPATION** | Real boss one HP, one loot roll, role-aware personal credit and state persistence, risk/return and anti-leech | Boss credit O1/O2/O6/O8 must be approved, Combat V2 evidence for support |
| **BLP-C5 RARE CHASE + CRAFT/Gear** | Authored unique gear source/fragment/manual plus legal 10/12/24 allocation or ForgeOrder; first real consumable source/sink; no phantom Chân Văn | Item V2 migration, forge roadmap order1, Source A visual bridge later |
| **BLP-C6 BALANCE & OFFLINE** | Seeded p50/p90/p95 item chase & effective XP, true offline parity and supply economics, Android/8GB performance | Whole B3 single clock and tested Save/Workforce flow |
| **BLP-C7 PRESENTATION HANDOFF** | Real loot source UX and HUD states projected by V5/Map/Character Studio; never gameplay authority | After Source A/visual owners deliver verified manifests; no overlap |

**Do not code an all-in-one boss/loot/character patch.** Sequence: one real immutable kill → one valid material reward save → one honest Tu Vi award at a real floor cost → one real boss/gear source → split and balance. No 100% sandbox `linh_moc` promoted by default.

### Focused test matrix to authorize for future implementation

- `BLP-T01`: same boss generation killed by two simultaneous teams => ONE kill ID, ONE Sect loot roll, personal eligible deterministic, no 2×.
- `BLP-T02`: DPS/tank/healer/support legitimate; silent bystander 0; downed participant only credits before HP0.
- `BLP-T03`: fake overheal/recast infinite/late tag cannot increase mastery indefinitely or full Boss XP.
- `BLP-T04`: normal/elite/boss authored table valid; missing content blocked, no guessed rare drop.
- `BLP-T05`: floor requirement basis, realm gap/challenge/grade/participation, no repeated multiplication, effective XP/hour target.
- `BLP-T06`: rank 30 floor 10/major gate, no realm bypass, offered vs applied/overflow and missing floor_costs fail-closed.
- `BLP-T07`: cultivation XP and mastery are distinct; current encounter win path cannot also pay same world kill.
- `BLP-T08`: unique item ID collision/invalid slot/quality/set generation => all-channel rollback.
- `BLP-T09`: Sect money/personal Stone partition, deterministic remainder, no legacy wallet double-write.
- `BLP-T10`: lock/reserve prevent spending, not legitimate loot receipt, warehouse integer overflow fail all.
- `BLP-T11`: save mid-Killed/mid-PENDING/mid-COMMITTED, corrupted tmp/bak, same identity upon replay.
- `BLP-T12`: future table version change leaves PENDING roll unchanged, no retroactive grant.
- `BLP-T13`: 2/3/4 and 3+3 set preserving; auto-equip respects manual lock, no auto salvage protected.
- `BLP-T14`: difference between 4 encounter wins legacy guarantee and 4 individual B3 kills, independent records.
- `BLP-T15`: one world >90s and >1h, several respawns/rare drops, no wave reset or UI death-queue lost receipt.
- `BLP-T16`: online/offline/look-away equal real committed rewards, no unauthorized estimated offline drop.
- `BLP-T17`: no Boss item data but Boss appears; truthful no table/error rather than item minted.
- `BLP-T18`: 1000+ disciples, multiple teams, supply+production jobs protected, fair sparse event processing.
- `BLP-T19`: cached reward nonce/seed count correct on duplicate kill event; no duplicate unique affix reroll.
- `BLP-T20`: visual unique loot notice events can be dropped without losing canonical item.
- `BLP-T21`: stage advancement between two sequential simultaneous kills follows frozen sorted event order, never replays different XP after save.

**Tests above are specified, NOT RUN, NOT PASS**. Godot official 4.7.2 focused + cumulative gates and source-specific QA only after authorized scoped code.

## 13. Handoff and decision summary

**Recommended design default for owner to review:**
- Farming normal mobs produces useful economy + valid small personal progression.
- Elite/Boss are **targeted chase**, not paywall to baseline playable growth; normal and production remain meaningful.
- One Boss kill → **one sect loot pool**, every meaningful eligible participant may gain personal progression; default personal Stones split equal after sect cut, but actual policy/rates remain OPEN.
- **A locked or reserved item belongs to Sect**; assignments are reversible; 10/12/24 and full 3+3 preserved.
- Stage/realm gates never bypassed; XP offered/applied and blocked overflow visibly distinguished.
- Source A is asset pipeline, not drop table/gameplay math.
- **Avoid designing dozens of unsourced item IDs or numeric drop rates now**. Next design checkpoint should be exact **Boss participation & personal payout policy** + one real content fixture with actual `ResourceRegistry` IDs, following owner approval.

**This document expands B3 V2 DESIGN but does not authorize implementation, migrations, rebalancing, merges or Source A changes.**
