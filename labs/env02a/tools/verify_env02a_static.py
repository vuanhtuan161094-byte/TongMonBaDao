#!/usr/bin/env python3
"""Offline only: verifies provenance and math. Not a Godot 4.7.2 pass."""
from pathlib import Path
import json,hashlib,re,collections
root=Path(__file__).resolve().parent.parent
obj=json.loads((root/'ENV02A_BASELINE_ASSET_SHA256.json').read_text())
assert len(obj['files'])>=32,len(obj['files'])
for relative,sha in obj['files'].items():
    path=root/relative
    assert path.is_file(),f'MISSING ASSET {relative}'
    assert hashlib.sha256(path.read_bytes()).hexdigest()==sha,f'HASH MISMATCH {relative}'
print('PASS ASSET_SHA',len(obj['files']))
model=(root/'scripts/map_model.gd').read_text()
new=(root/'scripts/env02_world.gd').read_text()
renderer=(root/'scripts/env02_chunk_environment.gd').read_text()
assert 'class_name TransferMapModel' in model
assert 'const WIDTH := 20' in model and 'const HEIGHT := 13' in model
assert 'Rect2i(Vector2i.ZERO, grid_size)' in model and 'cell.x < grid_size.x' in model
assert 'WORLD_GRID := Vector2i(192, 192)' in new
assert 'CHUNK_CELLS := 16' in new
assert 'INITIAL_AREA := Rect2i(72, 72, 48, 48)' in new
assert 'extends "res://scripts/env01_environment.gd"' in renderer
assert 'for chunk in visible_chunks' in renderer
assert (root/'scenes/pv01_three_buildings.tscn').exists()
assert 'run/main_scene="res://scenes/env02a_large_world.tscn"' in (root/'project.godot').read_text()
assert re.findall(r'class_name\s+(\w+)',new+'\n'+renderer)==[], 'No second named map/gameplay authority'
# Check original/large footprint + non-overlap + doorway accessibility.
sizes={'main_hall':(7,5),'warehouse':(3,2),'forge':(3,3)}
doors={'main_hall':(3,-1),'warehouse':(1,-1),'forge':(1,-1)}
origins={'main_hall':(84,86),'warehouse':(96,87),'forge':(92,92)}
spawn=(82,84)
occupied=set()
for name,(x,y) in origins.items():
    w,h=sizes[name]
    cells={(xx,yy) for xx in range(x,x+w) for yy in range(y,y+h)}
    assert all(0<=xx<192 and 0<=yy<192 for xx,yy in cells)
    assert cells.isdisjoint(occupied),name
    occupied|=cells
    assert 72<=x<120 and 72<=y<120
    door=(x+doors[name][0],y+doors[name][1])
    assert door not in cells,name
for name,(x,y) in origins.items():
    door=(x+doors[name][0],y+doors[name][1])
    assert door not in occupied,name
    q=collections.deque([spawn]); visited={spawn}
    while q and door not in visited:
        a,b=q.popleft()
        for dx,dy in ((1,0),(-1,0),(0,1),(0,-1)):
            t=(a+dx,b+dy)
            if 0<=t[0]<192 and 0<=t[1]<192 and t not in occupied and t not in visited:
                visited.add(t);q.append(t)
    assert door in visited,name
assert 192*192==36864 and (192//16)**2==144
assert set(range(72,120)).issubset(set(range(192)))
print('PASS STATIC_GEOMETRY 192x192 chunks=144 active=48x48; 3 accessible buildings')
print('NOTE: This is Python geometric feasibility, NOT the Godot AStar runtime gate')