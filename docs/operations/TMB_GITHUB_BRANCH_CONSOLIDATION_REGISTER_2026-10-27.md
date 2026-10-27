# TÔNG MÔN BÁ ĐẠO — 166-BRANCH CONSOLIDATION REGISTER, 27/10/2026

> Status: INVENTORY & PROPOSED RETIREMENT ONLY. **No branches, PRs, files or source assets have been deleted.** Two Windows Codex recovery sessions are underway; recheck live remote and local worktrees immediately before any future operation.

Repo `vuanhtuan161094-byte/TongMonBaDao`: **166 remote branches**, **40 open PRs, 40 Draft**, **4 closed PRs, 2 merged**.
Of these, **124** non-main branches are neither heads nor bases of currently open PRs. These are RESEARCH/ARCHIVE REVIEW candidates, **not automatically safe to delete**.
**90 `docs/` branches**, **87** without an open PR head/base relation.

## Cleanup strategy (requires future owner approval for exact deletions)

**Wave 0 / Keep active:** Let both Codex jobs finish. Keep main, PvE feature, current audit/coordination, PR #44–#49 and any new `recovery/*` worktrees. Never clean, reset or switch somebody else's Windows worktree.

**Wave 1 / Consolidate documents:** Build a short canonical `docs/STATUS_ACTIVE.md` and a dated source index. For each docs branch with unique facts/approval, record exact SHA and port the needed research/specification to `docs/archive/` or canonical approved subsystem specs. Clearly label research-only, superseded proposals, and current gameplay authority. Delete nothing before this preservation review.

**Wave 2 / PR closure:** Only after both Codex results are available, create a verified selected integration candidate. Review stacked PR #6–#20 (economy/Disciple), #24–#34 (CARE/Map/Combat) and #38–#39 (endgame) as dependency chains; close a proved-superseded PR only with source SHA, replacement SHA, and preserved QA/asset reference. Do not mass-merge these drafts to main.

**Wave 3 / Ref retirement:** Freeze exact candidate list in an owner-approved batch of ~5–10 refs. Confirm all candidate heads SHA, current PR head/base, Windows `git worktree list --porcelain`, no unique essential code/test/art, and reachable preservation tag or archived branch index. Then delete only approved remote refs, re-fetch branch listing/PR statuses and retain written restore SHAs. No force push, history rewrite, delete-all, or E: cleanup.

**Wave 4 / Historical files:** Branch deletion does NOT delete a tracked file from current main/feature or shrink past Git history. Separately classify ~74.7MB of tracked test outputs and keep canonical QA seeds, validated asset manifests, SHA logs; no bulk removal without retention verification.

## Existing PR #35 must be refreshed, not blindly merged

PR #35 `docs/project-status-cleanup-20261025` already proposes replacing obsolete README, AGENTS, architecture, CURRENT_CHECKPOINT and NEXT_CHAT_HANDOFF, reducing the two handoff files by 96.3% per PR. But its source snapshot is 25 October and predates PvE #44–#49, 6v10 and 2 Codex recovery. Cherry-pick **only reviewed status architecture** onto latest baseline, carry forward 27 October evidence and authority. Old comprehensive status docs remain accessible by SHA and archive manifest. Never erase canonical safety rules or unsolved QA debts.

## Obvious low-risk candidates for FIRST review, NOT auto-deletion

- Duplicate docs SHAs: `docs/x1-r01-r03-content-system-20261023` and `docs/x2-r04-r10-content-system-20261023` both `1c5b92b4...`. Inspect unique names/document scope, keep one canonical source and record both refs.
- Alias: `uiux-finalization-v1-20261023` and `integration/b3-playable-care-v1-20261023` both `710137c0...`; the integration ref is PR #25 head, so protect it. The alias is only a **candidate** after local worktree checks.
- Previously merged PR #1 branch `economy-a-market-completion-20261015` and PR #23 branch `integration/tmb-six-skills-main-20261022` can be inspected as possible retirement refs when no active worktree relies on them; the PR merges already preserve code in main. Validate first.
- 87 documentation refs without open PR dependencies and 14 C4 experimental refs form a review pool; date/name alone never justifies deletion.

## Goal

Maintain about 10–15 **active** branches after careful archival, not a numerical deletion quota. Retain exact SHA/commits/tags and design documentation; no function should disappear because a branch name looked old.

## Per-branch classification (all remote branches at scan time)

### A_KEEP_CORE: 4 branches

| Branch | Exact HEAD | PR reference |
|---|---|---|
| `audit/tmb-whole-project-readiness-20261027` | `d2adf282cbfb4ec362f565c2c7d42de4009bb6df` | — |
| `docs/tmb-two-codex-recovery-20261027` | `e3671070f70f9893e982e24128249f14bb103e3d` | head #49 |
| `feature/pve-jx-continuous-world-20261026` | `6b3fd181392c96c2386e5aa85950d2e993d67dda` | base #49,#48,#47,#46,#45,#44 |
| `main` | `29b5fba448b0178cb520a4ada44b375b4b934e31` | base #40,#35,#24,#21,#11,#6,#5,#4,#3,#2 |

### B_OPEN_PR_HEAD: 39 branches

| Branch | Exact HEAD | PR reference |
|---|---|---|
| `art/disciple-asset-pilot-a1-20261025` | `e5d2dafcd0ceac8457d4ab12217ccbe9ec4e3517` | head #40 |
| `codex/cmb-v4-vp01-reduced-visual-lab` | `5da810212cee1a4bbf8c10c7068e665803031ce3` | head #11 |
| `disciple-v2-foundation-action-guard-20261016` | `027627bca396afecf90879717da8d3fc855c2eb7` | head #14; base #16 |
| `disciple-v2-foundation-job-20261016` | `2719dbf6ac32bc5bab2196c25284ced127464406` | head #17 |
| `disciple-v2-ingress-hardening-20261016` | `77dcc6e9ab34bf97e41b686954c55cb2824e9b8b` | head #16 |
| `disciple-v2-scale-20261016` | `f374bc78a5556ad1003d92b27d6ec89c7c929aa3` | head #10; base #17,#14,#12 |
| `docs/game-apk-reverse-skill-20261017` | `8b15e7a807a8695e1bd4e339d1dbf44f433a946b` | head #21 |
| `docs/project-status-cleanup-20261025` | `f1d0cca3a9ef8c921ad07fafba536fcde4edf313` | head #35 |
| `economy-v2-bulk-production-20261016` | `b424d9dad96ec880037691d8163c0258c5667dc7` | head #8; base #9 |
| `economy-v2-core-20261016` | `c6f87edc0112b544b8ee6e3cc63905697caf307e` | head #7; base #8 |
| `economy-v2-disciple-production-integration-20261016` | `cf11d53f2ac48e9b7a220500fece983b675dcd62` | head #9; base #18,#10 |
| `economy-v2-resource-expansion-gates-20261016` | `a13d91fcc848859951c1541fe510026f0d33cbfd` | head #12; base #13 |
| `feature/combat-v3-s1-runtime-effects-20261024` | `9522812e91b7ca5bc0cc108eb92e000e930fe850` | head #29; base #30 |
| `feature/endgame-visual-lod-pve-world-foundation-20261025` | `acfd02daf7bc24c901ad3f4a52b742c35f1a0ad3` | head #39 |
| `feature/map-d1b-functional-hub-playable-20261025` | `c6bde70f6e98f482c91cd6d2c386e58437877209` | head #32; base #33 |
| `feature/map-d2-direct-chatgpt-visual-upgrade-20261025` | `7a551ca4f8f9b15f3069652c5f557e0fbc29833e` | head #33; base #38 |
| `feature/pve-map-presentation-upgrade-20261025` | `dae86efd37a61e2e82c64ea00608fc062c4b423c` | head #34 |
| `fix/combat-v3-s1-official-qa-20261024` | `f86ab7e7d42d6d275314368554489514f7edb98f` | head #30 |
| `fix/pve-play011-movement-save-diagnostics-20261027` | `49db887a7785a3111278d1bb992037e8884b5861` | head #46 |
| `fix/pve-world-group-formation-unique-20261027` | `528f6914261cd4b7725fd972dc39226e33954d50` | head #47 |
| `g1-disciple-radar-sourcea-pool-20261017` | `2219535fc3519ce811265ceed5cb85001efe5e45` | head #20 |
| `gui-workforce-v1-20261015` | `01272b2d54ef5651c62deb0dedc963089ae771ee` | head #2 |
| `integration/b3-care-main-20261022` | `4d08984f044bfa29a98070c8d68ee5a155256d3a` | head #24; base #25 |
| `integration/b3-playable-care-v1-20261023` | `710137c0e3976e685613a86692e5eb128b8d3c62` | head #25; base #26 |
| `integration/endgame-maps-assets-playable-20261025` | `7fd6848fa60791a43013b78fb2ae21fa6d388153` | head #38; base #39 |
| `integration/master-recovery-playable-v1-20261023` | `53ff0b223f4e77ccfbe5c77d2203496ac0cc37a9` | head #26; base #27 |
| `integration/master-v3-combat-d7-uiux-20261024` | `deeae081bcfbe1413d4cf60a29db7e58150888b5` | head #27; base #29,#28 |
| `integration/pr28-combat-v3-s1-playable-qa-20261024` | `9eb4fd55733bb49bbb069240b8e332d37d22aced` | head #31; base #34,#32 |
| `integration-v2-pr9-pr10-pr17-20261016` | `855fc4e8342607fed36f1128536f7a1c0d3d09fa` | head #18; base #19 |
| `lay-01-construction-architecture-design-20261016` | `23818d778cf7d4cb4d711f01182ed19d36f00408` | head #13 |
| `map25-uiux-finalization-20261017` | `5ce3c0f7ca4bd9eb0295f56b421ef96fca3a2bc7` | head #19; base #20 |
| `mine-v2-one-worker-20261015` | `dc3ad974252f5d4c034cfebe441f33fa24e9560c` | head #6; base #7 |
| `qa/pve-aux01-save-return-20261027` | `0a69ac951c0ea80c13b50e16855a61d3f4a9ba4f` | head #45 |
| `qa/pve-aux03-vfx-provenance-20261027` | `89d1061770c87858b76b7f940d2c35fae75edf56` | head #44 |
| `qa/pve-save-forensics-20261027` | `5915fca17b8e23b3afb597f1f379c4d2d60cecbb` | head #48 |
| `ui/pr27-runtime-readability-20261024` | `e9190f490ebea82d2badf7f3fc44b34dd24bd425` | head #28; base #31 |
| `ui-ref-01-design-20261015` | `13422d424e009f3646b9de0618738df978fd44df` | head #4 |
| `unity-sourcea-pilot-20261015` | `44df1428399eed13cfdd4a4dca89a6a410eef269` | head #3 |
| `v2-playable-completion-roadmap-20261015` | `4b05c7cb210c4a7eeb337dee9f6d58f7372afb8b` | head #5 |

### C_OPEN_PR_BASE: 0 branches

| Branch | Exact HEAD | PR reference |
|---|---|---|

### D_MERGED_REF_REVIEW: 2 branches

| Branch | Exact HEAD | PR reference |
|---|---|---|
| `economy-a-market-completion-20261015` | `4a6937dc28d477be13ffc0283d44cc74fe610733` | merged #1 |
| `integration/tmb-six-skills-main-20261022` | `ab39997442752aabe912ac99dcc62c953e9e4496` | merged #23 |

### E_SAME_SHA_REVIEW: 3 branches

| Branch | Exact HEAD | PR reference |
|---|---|---|
| `docs/x1-r01-r03-content-system-20261023` | `1c5b92b4e1e590efc664d273f312f54818f8a784` | — |
| `docs/x2-r04-r10-content-system-20261023` | `1c5b92b4e1e590efc664d273f312f54818f8a784` | — |
| `uiux-finalization-v1-20261023` | `710137c0e3976e685613a86692e5eb128b8d3c62` | — |

### F_DOCS_ARCHIVE_REVIEW: 85 branches

| Branch | Exact HEAD | PR reference |
|---|---|---|
| `docs/ascension-r11-r21-vertical-slice-source-proof-20261025` | `c61fb9d15277bb79c41279a0cb9e83167c93f260` | — |
| `docs/b3-care-o6-recovery-and-design-gates-20261023` | `c1c717be8f85d4d82a283e324cdc88bbf781967d` | — |
| `docs/b3-postcare-next-playable-design-20261022` | `e0cdde4583ed80859f82d0ff99da961bc4214fd0` | — |
| `docs/b3-tuviflow-threepath-benchmark-20261023` | `dda78655626a1a68aa630373813b03815a0d422c` | — |
| `docs/b3-v2-architecture-redesign-20261022` | `f1246f3a847069d7664d7acb74afba3182439d1b` | — |
| `docs/b3-xp01-direct-kill-canonical-20261023` | `3606b377240fdcf80fa3b0c0b833d8860f5dc394` | — |
| `docs/bd01-equipment-deep-design-20261023` | `9a618ecf87bcc9ebe66a2c9ad8a1601ad5d3f169` | — |
| `docs/c4-jx1-four-school-pilot-element-contract-20261019` | `624126dbcb2da4dbb42c48493451ad8ab362810b` | — |
| `docs/c4-jx1-presentation-parity-20261019` | `98db733f018a1f9a82047f65abfdbe77344ad37c` | — |
| `docs/chatgpt-codex-control-plane-20261026` | `1d3c0f4579b014a04f6a687a3924937f7fe51f22` | — |
| `docs/combat-base-luc-duy-mind-redesign-20261023` | `dc7077d5bad2d19b810d2f30ad60b4e570dc9713` | — |
| `docs/combat-base-v2-audit-20261023` | `9063c14834c726b30e532e1f52f4e7d93472f5a2` | — |
| `docs/combat-finite-retirement-full-caller-save-migration-20261025` | `634b5484900d5ff0b190c3452fdb24d79fbf64c1` | — |
| `docs/combat-v3-five-elements-mutation-balance-dependencies-20261024` | `1319426eb8d5004578e16b8a8baa20345055213c` | — |
| `docs/combat-v3-full-action-balance-proposal-20261024` | `2bd0a1ee5f87423de70af3ea5e73650958124871` | — |
| `docs/combat-v3-jx1-jx2-kiemthe-skill-mechanics-reference-20261024` | `3f9c141940944217d686af9e206aec5845946e8a` | — |
| `docs/combat-v3-jx-real-source-forensic-skill-audit-20261024` | `23ec02dfb922d92a9fa029da1f11932eff355751` | — |
| `docs/combat-v3-multi-disciple-jx-mechanics-engine-design-20261024` | `90c156afda031d1686025ae81b48bad17a129158` | — |
| `docs/combat-v3-player-readable-current-system-and-skill-contract-20261024` | `8a369c0e4b423b054f9626f9e7d7f80d0ddd6384` | — |
| `docs/combat-v3-pr27-measured-fixture-rebalance-20261024` | `c7cb2b4c78c184c206933d848935c1313df0792b` | — |
| `docs/combat-v3-s1-pr29-godot-qa-repair-packet-20261024` | `f8719b464954eff0d31381d883f6d84d9957453e` | — |
| `docs/combat-v3-s2-dash-firecombo-autoai-contract-20261024` | `6655a760d174c3cc47e06a140d7c8cc109bb7691` | — |
| `docs/combat-v3-skill-system-canonical-runtime-gap-20261024` | `31da96332d55b579f812f86ad37e2ee27decb2d2` | — |
| `docs/combat-v3-v2-systems-integration-masterplan-20261024` | `cb2800ec0ba9b6b4cf8c0cfe88768f2e11149df6` | — |
| `docs/combat-v3-vertical-slice-first-plan-20261024` | `05a7b0f6f06a6e555255b0d6a047dea38dadb791` | — |
| `docs/combat-v4-hybrid-school-design-c-20261018` | `8a1f2e83d44274452bf3fc06e155515562d80b28` | — |
| `docs/combat-v4-integrated-jx1-sourcea-realm-party-plan-20261018` | `793a6ad3547e768f1bdc75b594dfcd946e3c4ad8` | — |
| `docs/combat-v4-jx1-drive-skill-audit-20261018` | `3ad6c227c249c4fc9f5425d2ea9b7d8feaba376b` | — |
| `docs/combat-v4-jx-factions-realm-skill-ladder-20261018` | `001b1c3e90772955bdb641d7a1d2c9ddcd1d91ec` | — |
| `docs/combat-v4-jx-gameplay-deep-audit-v2-20261019` | `32444e69ebac4c9128dd6b34989c49b47b7e563f` | — |
| `docs/combat-v4-jx-two-source-deep-design-20261019` | `150539aaf5b8e6981c76d16c42f46fcf928cc019` | — |
| `docs/combat-v4-legendary-exclusive-skill-design-a-20261018` | `cc74e28f996f14217f388dc09051adb878282a4c` | — |
| `docs/combat-v4-source-vl-research-20261018` | `c8568b3c9ea84608ca8705864c8d70a0539a748f` | — |
| `docs/combat-v4-thanh-truc-lam-packet-20261018` | `4fdb077ad6f880ab535436e92ddce12967c6d6b5` | — |
| `docs/cpv2-c4-01-three-paths-source-to-archive-20261023` | `8e2b7cca0a24be951b5f2eff87a9234ac5054bed` | — |
| `docs/cpv2-c4-boss-vs-research-economy-20261023` | `0bb10b9d8ffbf9e167352e10cdd997e43ba432b9` | — |
| `docs/cpv2-c4-foundation-drop-sources-20261023` | `f4eceea1f2be5f875aae9974b1b9ba0929eae573` | — |
| `docs/d7-dual-pool-lifecycle-balance-review-20261024` | `64ecbcd5d94a9be6df346f32a624fc7d5697998e` | — |
| `docs/dev-reset-skill-system-player-guide-20261024` | `931e73d03818dd5020dcfa1c56f021f7f464aa47` | — |
| `docs/equipment-r1-r30-ascension-chanvan-combatv2-review-20261024` | `8311b17d2a16b36d6cdffd8c7e41f6285ba229d5` | — |
| `docs/equipment-v2-forge-transaction-rng-inheritance-20261024` | `0653dde6bffd8ea65ba359f102c0f83c21b0831b` | — |
| `docs/forge-lv30-75-r20-predivine-source-cost-softlock-20261024` | `a1e9c49189373045e510832df5d9558b0086d135` | — |
| `docs/forge-lv30-75-three-budget-profiles-r20-20261025` | `d0eb1a411fe56faffda3cb5bdc2a33b0aa27b4c7` | — |
| `docs/forge-r11-r30-source-blueprint-economy-anti-softlock-20261024` | `6fa6f5e364c793105ec9e775cb429fe2493bcd4f` | — |
| `docs/forge-v2-enhance-refine-grade-realm-inherit-economy-review-20261024` | `fb9cd0e64912f89719d40166a9356beb7c750489` | — |
| `docs/forge-v2-transaction-blueprint-grade-salvage-inheritance-20261024` | `1da1d0616cbad198738af8e9648afceb47987761` | — |
| `docs/forge-v2-transaction-rare-quality-qa-20261024` | `9fc8aaf213839afdedb11b6fbb7ed065b89df752` | — |
| `docs/full-branch-audit-nextsteps-20261025` | `07ad2dac1893e904a9ed9bc24575469306cfb6c8` | — |
| `docs/gear-r10-r11-r20-r21-first-design-acceptance-20261024` | `8fd21575bdafdc5bc4dda2a17abf416cc6ad9abb` | — |
| `docs/gear-v2-basic-rare-24sets-camp-sources-20261024` | `6226a8a2ab073b362ab6b899deb50d869b59e63f` | — |
| `docs/huntworld-20-camps-200-400-mobs-rts-review-20261024` | `e388be9128ca03c73c9e47003cc301dd8ee03641` | — |
| `docs/i1-concrete-disciple-rootv2-legacy-migration-design-20261024` | `127bf2055a2eeb5461b9613d78ee1fa0eabaa5d2` | — |
| `docs/integration-tmb-agent-skills-main-20261022` | `c215891973df6017f95895a260f37e1aec5d36c8` | — |
| `docs/jx1-d01-d08-source-first-20261020` | `d81db08608e2c9e1584d75942cf0671489e278dd` | — |
| `docs/jx-original-skill-readonly-source-audit-packet-20261024` | `b5cc69d261326542660fc68fca5346e37954358e` | — |
| `docs/mainline-governance-content-foundations-20261023` | `4b8caa271d2665c30b0a6d0150abed302b05c5f1` | — |
| `docs/map-d0-sect-main-redesign-20261025` | `25cb7a0f59a93ddcccc8a5d6acf1dd8e2290874f` | — |
| `docs/map-d1-b-overnight-one-shot-20261025` | `aebbe19fc53d7357639ceb68ae977893eaa558ac` | — |
| `docs/map-d2-visual-rebuild-broad-scope-20261025` | `89e7c11d9936d29cae8983e1e09554a5464c2456` | — |
| `docs/map-redesign-checkpoint-20261024` | `fa51f32b843ae090f4a7ecce5caad750d8fb5d30` | — |
| `docs/playable-v1-six-foundations-numeric-truth-20261023` | `5cdb902f5045b72fb6fae97e40528f9680e94027` | — |
| `docs/pr26-d7-v3-combat-ui-handoff-20261024` | `a63c87929c002a2efac033b0ead27c3989c53e61` | — |
| `docs/pr28-pr29-coordination-20261024` | `3b3a51bee0789509a47b3d6b80889d857828307d` | — |
| `docs/pve-play01-chat-handoff-20261026` | `1f506e2868c71f0f1836304001a88b6a7a3948a4` | — |
| `docs/r11-frontier-s1-s2-source-provenance-softlock-20261025` | `4c3e7ba5df058eb4250e14e02db6b13f6e2a8618` | — |
| `docs/r11-s1-s2-quant-economy-combat-softlock-20261025` | `be1320d558dcb2dd162743cca96a9b1b4cade830` | — |
| `docs/rts-hunting-map-200-monsters-hybrid-path-review-20261024` | `4a9cb4a11f546a5d172f5446609432c4d3ff4d84` | — |
| `docs/sourcea-uiux-audit-20261026` | `92f30bb5c48fd83209b8b609cd79bacda6b85a59` | — |
| `docs/sourcea-v5-backend-handoffs-20261021` | `7cbe5fe58e4d03850a7107bfb955addb9c9b1533` | — |
| `docs/tmb-agent-skills-20261022` | `9f10db7f5d59d5a93a023fd2c0ea6d48a98d5434` | — |
| `docs/tmb-crosssystem-content-reconciliation-20261023` | `cb2d08798658e3765c37359f01731cafcde9d20e` | — |
| `docs/tmb-d7-combat16-birth-odds-freeze-20261023` | `a4017592916518e4527b0c534c7d50651ba95d2c` | — |
| `docs/tmb-d7-dual-pool-deep-audit-20261023` | `6ed3bf91c6e40919e4889c6197fd49b70479c69a` | — |
| `docs/tmb-d7-final-crosssystem-impact-gate-20261023` | `888cbe5b83e8f22c376457a770fb0ba9d1480bc4` | — |
| `docs/tmb-master-completion-roadmap-20261023` | `36f5ba1fb976f79a914731eabce6d9b1c7240b81` | — |
| `docs/tmb-status-20261021-v5-sa-lib` | `447112287da6b2aaa0e7c32bf53a3e3d70fa59d0` | — |
| `docs/tmb-tam-can-tu-tinh-v3-numeric-lock-20261023` | `ce3bb318501ea5df11ef858e72ccc7a83c4bb775` | — |
| `docs/ttl-20-camp-monster-catalog-loot-economy-v3-20261024` | `a8d69476ba89720e5c51a5b6d29d7d5a2d729d48` | — |
| `docs/ttl-20-camps-map-topology-five-difficulties-design-20261024` | `f4090db617391c6b2453fbadd0d973bb74323c60` | — |
| `docs/ttl-v3-loot-recipe-eligibility-balance-20261024` | `7ef65ec0986d6c60bf6e4fa47e6e44ef9e3d88dd` | — |
| `docs/ttl-v3-rare-loot-three-profiles-gear-scaling-20261024` | `58bfb99ca1425cc17327d86bd4b3cbb4d5dba3a3` | — |
| `docs/ttl-v3-verified-loot-sources-crafting-matrix-20261024` | `3b30d992343f39a348570b16c229f21008ccd42c` | — |
| `docs/v3-one-disciple-three-realm-waves-skill-journey-20261024` | `2c059462b135edba47cf8bd5bb98e9761969aaa1` | — |
| `docs/work-mode-handoff-map-qa-integration-20261025` | `bb7d93cb5ff6470aad2fba0f626f7b650720b572` | — |
| `docs/worldcombat-v3-heterogeneous-monsters-element-loot-20261024` | `b23ef05ccbc98b9a79184b6e2fe910150fc86d01` | — |

### G_HISTORICAL_CODE_REVIEW: 33 branches

| Branch | Exact HEAD | PR reference |
|---|---|---|
| `audit/c4-backend-gap-contract-20261019` | `ab554f931760dcd7acf7a968f8ffc144d5927449` | — |
| `c4-01-battle-world-cast-schema-20261018` | `4e2ca7db07c98a021977bbcb026b6be7c958bbff` | — |
| `c4-backend-identity-contract-20261019` | `49df1f5952df93a01bda358cdf3c0f68bcb0e145` | — |
| `c4-be01-hunting-playable-and-max-fixture-20261019` | `4a2584099dea21f25e85c6f9368b1f4243239f25` | — |
| `c4-be01-live-hunt-maxlab-20261019` | `70fa85a071823aa683a4668ffcb9814ebb57e28b` | — |
| `c4-be01-live-hunting-maxqa-20261019` | `8b314c9b557b16c0888faabf1999f5ddf70fc192` | — |
| `c4-gp01-combat-feedback-20261019` | `f2ea6852823d8bf5f7a1451c0cb975a0773364af` | — |
| `c4-gp01-jx1-source-hud-20261019` | `9e187be0df9e32c873712e3eb6eb464f87160e89` | — |
| `c4-jx1-camera-world-source-audit-20261020` | `b83b92f3832c28520d620de8b11aeb7a557dcce4` | — |
| `c4-jx1-rank-and-fx-source-20261019` | `f757c5f162f85ebccda936b06ba8a06b07eac003` | — |
| `c4-jx1-ui-readability-hardening-20261019` | `8f14d171744b3d332f198dc5fca9c2547a71989c` | — |
| `c4-jx1-ui-source-first-20261019` | `5cd6889a9b25b2221515f8aad7a8882806d06106` | — |
| `c4-pilot04-jx-effects-20261019` | `5c2e42abb44407bfc4d5a14ea2e7b2e966a2c3de` | — |
| `c4-pres01-jx-motion-readability-20261019` | `d160f97982f627460ab17661bdbfc572fe7c51b4` | — |
| `c4-vp01-sourcevl-real-combat-pilot-20261018` | `b2965d951f8490286c6f75ab3694ab16f02e1446` | — |
| `code/code-clean-finite-reward-20261025` | `5fbdbc6309c3f1386f0d8b619831e007c5a52824` | — |
| `design/combat-v4-gameplay-ai-hud-3encounters-20261019` | `be6331a193cd4a12a68df2807ae05412bd3fb3c8` | — |
| `disciple-v2-foundation-activejob-20261016` | `5e870c8caa335563d991e3f78c344ffa48b76288` | — |
| `feature/dev-character-studio-mvp` | `3f09dd1b54be19c305bc76a915ee55f380499281` | — |
| `fix/pve-cache-topology-events-offline-20261026` | `2b455682208c12d51d5f682f99694565887e0cfc` | — |
| `fix/pve-same-clock-gui-harness-20261026` | `7038e8788df0b0c1c2412e72bd1fba3f320f1140` | — |
| `fix/pve-save-world-identity-20261026` | `c90ab907436fc4d92ca51c345c5eef728834008c` | — |
| `integration/g1-map25-c4-real-hunt-20261019` | `073e2d99c704c3e93009029218699a9bcc1ae799` | — |
| `integration/pve-play01-audit-gates-20261026` | `94db3b5c2ee9b22567781cb10e4a753b8a78bece` | — |
| `lay-01-adr-manifest-design-20261016` | `2448212553c364b813d0a4a9921a4a412e0239b4` | — |
| `plan/codex-playfirst-demo-20261020` | `83b29fdfc10e1c475d4921f464821ff06ac0bd65` | — |
| `qa/code-r0-finite-world-20261025` | `cb0974bca4445b3ef591fbb149740f328a40c0c8` | — |
| `qa/pve-aux02-world-input-contract-20261027` | `32545b31262b11d5fb30510790765245c9d70c1b` | — |
| `qa/pve-play01-independent-evidence-audit-20261026` | `630de21f0c9fc3751de15c296c2c75303dd2e4ac` | — |
| `qa/pve-playable-fps-diagnostics-20261026` | `8c0582be3b4e008bb843495904c0a63db3eb23ca` | — |
| `sa-lib-01-sourcea-spine-library-20261021` | `87d6b60123c85930e9eb571949f4aafbb8f8ac7d` | — |
| `tools/af-jx1-player-forge-20261020` | `4dcb2daf01e6a14971b32131b7b69d7c67ae563f` | — |
| `work/playfirst-demo-max-v3-20261020` | `aad7cec147e5df587ab13614e1c9ef2ac752a8d7` | — |
