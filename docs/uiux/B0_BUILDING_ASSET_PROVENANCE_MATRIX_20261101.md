# B0 — Source A building asset provenance matrix

Status: **B0 read-only audit complete; candidate assets are not approved for runtime or release.**  
Audit date: 2026-11-01. No Godot process, asset import, runtime edit, or merge was performed for this document.

## Evidence boundary

| Evidence | Exact revision / identifier | What it proves |
| --- | --- | --- |
| Game docs branch base | `docs/dual-codex-sourcea-uiux-audit-20261101` @ `9ce65f6239d8d8659a9daa50c5ea338c7fd02ac7` | Packet/AGENTS instructions read; branch had no later commits when checked. |
| Game RC | `rc/one-game-playable-20261101` @ `970af33b23076c80d677cf5898a721a27504708f` | Candidate manifest and current presentation baseline. |
| PR #64 | head `bf3ed0310899c554eea4e6b2e1967dcada2d68dd`, open, draft, not merged | DD09.2 Hall/Residence UI and site values reviewed as a separate candidate. |
| Source catalog | `vuanhtuan161094-byte/ZQZS-Source-Knowledge` @ `83cbc4ecbd83eb518a6d6f2b3894377d9d99254d` | Source catalog claims and file hashes below. |
| Building index blob | `6a95a7160fe84b7bb82f1434890e4e6b15a05249` | CSV manifest for model/config/dependency provenance. |
| Game candidate manifest blob | `a51a767a10cae72a713bc9f190c3af828f43c0cd` | 13 candidate logical IDs, candidate flags, sizes/hashes, rights and import status. |

The source catalog itself did **not** prove that its `E:\GameAssetExtract` paths existed. A read-only local check on that source tree found the configured catalog file, all 13 referenced bundles, and every candidate dependency at the catalog paths. All 75 referenced file instances (49 dependency entries + 13 bundle entries + the shared config path checked once per candidate) matched the catalog SHA-256. The count includes duplicate model/shared-texture records; it is not 75 unique assets. This verifies local availability and byte parity only. It does not verify ownership/licensing, runtime import, pivots, animation, or visual correctness in Godot.

The common config SHA-256 is `51966a724c427030e8a4e8b80bf16e68ec9aa7d74a7a2e179a9ebc6feddb9ae1`. The two source CSV/JSON catalogs have rights label **A_USER_AUTHORIZED_LAB; verify redistribution scope before shipping**. The game manifest sets `binary_transport=NOT_APPROVED`, `runtime_asset_import=NONE`, `release_policy=INTERNAL_LAB_ONLY_UNTIL_RIGHTS_VERIFIED`; every row remains `CANDIDATE_NOT_APPROVED`, `binary_imported=false`, `runtime_resource_path=""`, and `release_rights=UNVERIFIED`.

## All 13 building candidates

Footprint and door values below are source config data, not a decision to use those values for the game's fixed-site plots. Dimensions were read from the local PNGs; only the three priority examples were visually inspected in this B0. “lum” is a separate light/footprint image where listed. Atlas plus skeleton dependencies are Spine source inputs, not a Godot-ready animated scene.

| Source logical ID | Config / model | Catalog evidence | Source footprint / door | Primary image canvas | Provenance note |
| --- | ---: | --- | --- | --- | --- |
| `building.main_hall` | 1 / 510052 | VERIFIED | 7×5 / 3, -1 | 1104×740 (lum 331×222) | `1514397bfbedb412500e1472546938dc237d37e2fee907e967d2c59874246174` | Đại Điện / timber hall; PNG visually inspected; alpha present. |
| `building.disciple_residence` | 15 / 510076 | VERIFIED | 3×3 / 1, -1 | 536×416 (lum 536×416) | `51a14d00c90a9899c58ff2cc42e1e6962b66dca9605533c100d90c9c27244576` | Đệ Tử Xá / two-storey residence with yard; PNG visually inspected; alpha present. |
| `building.cultivation_area` | 36 / 510191 | INFERRED_VISUAL_ANALOG | 3×3 / 1, -1 | 604×604 (lum 181×181) | `5f90f4cd6da5eeba0b607d48d83cc0ef06a343b7982dac0c74c645ee345862f7` | Cultivation visual analog; candidate is inferred, not identity-confirmed. |
| `building.body_training` | 38 / 510232 | INFERRED_VISUAL_ANALOG | 1×1 / 1, -1 | 204×92 shared `cuizhi` texture; no lum recorded | `be932a7c2916a599c02ef400206f4096243f7fbb4073df5eba6e024c735fe80f` | Uses shared `cuizhi` texture; no distinct body-training image proven. |
| `building.warehouse` | 14 / 510102 | VERIFIED | 3×2 / 1, -1 | 420×380 (lum 126×114) | `4648bb55e2159ea17d62a7b20fc785153b23654e339758652a79864c2991c774` | Warehouse; repo candidate PNG exists, not production-approved. |
| `building.forge` | 7 / 520081 | VERIFIED | 3×3 / 1, -1 | 548×560 (lum 164×168) | `266e8b2887ed106ea4817c07e4661234b787f36af6cfa40d46c826e268f8d772` | Forge; repo candidate PNG exists, not production-approved. |
| `building.medicine_hall` | 6 / 520031 | INFERRED_VISUAL_ANALOG | 3×3 / 1, -1 | 464×584 (lum 139×175) | `2748a13a980f426ab65c69831a0e642e8902613ec18dfe13d756dc57bea61bee` | Medicine-hall identity is inferred; model 520031 is also alchemy art. |
| `building.mine` | 4 / 520051 | VERIFIED | 3×3 / 1, -1 | 596×512 (lum 179×154) | `f729b0e55873b4abec7f2bef04d7ebf3ab51af2b21cbb05929b09cb20d0d352d` | Mine; source candidate. |
| `building.spirit_field` | 2 / 520091 | VERIFIED | 2×2 / 0, -1 | 368×192; no lum recorded | `9a62169bbcf0970f5e1294e7a41b6d60e6192cf95d9a1a7ef3e1d022cb3bc015` | Spirit Field; source candidate. |
| `building.linh_forest` | 3 / 520101 | VERIFIED | 2×2 / 0, -1 | 348×184 (lum 104×55) | `70da37aa374eb2397280a5dfd3f225ac274616bf77aeb9acc42c3c035b319976` | Forest; source candidate. |
| `building.alchemy_hall` | 6 / 520031 | VERIFIED | 3×3 / 1, -1 | 464×584 (lum 139×175) | `2748a13a980f426ab65c69831a0e642e8902613ec18dfe13d756dc57bea61bee` | Alchemy; model 520031 shared with inferred medicine hall. |
| `building.guidance_platform` | 22 / 510111 | VERIFIED | 3×3 / 1, -1 | 532×592 (lum 160×178) | `f5f9ff9089f5a944da16c257f216ed9a16563fae118a69d1bad6a5731619958e` | Dẫn Tiên Đài / mint spirit gate; PNG visually inspected; alpha present. |
| `building.sect_gate` | 39 / 510163 | VERIFIED | 1×1 / 1, -1 | 204×92 shared `cuizhi` texture; no lum recorded | `7fa21d27c5bf9d69dc77bcecc4704cb827d401961701d7fb8a912d16608b7a0e` | Uses shared `cuizhi` texture; gate-specific appearance is not established. |

### Dependency SHA-256 inventory

Each row below is the selected model's Source A dependency as recorded in the candidate manifest. Paths resolve under `E:\GameAssetExtract`; config and bundle roots are identified above. Repeated hashes are intentionally repeated for shared models/textures.

| Logical ID | Dependency file | Bytes | SHA-256 |
| --- | --- | ---: | --- |
| `building.main_hall` | `510052_lum.png` | 20042 | `db8a49b339afd8d93e5cbf8477a7b8d3e3d3bae12014e78b3bacd241de94c8ed` |
| `building.main_hall` | `510052.png` | 596816 | `b6bf88c35e3edc33aba822124296af15a5c8491a05c28f6b5d7b342d20d5325c` |
| `building.main_hall` | `510052.atlas` | 176 | `69dc956d8ee7bed005c31a2e1120abc17a9fdd901c4f81f6481d2a921acf31cd` |
| `building.main_hall` | `510052.skel` | 430 | `9e400ab40c6c3272bd862dbff81b5865b5c02aa133f7aa6d712aa8b2851fab73` |
| `building.disciple_residence` | `510076_lum.png` | 50464 | `5dd6fc0559196397779751c5d8bfe543130dde10ebf088984d2e4dfac4fe5bbb` |
| `building.disciple_residence` | `510076.png` | 200514 | `f8e05d7376fc5ddc7b25f56673b6d5f444b10fd759da06a5929ec4f38a68d320` |
| `building.disciple_residence` | `510076.atlas` | 173 | `97371a65bf06f117ccaf18d94b6842366d257537722d5fecaeb478bac6912ae3` |
| `building.disciple_residence` | `510076.skel` | 413 | `242872479f236ad49650f78482f2f20aa3f122bb0f37244c329f27aab5ab55f8` |
| `building.cultivation_area` | `510191.atlas` | 173 | `dd26ab88f80281586e549c5b17633e43ad27759c1946ac98969ca423ec2cdca1` |
| `building.cultivation_area` | `510191.png` | 401672 | `e4cb28de95596bd153990cf8492633992098f12c9f31d2c662a9d8c6c838021d` |
| `building.cultivation_area` | `510191_lum.png` | 22795 | `06f2d8ae3c6a37e8fc3b4bd63ef8305b527da90f97db6f1c8684fe959973ba8a` |
| `building.cultivation_area` | `510191.skel` | 429 | `008111fdda996f91815ec015346fbd67c0988599c0fbaf8d4d2230289abf3976` |
| `building.body_training` | `cuizhi.png` | 21217 | `dfae26b7c9f66837061344424132d02892a5d061dc860cc9e93cfbf2f0802f5b` |
| `building.body_training` | `cuizhi.atlas` | 869 | `30b06c7e4ae04a032ae08ec31808365d1826f7d4578fcda76479624c425dc334` |
| `building.body_training` | `510232.skel` | 358 | `b5b393ad445a5e400f073764de71059bfa51af303560b5c4e072e0e2170bbfb6` |
| `building.warehouse` | `510102.png` | 161410 | `9bd8b5196ba8b7b79d6f7ef17da07a0d5289fa208ed03484ec1803fd765d9158` |
| `building.warehouse` | `510102.atlas` | 173 | `a9ec08c486bbf5220eb009fb31f219f84e144409b50b001605bc592efb4b99f7` |
| `building.warehouse` | `510102_lum.png` | 3193 | `7ae4a471f8f0ebccf9f34524abf873e81f40dafee944c197b2722cc0cbcf70fc` |
| `building.warehouse` | `510102.skel` | 429 | `da98161f327a5fdfbf8be48f3bfa3487f692cc779542ec5e02c35a57b4623902` |
| `building.forge` | `520081.png` | 248467 | `4225062d48c08f9562be76315f5b8984d4bea0a2311e5762dc844a23e7567458` |
| `building.forge` | `520081.skel` | 407 | `67c2c1783acb523bcc0a72fce08f8f95d198b896d74928c8b1d0a850c4280393` |
| `building.forge` | `520081_lum.png` | 11562 | `e5f0bbb7d37dfde41b2a496d39ed79d33f2bb1f7a76270a1b14ad7892381bd8c` |
| `building.forge` | `520081.atlas` | 173 | `7ceb93ae6ac1ed87e6a9673721104f5a084a350d7772cc32734347a734ed6bcc` |
| `building.medicine_hall` | `520031.png` | 252001 | `673c00e409e6ea1f100c15aba33efef2dc0b8ca08f0b0777c6b96aae724ea15d` |
| `building.medicine_hall` | `520031.skel` | 442 | `1dee816bb3cd4b7a36d7b0c1c5bfcea64d78999ac8efa61fc0b3a5f1976c048f` |
| `building.medicine_hall` | `520031_lum.png` | 11532 | `46f0c643e8897ad02b71994babe31fa038ba729f1c5e5f8bf84ba19a47ab9250` |
| `building.medicine_hall` | `520031.atlas` | 173 | `b5f806c19d893aa9a873b213e2aa524c069abf271fbf5de19afba92dae523f66` |
| `building.mine` | `520051.skel` | 399 | `6d42e4db5097f24ceacdfface23a5303f9f862d82d12f189cac2e9b9e9f5934a` |
| `building.mine` | `520051.png` | 228507 | `b67d43769de14e32a79500a61332078ef56893ca2abcf7aaf89d13a134639aaf` |
| `building.mine` | `520051_lum.png` | 9917 | `2da9667f3accdf70c29218653fb079d3217597a81601cb09d54ea34e63d579eb` |
| `building.mine` | `520051.atlas` | 173 | `4b217f2397eb08b02a5389e6649659375d6c12418a19fffd8f626fcda3025c95` |
| `building.spirit_field` | `520091.png` | 71736 | `1e5674ad4c30caaac0bc206c355e009303657cbb2379a78c3bfe1be737ce0a83` |
| `building.spirit_field` | `520091.atlas` | 173 | `4c55068bf9fadea74859190419940302cdfe82aa862ee843440077db1e960575` |
| `building.spirit_field` | `520091.skel` | 391 | `9ea03581564b7d7b9ba9ae6dd250114ecfc6f425dff12fcdb6c41e4458ba3ab7` |
| `building.linh_forest` | `520101_lum.png` | 4390 | `576b730cfb02da071d6075e8798f975f87f42f066ebdbcf0b70656fa5886e808` |
| `building.linh_forest` | `520101.skel` | 391 | `5425e61ccd2e7437ef4d1f646a4a7fc2ab1ea7c63af65902f1558b1be7802a12` |
| `building.linh_forest` | `520101.png` | 68499 | `8e83cf0b84f3068fcd8ef6f64be8b75cf8ea3beda7c198486df0dcc8ec57f1d8` |
| `building.linh_forest` | `520101.atlas` | 173 | `325077e0007051bbcf94e4d1f56e1ae55e67bdc52151bc4d410783eee168d656` |
| `building.alchemy_hall` | `520031.png` | 252001 | `673c00e409e6ea1f100c15aba33efef2dc0b8ca08f0b0777c6b96aae724ea15d` |
| `building.alchemy_hall` | `520031.skel` | 442 | `1dee816bb3cd4b7a36d7b0c1c5bfcea64d78999ac8efa61fc0b3a5f1976c048f` |
| `building.alchemy_hall` | `520031_lum.png` | 11532 | `46f0c643e8897ad02b71994babe31fa038ba729f1c5e5f8bf84ba19a47ab9250` |
| `building.alchemy_hall` | `520031.atlas` | 173 | `b5f806c19d893aa9a873b213e2aa524c069abf271fbf5de19afba92dae523f66` |
| `building.guidance_platform` | `510111.atlas` | 173 | `1460001cc428c100fe3e6009d55e34a753e4ce2b38e09eb65bbd50ba90046da3` |
| `building.guidance_platform` | `510111.png` | 236638 | `90b7c595f3b77788c99924ef2eb7ba4b8ede794ccffda1c6808263ba3c711762` |
| `building.guidance_platform` | `510111_lum.png` | 7683 | `4a636e29eab2504c00209b65eb031910532cd782afdecc6ba3427ce3c68788b4` |
| `building.guidance_platform` | `510111.skel` | 453 | `d7331e602f2ccc8959380c0ea64172fa9fb29959da7ef2982f8f7324baab3499` |
| `building.sect_gate` | `cuizhi.png` | 21217 | `dfae26b7c9f66837061344424132d02892a5d061dc860cc9e93cfbf2f0802f5b` |
| `building.sect_gate` | `cuizhi.atlas` | 869 | `30b06c7e4ae04a032ae08ec31808365d1826f7d4578fcda76479624c425dc334` |
| `building.sect_gate` | `510163.skel` | 414 | `bd64c6152a655823608c769c1552d348902610e168aef1d86cdb8e1a65abda6e` |

The bundle hashes are in the candidate table. The source model blobs are on the Source A side only; B0 added no image, atlas, skeleton, or bundle file to the game repository.

## Priority image findings

- **510052 / `building.main_hall` — Đại Điện**: source bundle `1514397bfbedb412500e1472546938dc237d37e2fee907e967d2c59874246174`; primary texture SHA `b6bf88c35e3edc33aba822124296af15a5c8491a05c28f6b5d7b342d20d5325c`; 1104×740 transparent PNG. The image shows a large timber hall, paved footprint and vegetation. It is a visual candidate; source footprint is [7,5], door [3,-1].
- **510076 / `building.disciple_residence` — Đệ Tử Xá**: bundle `51a14d00c90a9899c58ff2cc42e1e6962b66dca9605533c100d90c9c27244576`; primary texture SHA `f8e05d7376fc5ddc7b25f56673b6d5f444b10fd759da06a5929ec4f38a68d320`; 536×416 transparent PNG. The image shows a small two-storey home, yard, water vessel and stacked wood. Source footprint [3,3], door [1,-1].
- **510111 / `building.guidance_platform` — Dẫn Tiên Đài**: bundle `f5f9ff9089f5a944da16c257f216ed9a16563fae118a69d1bad6a5731619958e`; primary texture SHA `90b7c595f3b77788c99924ef2eb7ba4b8ede794ccffda1c6808263ba3c711762`; 532×592 transparent PNG. The image shows a mint-colored spirit gate/portal. Source footprint [3,3], door [1,-1].

The PNG and corresponding separate `lum` texture exist in E: for all three priorities. No Godot-facing runtime resource path was recorded in the game candidate manifest, and no asset rights were cleared for distribution. This is why “exists locally” and “usable in-game” remain separate statuses.

## Repository-candidate images vs missing visuals

- The Source A map candidate record describes three static building PNG candidates already present in the game tree: Hall 510052, Warehouse 510102, and Forge 520081. They are existing candidate pixels, **not** accepted replacement art. The manifest still says binary import false / no runtime resource path; they must not be labeled production-approved or historically recovered art.
- Residence 510076 and Guidance 510111 are present in the E: Source A archive but are absent from that three-image repository candidate subset. Their addition would require owner-approved transport and rights review first.
- The other seven source entries are not proven to be distinct visual assets for their logical destination: cultivation and body training are inferred analogs; medicine hall shares model 520031 with alchemy; body training and sect gate use shared `cuizhi` texture, not an independently verified building image.
- `docs/P3_ASSET_REGISTRY.json` has legacy recovery markers. Do not rewrite those as “recovered” based on candidate artwork.

## Door, pivot, orientation and animation risks

The Source A residence config records doorway [1,-1]. PR #64's `godot/src/simulation/governance/sect_residence_site_v1.gd` at head `bf3ed0310899c554eea4e6b2e1967dcada2d68dd` uses `DOOR_OFFSET := Vector2i(1, 3)`. These are different values in different coordinate contexts. A 2D PNG alone cannot show which map cell the movement system must target. **P0 evidence debt:** Codex A must reconcile it using the real Godot map projection, collision/footprint and actor movement evidence. B0 did not edit or propose changing the offset, route, plot or save.

The manifest does not define pixel pivot, Sprite anchor, transparent-margin crop, gameplay door pixel, Godot orientation, or a renderer conversion rule. Spine candidates need the complete matched PNG + `lum` where provided + `.atlas` + `.skel` tuple and playback proof. A lone PNG is only a static candidate, not the original animation or a correctly anchored building.

## Rights gate and safe next use

Before any transport/import, owner must resolve: scope of the A user authorization; internal-lab vs redistribution rights; which exact bundle/dependency subset may be used; whether a static PNG render is accepted instead of Spine; and a source/pivot/door test. Until then the allowed visual state is **CANDIDATE NOT APPROVED**. Use a neutral original Godot-native placeholder for any mock layout; do not copy Source A prefab, atlas UI, JX/JXQY imagery, or unverified binary assets.

### Provenance sources

- [Game candidate manifest at RC](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/970af33b23076c80d677cf5898a721a27504708f/godot/data/presentation/source_a_candidate_manifest.json)
- [Source A building index](https://github.com/vuanhtuan161094-byte/ZQZS-Source-Knowledge/blob/83cbc4ecbd83eb518a6d6f2b3894377d9d99254d/transferkit/Catalog/BUILDING_VISUAL_INDEX.csv)
- [Source A UI screen index](https://github.com/vuanhtuan161094-byte/ZQZS-Source-Knowledge/blob/83cbc4ecbd83eb518a6d6f2b3894377d9d99254d/transferkit/Catalog/UI_SCREEN_INDEX.csv)
- [Source A UI prefab probe](https://github.com/vuanhtuan161094-byte/ZQZS-Source-Knowledge/blob/83cbc4ecbd83eb518a6d6f2b3894377d9d99254d/transferkit/Catalog/UI_PREFAB_PROBE.json)
