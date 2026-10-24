# MAP-D1B follow-on study — District C, asset recovery and LOD

Status: documentation only. This note does not authorize or implement District C, additional producer instances, new systems, or asset changes.

## Boundary

The current MAP-D1B Option B prototype is the sect map in the real P3.2 scene. The hunting world remains the separate Thanh Trúc Lâm map with 20 camps. District C must continue to use the existing sect map model, camera, runtime, producer instances, and SaveService after a later explicit code packet. It must not add a second simulation or reuse the hunting-world map as a sect district.

The 30 Mine, 30 Linh Lâm, and 40 Linh Điền figures below are a planning scale only. They are not current runtime counts, placement coordinates, unlocked content, or owner-approved art.

## Spatial scale and chunking

- Current world: 192×192 cells, divided into 16×16 chunks (144 total chunks if the whole grid is populated).
- Current starter district: 48×48 cells, or 3×3 chunks.
- The current default camera capture reports 20 active chunks. That is a runtime observation for this camera/view and current implementation; it is not proof that all world chunks are resident or that a 100-producer district is already supported.
- A full 16×16 quad mesh has 256 tiles, about 1,024 vertices and 1,536 indices at four vertices and six indices per tile. This is a topology estimate from the renderer's existing mesh shape, not a frame-time measurement.

Do not squeeze 100 additional producer locations into the starter rectangle. First lay out contiguous expansion land beyond the 48×48 starter and count legal static footprints, roads, buffers, and pick targets. Keep every real producer instance mapped by its stable `BuildingState.id`. Use production clusters to shorten roads and avoid a separate long road branch for every instance.

Planning options for a later design review:

| Option | Spatial organization | Advantages | Risks / unknowns |
|---|---|---|---|
| C1 — three contiguous work districts | Mine, Linh Lâm, and Linh Điền each occupy a neighboring expansion block connected to one production spine | Clear zone identity; simple route map; easier art variation and instance picking | Needs enough approved footprint/art variants; a flat grid may feel repetitive |
| C2 — four landscape clusters | Split the 100 instances into 4 mixed or crop/resource clusters, with type-specific subareas and one shared spine | More room for terrain/ecology variety; supports staged expansion | More junctions and cross-traffic; districts may become visually less legible |
| C3 — staged unlock rings | Add production chunks in rings or levels; reveal additional clusters only when existing canonical rules allow expansion | Lower first-load visual density; clearer early progression | Unlock authority and save migration are outside MAP-D1B; do not invent either here |

No option is selected by this report. A later packet should choose a spatial plan before assigning actual cells.

## Asset recovery order

All 32 present Source A PNGs passed the current SHA-gated contract. The runtime loaded 30 in the final map capture; two valid vegetation records were not part of that final visible prop set. The verified library does not include building art for the Gate, Residence/Cư Xá, Training/Tu Luyện, Mine, Linh Lâm, or Linh Điền, and it has no verified water, bridge, cliff, or slope set.

Recommended art work order after asset provenance is available:

1. Gate and threshold pieces: gate arch, wall/road cap, entrance floor transition.
2. Core district buildings: Residence/Cư Xá and Training/Tu Luyện with front-facing and side-facing footprint views.
3. Producer worksite families: Mine, Linh Lâm, and Linh Điền structures. Keep one art family per actual producer type; do not draw a fake active job or fake output.
4. Terrain transitions: water edge, bridge/deck, slope/cliff and ground-height boundaries as one coherent tile family.
5. Road edges and ends only where the existing six verified route textures cannot close a boundary cleanly.

Every candidate requires source provenance/rights, an immutable SHA-256, dimensions and alpha inspection, pivot/ground contact, facing/scale checks, a footprint specification, Godot 4.7.2 import verification, occlusion/picking check in the real P3.2 scene, and visual review against the Source A art bible. Animation claims require an actual verified clip; no still PNG is to be presented as a working animation.

## LOD and rendering strategy for a future code packet

LOD here means how much map detail is rendered at a distance. It must remain presentation-only and read from the canonical world state.

| Level | Candidate use | Presentation data | Guardrail |
|---|---|---|---|
| Near | Current camera and interactive districts | Verified building sprites, selected decorative props, readable route tiles, real producer markers and pick zones | Keep the same `BuildingState.id`/controller target and current camera authority |
| Mid | Neighboring production clusters | Lower prop density, reuse verified tiles, show approved building silhouettes and real state-backed worksite cues | Never imply a worker, active job, stock, or production output that is absent from runtime state |
| Far | Distant/locked expansion blocks | Coarse district ground and aggregate visual silhouettes; omit per-prop detail | Do not add unlocking, population counters, new save data, or a second producer registry |

Use the current chunk lifecycle as the starting point. Measure chunk creation, draw calls, visible texture count, working set, frame-time percentiles, and camera-motion stalls on a real Windows build before changing chunk size or adding asynchronous streaming. The current benchmark is only a baseline: 60 one-second windows, 59.74 FPS mean, 60.02 median, 56.20 p05, 55.10 minimum, process frame-time p95 64.54 ms, and process Working Set median 505.12 MiB with startup peak 738.75 MiB. It does not certify a populated 100-producer map or Android performance.

Future performance evidence should use the same map camera and state for each candidate, report warm-up and steady-state separately, include long camera pans across chunk boundaries, and record a low-percentile FPS plus frame-time p95/p99. Do not infer performance from a still image or use a screenshot's displayed FPS.

## Next evidence gates (not yet authorized)

1. Owner selects a spatial organization for C1/C2/C3 and reviews the Option B images.
2. Asset owner provides or approves source files and provenance for the missing structure/terrain families.
3. A separate code packet names the specific map files/tests allowed, preserves canonical producer IDs and camera authority, and defines map contract tests for 100 real instances.
4. Windows manual play and Android/touch QA are run on target devices.
5. Re-measure rendering with approved production art at the chosen target scale.

Until these gates are met, all District C numbers and LOD recommendations remain planning notes only.
