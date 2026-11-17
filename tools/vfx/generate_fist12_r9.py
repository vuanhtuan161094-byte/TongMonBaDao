#!/usr/bin/env python3
"""FIST12 R9: decode original image-authored VFX keys and bake direct RGBA Godot atlas.
Source masters are original standalone first-party sprite sheets (not posters),
base64-encoded WebP RGBA in source control. Three punches have **different**
source-pose illustrations. This is VFX only, no actor animation or gameplay edits.
No GIF, skeletal rig, fake Godot screenshot or external/licensed game art.
"""
import base64, hashlib, io, json
from pathlib import Path
import numpy as np
from PIL import Image
ROOT=Path(__file__).resolve().parents[2]
BASE=ROOT/'godot/labs/combat_lab/fist12/assets'
SRC=BASE/'r9_sources';OUT=BASE/'generated'
OUT.mkdir(parents=True,exist_ok=True)
CELL=320;SOURCE_CELL=224
LAYERS={
 'charge':('f12_charge.png',8),
 'contact':('f12_contact.png',8),
 'mark':('f12_six_second_mark.png',8),
}
REPORT={}
def load_source(name):
    filename=SRC/f'f12_r9_{name}_master.webp.b64'
    raw=base64.b64decode(''.join(filename.read_text(encoding='ascii').split()),validate=True)
    with Image.open(io.BytesIO(raw)) as img:
        assert img.format=='WEBP',(name,img.format)
        rgba=img.convert('RGBA')
    assert rgba.size==(4*SOURCE_CELL,2*SOURCE_CELL),(name,rgba.size)
    rgba.save(OUT/f'f12_r9_{name}_master.png',optimize=True)
    REPORT[name]={'source_webp_sha256':hashlib.sha256(raw).hexdigest(),
                  'master_png_sha256':hashlib.sha256((OUT/f'f12_r9_{name}_master.png').read_bytes()).hexdigest(),
                  'source_px':list(rgba.size),'poses':[]}
    keys=[]
    for i in range(8):
        s=(i%4)*SOURCE_CELL;t=(i//4)*SOURCE_CELL
        tile=rgba.crop((s,t,s+SOURCE_CELL,t+SOURCE_CELL)).resize((CELL,CELL),Image.Resampling.LANCZOS)
        arr=np.asarray(tile.getchannel('A'),dtype=np.uint8)
        visible=arr>36
        assert visible.sum()>500,(name,i,'near empty frame')
        # Edge clipped source imagery is an art red flag. Trace actual visible
        # alpha envelope but do NOT assert its beauty or smoothness by hashes.
        sy,sx=np.where(visible)
        bbox=[int(sx.min()),int(sy.min()),int(sx.max()),int(sy.max())]
        edge=int(((arr[:4,:]>36).sum()+(arr[-4:,:]>36).sum()+(arr[:,:4]>36).sum()+(arr[:,-4:]>36).sum()))
        assert edge<100,(name,i,'hard source crop edge',edge)
        keys.append(tile)
        REPORT[name]['poses'].append({'index':i,'visible_pixels':int(visible.sum()),'bbox':bbox,
                                      'alpha_hash_sha256':hashlib.sha256(tile.tobytes()).hexdigest(),
                                      'edge_pixels':edge})
    assert len({p['alpha_hash_sha256'] for p in REPORT[name]['poses']})==8,(name,'duplicate pixels')
    return keys

def write_atlas(keys,out_name):
    assert len(keys)%4==0
    atlas=Image.new('RGBA',(CELL*4,CELL*(len(keys)//4)))
    for i,tile in enumerate(keys):atlas.alpha_composite(tile,((i%4)*CELL,(i//4)*CELL))
    assert atlas.getchannel('A').getextrema()[0]==0
    path=OUT/out_name;atlas.save(path,optimize=True)
    return atlas

charge=load_source('charge')
punches=[]
for part in ('punch1','punch2','punch3'):punches.extend(load_source(part))
contact=load_source('contact')
mark=load_source('mark')
sheets=[write_atlas(charge,'f12_charge.png'),write_atlas(punches,'f12_meridian_waves.png'),
        write_atlas(contact,'f12_contact.png'),write_atlas(mark,'f12_six_second_mark.png')]
raw_bytes=sum(p.width*p.height*4 for p in sheets)
assert raw_bytes==19660800,raw_bytes
(OUT/'f12_r9_provenance.json').write_text(json.dumps(REPORT,indent=2,ensure_ascii=False),encoding='utf-8')
print('FIST12_R9_BAKE_PASS pages=4 poses=48 rgba_bytes=19660800 direct_alpha_sources=true no_gif=true no_rig=true')