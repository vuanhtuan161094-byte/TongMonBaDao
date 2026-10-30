# Godot Engine Gate v1.1 — selected evidence

Date: 2026-10-30. Evidence is limited to the selected three-effect pack and its clean extracted project copy.

## Results

- Engine: Godot 4.7.2 stable official, build ed1daf0bf001b61586d9930840f2f1394092c079.
- Import: PASS, exit 0, 7.408 s, 18 resources and 3 WebP sidecars; no script parser, resource loading, or import failures.
- Focused runtime: PASS, 14/14 checks; includes grid, nonuniform rectangles, page boundaries, true alpha, preserved source pixels after transparent padding, direction 15, loop/one-shot/stop, shared textures, lifecycle/cache release, and controlled 1/3/10/30 instances.
- Playback: PASS, actual Godot GUI renderer using OpenGL 3.3 Compatibility on Intel Iris Plus. All three sample frame indices changed between two viewport captures at 48, 64, 75 and 96 px.
- Python: 9/9 unit tests passed.
- Portable clean-copy project: PASS. All 21 pack.json file checksums matched after ZIP extraction; resource paths use res:// and have no drive-absolute reference.
- Host warning: Windows root certificate-store read failed. It did not stop import, runtime tests or GUI capture.

## Pack transforms

- Đường Môn m38: 34 frame regions split on complete frame boundaries into five pages, maximum page width 2016 px, preserving frame order and anchor.
- Thúy Yên m146: source sheet was 317×1133 while metadata requires a 318×1136 grid. The selected pack pads 1 transparent column on the right and 3 rows at the bottom. Runtime checks confirmed no alpha in the added region and exact preservation of every source pixel.
- VLTK 01744d1a: 96 nonuniform frame rectangles across 16 directions; imported source sheet remains under 2048 px.

## Limits

- Only the selected three-record pack was engine tested; full 793-unique-texture library import remains pending because the external project cache is outside the Asset Studio write sandbox.
- Godot 4.7.2 export templates were absent; exported PCK/EXE validation is pending.
- Playback is technically verified. Owner art review remains pending; m38 particles are sparse at 48–64 px and modest at 96 px.
- GUI frame time/FPS and prolonged anchor jitter were not measured. Headless FPS readings are excluded.

Local screenshots, raw test logs, the Selected Pack archive and detailed reports remain in the Asset Studio artifacts folder. No JX image payloads are included here.
