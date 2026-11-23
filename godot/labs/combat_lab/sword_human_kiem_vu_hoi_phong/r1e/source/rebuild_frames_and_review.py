from PIL import Image, ImageDraw, ImageFont
from pathlib import Path
import numpy as np, hashlib, json, zipfile, os
SRC=Path('/mnt/data/a_high_quality_game_vfx_sprite_sheet_animation_a.png')
OUT=Path('/mnt/data/KVHP_R1E_VFX_ONLY')
OUT.mkdir(exist_ok=True)
src=Image.open(SRC).convert('RGBA')
W,H=src.size
assert (W,H)==(1774,887)
names=['charge_01','charge_02','charge_03','release','gyre_01','gyre_02','gyre_03','gyre_04','contact','shock','fade_01','fade_02']
frames=[];checks=[]
for i,name in enumerate(names):
    col,row=i%4,i//4
    x0=round(col*W/4);x1=round((col+1)*W/4)
    y0=round(row*H/3);y1=round((row+1)*H/3)
    cell=src.crop((x0,y0,x1,y1))
    rgba=np.array(cell)
    # The direct sprite sheet has numbered editorial chips in each cell's
    # upper-left corner.  Erase these separate chips (not a poster crop).
    # No animation pixel extends into this corner in original source.
    rgba[:63,:108,:]=0
    # Remove nearly transparent low-level black RGB scanner residue
    alpha=rgba[:,:,3]
    rgba[alpha<=7]=0
    # Remove the AI renderer's black matte through emissive-alpha unmatting.
    # This is VFX-only sprite-sheet compositing, NOT extracted poster artwork.
    rgb=rgba[:,:,:3].astype(np.float32)
    orig_a=rgba[:,:,3].astype(np.float32)/255.0
    m=rgb.max(axis=2)
    power=np.clip((m-9.0)/(255.0-9.0),0,1)
    eff_a=np.clip((power**1.40)*orig_a,0,1)
    out_rgb=(rgb*255.0/np.maximum(m[:,:,None],1.0))
    rgba[:,:,:3]=np.clip(out_rgb,0,255).astype('uint8')
    rgba[:,:,3]=np.clip(eff_a*255,0,255).astype('uint8')
    rgba[rgba[:,:,3]<=6]=0
    cell=Image.fromarray(rgba,'RGBA')
    # Preserve original 1.5:1 effect proportions, no distortion.
    new_width=480
    new_height=round(cell.height*new_width/cell.width)
    item=cell.resize((new_width,new_height), Image.Resampling.LANCZOS)
    # transparent safe padding on all sides
    canvas=Image.new('RGBA',(512,512),(0,0,0,0))
    canvas.alpha_composite(item,((512-new_width)//2,(512-new_height)//2))
    a=np.array(canvas.getchannel('A'))
    bbox=canvas.getchannel('A').getbbox()
    clear=bool(bbox and min(bbox[0],bbox[1],512-bbox[2],512-bbox[3])>=8)
    n=int((a>12).sum())
    p=OUT/f'kvhp_r1e_{i+1:02}_{name}.png'
    canvas.save(p,optimize=True)
    checks.append({'frame':i+1,'name':name,'bbox':bbox,'nonzero_alpha_pixels':n,'border_8px_clear':clear,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
    frames.append(canvas)
atlas=Image.new('RGBA',(2048,1536),(0,0,0,0))
for i,frame in enumerate(frames):atlas.alpha_composite(frame,((i%4)*512,(i//4)*512))
atlas.save(OUT/'KVHP_R1E_VFX_only_atlas_4x3_RGBA.png',optimize=True)
# Source and contact light/dark previews @ actual 1x 174px sprite footprint.
contact=Image.new('RGB',(4*220+25,6*222+95),(19,27,40))
draw=ImageDraw.Draw(contact)
draw.text((15,14),'R1E DIRECT AI VFX-ONLY | SOURCE FRAMES | 1x @ 174px',fill=(225,240,253))
draw.text((15,32),'NO CHARACTER / NO POSTER / DARK-LIGHT QA',fill=(154,191,213))
for bgnum,bg in enumerate([(20,32,46),(218,226,220)]):
    for i,frame in enumerate(frames):
        row=i//4+3*bgnum;col=i%4
        x=15+col*220;y=67+row*222
        tile=Image.new('RGBA',(200,200),bg+(255,))
        sprite=frame.resize((174,174),Image.Resampling.LANCZOS)
        tile.alpha_composite(sprite,(13,10))
        contact.paste(tile.convert('RGB'),(x,y))
        draw.text((x+4,y+202),f'{i+1:02d} {names[i]} | '+('DARK' if not bgnum else 'LIGHT'),fill=(235,242,249) if not bgnum else (204,214,227))
contact.save(OUT/'G3_R1E_dark_light_1x.png',optimize=True)
# Two GIF review types, 1x 174px, no fake runtime claim.
for bgname,bg in [('dark',(20,32,46)),('light',(218,226,220))]:
    seq=[]
    for i,frame in enumerate(frames):
        tile=Image.new('RGBA',(174,174),bg+(255,))
        tile.alpha_composite(frame.resize((174,174),Image.Resampling.LANCZOS))
        seq.append(tile.convert('RGB'))
    seq[0].save(OUT/f'KVHP_R1E_VFX_only_1x_{bgname}.gif',save_all=True,append_images=seq[1:],duration=[130,130,150,100,100,100,100,110,150,140,180,240],loop=0,optimize=True)
seq=[]
for i,frame in enumerate(frames):
    f=Image.new('RGB',(368,194),(19,28,40))
    for j,bg in enumerate([(20,32,46),(218,226,220)]):
        tile=Image.new('RGBA',(174,174),bg+(255,))
        tile.alpha_composite(frame.resize((174,174),Image.Resampling.LANCZOS))
        f.paste(tile.convert('RGB'),(8+185*j,8))
    dr=ImageDraw.Draw(f);dr.text((10,181),f'{i+1:02d} '+names[i],fill=(226,238,255))
    seq.append(f)
seq[0].save(OUT/'KVHP_R1E_VFX_only_1x_dark_light.gif',save_all=True,append_images=seq[1:],duration=[130,130,150,100,100,100,100,110,150,140,180,240],loop=0,optimize=True)
metadata={
 'name':'Kiếm Vũ Hồi Phong Nhân | R1E VFX-ONLY candidate',
 'source_type':'AI-drawn 12-panel VFX-only sprite sheet, NOT cut from poster, NOT player character',
 'source_image':SRC.name,
 'source_px':[W,H],
 'number_markers':'AI sheet had numbered corner tags which were excluded in direct sprite-sheet cell extraction',
 'alpha':'AI RGB black matte converted by emissive unmatting to transparent RGBA, frame-number corner chips removed; source alpha retained as upper bound',
 'pose_count':12,'atlas_px':[2048,1536], 'frame_px':[512,512],
 'preview_scale_px':174,'technical_pass':all(i['border_8px_clear'] and i['nonzero_alpha_pixels']>0 for i in checks) and len(set(c['sha256'] for c in checks))==12,
 'gates':{'G3':'ART_OWNER_REVIEW_REQUIRED','godot':'NOT_EXECUTED','pve':'HOLD','pr72':'UNCHANGED'},
 'frames':checks,
 'limitations':['AI-generated image requires owner art approval and consistency inspection','No in-engine actor/socket/contact proof','Source sheet already had graphic frame-number tags; those were masked from the individual sprites','GIF timing is illustrative only, not canonical cast or cooldown'],
}
(OUT/'R1E_SOURCE_QA.json').write_text(json.dumps(metadata,ensure_ascii=False,indent=2),encoding='utf-8')
zip_path=Path('/mnt/data/KVHP_R1E_VFX_ONLY_source.zip')
with zipfile.ZipFile(zip_path,'w',compression=zipfile.ZIP_DEFLATED) as z:
    for p in sorted(OUT.iterdir()):z.write(p,arcname=p.name)
print(json.dumps({'out':str(OUT),'zip':str(zip_path),'technical_pass':metadata['technical_pass'],'checks':checks,'atlas_sha256':hashlib.sha256((OUT/'KVHP_R1E_VFX_only_atlas_4x3_RGBA.png').read_bytes()).hexdigest()},ensure_ascii=False))
