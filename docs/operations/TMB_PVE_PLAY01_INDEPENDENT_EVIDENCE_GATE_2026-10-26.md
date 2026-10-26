# PVE-PLAY-01.1 — Independent Evidence Gate (read-only)

**Authority:** This QA branch is a frozen fork of Codex PvE \`b91d60a\` and is **NOT** integrated into the active Windows Codex worktree. Only two independent Python files and this note are added. It does not modify Godot gameplay, UI, SaveService, renderer, Source A, or launcher.

## Run on a local copied FPS JSONL after the Windows playtest

From repository root (Python 3, standard library only):

\`\`\`powershell
python tools/qa/pve_play01_evidence_audit.py "path\to\normal_gui_YYYYMMDD.jsonl" --out "path\to\evidence_audit.json"
python -m unittest discover -s tools/qa -p "test_pve_play01_evidence_audit.py" -v
\`\`\`

The report separates phase windows, estimates 15s production / 30s PvE / 10s return coverage, shows the worst five 3-second-window spikes, flags any >100ms spike, and **refuses to infer full-session P99 / 1%-low FPS from 3-second summaries**. Global per-phase P50/P95/P99/1%-low is calculated only when actual frame durations are present as \`{"kind":"frame","phase":"pve_active","frame_ms":16.7}\` or \`frame_ms_samples\` arrays. 1%-low is based on the slowest 1% frame times. Do not claim that this proves end-to-end GPU display/present latency.

The instrument under \`94db3b5c\` logs 3-second windows and currently lacks raw-frame series and P99; an audit using those logs will legitimately flag missing evidence. Coarse window phase assignment near transitions can misattribute frames; the segment durations are explicitly **approximate**. The scripts are observers and **must not be copied into the live Windows worktree mid-session**.

## Acceptance still requires separate external evidence

1. Exact new SHA, actual official Godot 4.7.2 version and successful focused test logs on that SHA.
2. A real normal Windows launcher, *not* MovieWriter, 1280×720, and physical mouse actions from visible Thanh Trúc Lâm entry through six eligible disciples, 6v10 V2, JX #158 cast/positive-hit/impact.
3. 15s sect + 30–60s live PvE + Save/Return + 10s sect; reload of actual saved gameplay without duplicated reward.
4. Per-frame P95/P99, slowest 1%-frame FPS, max and frequency >33.3/50/100ms, top spikes with timestamps; compare logger ON/OFF on the same machine/save.
5. For every unacceptable spike, a matched Godot profiler capture (script/process/render/GPU clues as available). A frame-time summary **cannot attribute root cause**.
6. A genuine GUI screenshot/video (not a synthetic drawn test scene) plus the operator's explicit manual-play result and remaining defects.

**Automated outcome is always \`PLAYABLE_UNVERIFIED\`.** A reviewer may only issue \`PLAYABLE_PASS\` after independent evidence and owner approval. If severe stutter persists, issue \`PLAYABLE_BLOCKED\` despite a ~60 FPS mean.

**No merge into Codex or main without owner approval.** On the next pushed Codex checkpoint, review changed paths, compare with \`94db3b5c\`, and select only missing fixes. Existing Codex caches/SAVE identity must be kept intact.
