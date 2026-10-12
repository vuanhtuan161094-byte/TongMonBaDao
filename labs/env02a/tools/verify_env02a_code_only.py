#!/usr/bin/env python3
"""Code-only, offline structural checks. Not a Godot parser/runtime/visual test."""
from pathlib import Path
import re
import sys

root = Path(__file__).resolve().parents[1]

def read(name):
    p = root / name
    assert p.is_file(), f"Missing code file: {name}"
    return p.read_text(encoding="utf-8-sig")

model = read("scripts/map_model.gd")
world = read("scripts/env02_world.gd")
chunks = read("scripts/env02_chunk_environment.gd")
legacy = read("scripts/pv01_three_buildings.gd")
oldscene = read("scenes/pv01_three_buildings.tscn")
newscene = read("scenes/env02a_large_world.tscn")
project = read("project.godot")
cmd = read("RUN_ENV02A_WINDOWS.cmd")
assert model.count("class_name TransferMapModel") == 1
assert "const WIDTH := 20" in model and "const HEIGHT := 13" in model
assert "grid_size: Vector2i" in model and "Rect2i(Vector2i.ZERO, grid_size)" in model
assert "func doorway(" in model and "func occupied(" in model and "func path_to(" in model
assert "WORLD_GRID := Vector2i(192, 192)" in world
assert "CHUNK_CELLS := 16" in world
assert "INITIAL_AREA := Rect2i(72, 72, 48, 48)" in world
assert "var model = MapModel.new(WORLD_GRID, PREVIEW_SPAWN)" in world
assert "func _chunks_for_view(" in world and "func _update_culling(" in world
assert "func _verify_deferred()" in world and "ENV02A_RESULT " in world
assert 'extends "res://scripts/env01_environment.gd"' in chunks
assert "for chunk in visible_chunks" in chunks and "func set_visible_chunks" in chunks
assert "res://scripts/pv01_three_buildings.gd" in oldscene
assert 'run/main_scene="res://scenes/env02a_large_world.tscn"' in project
assert "--env01-verify" in cmd and "--env02-verify" in cmd
assert "%~dp0." in cmd
assert "func _run_env01_verify" in legacy
for src in (world, chunks):
    assert not re.search(r"^class_name ", src, flags=re.MULTILINE)
for text in (model, world, chunks, legacy):
    assert "E:\\" not in text and "C:\\Users\\" not in text
assert 192 * 192 == 36864 and (192 // 16) ** 2 == 144
print("PASS CODE_ONLY: map owner, legacy 20x13, 192x192/48x48/16, scene references, launcher")
print("PENDING: Godot 4.7.2 GDScript parser, real AStar, chunk rendering, Windows/mobile visual QA")