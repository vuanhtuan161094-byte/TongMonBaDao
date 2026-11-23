#!/usr/bin/env python3
"""R1E->V2 24 visual samples (12 owner-approved RGBA + 12 derived transition samples).
Source-first: NEVER crop promotional posters, NEVER invent VFX from geometry.
The 12 original AI-drawn sprite frames stay immutable; transitions use constrained
bidirectional optical-flow and premultiplied-alpha resampling. This is not
24 newly hand-painted frames and does not constitute owner art approval.
"""
from __future__ import annotations
import hashlib, json
from pathlib import Path
import cv2
import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/"godot/labs/combat_lab/sword_human_kiem_vu_hoi_phong/r1e/source"
DEST=ROOT/"godot/labs/combat_lab/sword_human_kiem_vu_hoi_phong/r1e/v2_source"
PFX="kvhp_r1e_"
TARGET_COUNT=24
DURATION_MS=40  # 24 samples / 25 fps = 0.96 s. REVIEW clock only.
def sha(p:Path)->str:
    return hashlib.sha256(p.read_bytes()).hexdigest()
def clean(im:Image.Image)->bool:
    a=np.asarray(im.getchannel("A"))
    edge=np.concatenate((a[:8].ravel(),a[-8:].ravel(),a[:,:8].ravel(),a[:,-8:].ravel()))
    return bool(np.any(a>0) and np.max(edge)==0)
def inbetween(a_im:Image.Image,b_im:Image.Image)->Image.Image:
    a=np.asarray(a_im,dtype=np.float32)/255.0
    b=np.asarray(b_im,dtype=np.float32)/255.0
    # Brightness weighted by source alpha; zero outside source artwork.
    a_gray=np.uint8(np.clip(a[:,:,:3].max(2)*a[:,:,3]*255,0,255))
    b_gray=np.uint8(np.clip(b[:,:,:3].max(2)*b[:,:,3]*255,0,255))
    flow_a=cv2.calcOpticalFlowFarneback(a_gray,b_gray,None,0.5,4,25,3,7,1.5,0)
    flow_b=cv2.calcOpticalFlowFarneback(b_gray,a_gray,None,0.5,4,25,3,7,1.5,0)
    for f in (flow_a,flow_b):
        f[:]=cv2.GaussianBlur(f,(0,0),1.1)
        magnitude=np.linalg.norm(f,axis=2)
        f*=np.minimum(1.0,18.0/np.maximum(magnitude,1e-5))[:,:,None]
    h,w=a_gray.shape
    gx,gy=np.meshgrid(np.arange(w,dtype=np.float32),np.arange(h,dtype=np.float32))
    def warped(img,flow):
        return cv2.remap(img,gx-flow[:,:,0]*0.5,gy-flow[:,:,1]*0.5,
                         cv2.INTER_LINEAR,borderMode=cv2.BORDER_CONSTANT,borderValue=0)
    pa=np.dstack((a[:,:,:3]*a[:,:,3,None],a[:,:,3]))
    pb=np.dstack((b[:,:,:3]*b[:,:,3,None],b[:,:,3]))
    out=(warped(pa,flow_a)+warped(pb,flow_b))*0.5
    alpha=np.maximum(out[:,:,3],0)
    rgb=np.divide(out[:,:,:3],alpha[:,:,None],out=np.zeros_like(out[:,:,:3]),
                  where=alpha[:,:,None]>1e-5)
    return Image.fromarray(np.uint8(np.clip(np.dstack((rgb,alpha)),0,1)*255+0.5),"RGBA")
def main()->None:
    DEST.mkdir(parents=True,exist_ok=True)
    names=sorted(SOURCE.glob("kvhp_r1e_[0-9][0-9]_*.png"))
    assert len(names)==12, "R1E originals must have precisely 12 PNG frames"
    original=[Image.open(p).convert("RGBA") for p in names]
    assert all(x.size==(512,512) and clean(x) for x in original)
    frames=[]
    provenance=[]
    for i,im in enumerate(original):
        frames.append(im)
        provenance.append({"kind":"owner_approved_original","a":i+1})
        if i<11:
            frames.append(inbetween(im,original[i+1]))
            provenance.append({"kind":"derived_motion_inbetween_not_new_art","a":i+1,"b":i+2})
    # Last one is only an alpha taper, not a newly authored artwork frame.
    faded=np.array(original[-1])
    faded[:,:,3]=np.uint8(faded[:,:,3].astype(np.float32)*0.40)
    frames.append(Image.fromarray(faded,"RGBA"))
    provenance.append({"kind":"derived_fade_from_original","a":12})
    assert len(frames)==24
    atlas=Image.new("RGBA",(2048,3072))
    for i,fr in enumerate(frames):
        assert clean(fr), f"invalid alpha/border in sample {i+1}"
        atlas.paste(fr,((i%4)*512,(i//4)*512))
    atlaspath=DEST/"R1E_V2_24_atlas_4x6_RGBA.png"
    atlas.save(atlaspath,optimize=True)
    names_out=[]
    for i,fr in enumerate(frames):
        path=DEST/f"r1e_v2_{i+1:02d}.png"
        fr.save(path,optimize=True)
        names_out.append(path)
    assert len({sha(p) for p in names_out})==24, "V2 sample hashes must be unique"
    # Honest source-only 1x preview, no actor/game screenshots implied.
    previews=[]
    for i,fr in enumerate(frames):
        f=Image.new("RGB",(368,218),(17,27,41))
        d=ImageDraw.Draw(f)
        tile_sprite=fr.resize((174,174),Image.Resampling.LANCZOS)
        for j,bg in enumerate(((17,27,41),(223,227,219))):
            tile=Image.new("RGBA",(174,174),bg+(255,))
            tile.alpha_composite(tile_sprite)
            f.paste(tile.convert("RGB"),(184*j,22))
        d.text((8,4),f"R1E V2 SOURCE 1x  {i+1:02d}/24",fill=(203,236,255))
        previews.append(f)
    previews[0].save(DEST/"R1E_V2_source_1x_dark_light.gif",save_all=True,
                     append_images=previews[1:],duration=DURATION_MS,loop=0,
                     disposal=2,optimize=False)
    meta={"schema":"tmb.vfx.r1e_v2.motion_derived.v1","original_art_frames":12,
          "derived_transition_frames":12,"total_preview_samples":24,
          "review_duration_ms":960,"preview_fps":25,"atlas_px":[2048,3072],
          "owner_source_art":"R1E_APPROVED","owner_v2_art":"REVIEW_PENDING",
          "godot_runtime":"NOT_VERIFIED","pve":"HOLD",
          "no_poster_extraction":True,"not_24_ai_painted":True,
          "original_sha256":[sha(p) for p in names],
          "atlas_sha256":sha(atlaspath),
          "frames":[{"index":i+1,"file":names_out[i].name,
                     "sha256":sha(names_out[i]),"origin":provenance[i],
                     "border_clear_8px":clean(frames[i])}
                    for i in range(24)]}
    (DEST/"R1E_V2_SOURCE_MANIFEST.json").write_text(
        json.dumps(meta,indent=2,ensure_ascii=False)+"\n",encoding="utf-8")
    print("R1E_V2_SOURCE_QA=PASS original=12 derived=12 frames=24 atlas=2048x3072 1x=174 no_poster=true PvE=HOLD")
    print("R1E_V2_ATLAS_SHA256="+sha(atlaspath))
if __name__=="__main__":
    main()
