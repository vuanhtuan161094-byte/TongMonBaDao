# VFX SHARED RUNNER V1 — one packet, one Godot engine, one QA pipeline

**18 Nov 2026 · PR #72 Draft · coordinator-owned.** One reusable **Godot 4.7.2** test/capture driver, not one new engine per school. This supplements the mandatory [Art First / Production V4](TMB_VFX_ART_FIRST_SINGLE_SKILL_SOP_V3_20261114.md) and the existing validator; does **not** replace the school contract, original RGBA source, moving target test or owner visual gate.

## Files and use
- `tools/qa/run_vfx_shared_packet.py`: single Python CLI parameterized by the existing **V4 packet JSON** (`scene_path`, `lab_script`, `focused_test`, `time_contract.phases`, `proof_contract`); runs common validator packet/assets, **exact-SHA check**, strict Godot import/parse/focused test and optional real Godot 1280×720 MP4, screenshots, evidence manifest and hashes.
- `.github/workflows/vfx-shared-skill.yml`: **reusable workflow_call** with three inputs (`packet`, `mode`, `duration_seconds`), plus manual workflow_dispatch. The workflow installs official pinned Godot 4.7.2 once and uploads proof from a single output folder. One short template invocation is sufficient instead of copying 90-line per-skill runners.
- Modes: `focused` for source/technical contract with **no film**; `g35` for native three-timepoint image and short movie **early STOP**; `full` for full native movie (set duration beyond attack, sustain, last phase and cleanup). **G3.6 contrast and G3.7 semantic art review are separate manual/art gates**; recording a G3.5 snapshot never authorizes a skill.
- **Important:** this runner consumes EXISTING atlases and committed first-party source; it does **not** invoke skill's generators. If atlas doesn't exist yet, school chat must bake original RGBA via its own reproducible generator **before** this runner. Never treat a missing master as a reason to silently create placeholder art.
- The runner does not change/deletes source files; logs/video in `RUNNER_TEMP`; all CI artifact links expire after 14 days, so approved masters and durable QA source must still be saved in the repository or owner-approved permanent storage.

## Usage (school wrappers become ~15 lines)
At the end of the school-owned workflow, or to replace its repetitive Godot/FFmpeg steps once parity is demonstrated:

```yaml
name: VFX School | sample focused native
on:
  push:
    branches: [integration/pve-p0-playable-ui-20261103]
    paths:
      - 'godot/labs/combat_lab/poison19_phu_cot_co_tien_b/**'
      - 'docs/operations/vfx_packets/POI19_R3_V4_PREFLIGHT.json'
jobs:
  vfx:
    uses: ./.github/workflows/vfx-shared-skill.yml
    with:
      packet: docs/operations/vfx_packets/POI19_R3_V4_PREFLIGHT.json
      mode: g35
      duration_seconds: 0
```

**Do not blindly replace** existing POI19/R3 or FIST12 pipelines yet: their independent generated-asset steps, native-viz semantics, or extra guard/expiry tests may exceed the shared runner. Their original workflows remain intact until exact-SHA output parity is checked. For POI19 actual 6.5s mark expiry, use `mode: full, duration_seconds: 8.5` after early owner visual gate; the packet's three checkpoints alone do not inspect its 6.5-second sustain.

### Manual local/CI example

```bash
python3 tools/qa/run_vfx_shared_packet.py \
  --packet docs/operations/vfx_packets/POI19_R3_V4_PREFLIGHT.json \
  --mode g35 --seconds 0 \
  --out /tmp/tmb-vfx-poi19-g35 --sha "$(git rev-parse HEAD)"
```

Godot 4.7.2, ffmpeg, xvfb, Python Pillow, original atlas files and Linux Bash must be present. On Windows use GitHub Actions or a correctly configured Linux environment.

## Governance and definition of done
- Start a skill with **contract + original master + atlas/poses**, NOT another independent Godot project / N copies of capture script / redundant full movie workflow.
- Source PNG and unique layers, **not** new media/CI infrastructure, should account for most skill-specific files; per-skill focused test is justified for skill-specific semantics and moving target/decoy.
- G3.5 at early native true gameplay scale; only run G5 full video after original art meets visible 1× requirement. No FPS claims from fixed-FPS movie output.
- Compare a fully passed existing POI19/FIST12/PAF06 school workflow with shared runner evidence before migration; keep old workflows and original source unless test parity is demonstrated. Coordinator owns shared code.
- Never edit combat gameplay, approved assets, SaveService, PvE/G8, V6.3 or branch/merge state. `TECH PASS != ART PASS != OWNER APPROVED`.
- CI default self-test is POI19 R3 G3.5 (committed original source). If CI fails, log is an actionable defect, not proof of a working generalized pipeline. Owner approvals and Android physical remain pending.

## Launch state
This document and the reusable driver can be committed before CI finishes; **claim TECH PASS only after exact-SHA Actions run concludes SUCCESS**, not because the code exists. Previous B/D/E shared LAB pilot success `a6557607` does not certify this new V4 packet-runner code.
