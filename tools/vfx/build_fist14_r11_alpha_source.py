#!/usr/bin/env python3
"""Export the exact owner-approved FIST14 R11 GIF poses as RGBA Godot atlas.

No frame synthesis, visual redesign, copied third-party art, or source mutation.
GIF was approved on dark matte; the derived alpha is an approximation and must
be visually rechecked on dark AND light game maps at 1x before native acceptance.
"""
from __future__ import annotations
import hashlib
import base64
import json
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
R = Path('godot/labs/combat_lab/fist14/r11_owner_review')
SRC = ROOT / R / 'source/FIST14_R11_ORIGINAL_OWNER_GIF.gif'
ENCODED_SOURCE = ROOT / R / 'source/FIST14_R11_ORIGINAL_OWNER_GIF.gif.b64'
RGB_MASTER = ROOT / R / 'source/fist14_r11_original_rgb_contact_sheet.png'
ATLAS = ROOT / R / 'assets/fist14_r11_rgba_atlas_4x4.png'
PROVENANCE = ROOT / R / 'source/provenance.json'
REVIEW = ROOT / R / 'review/fist14_r11_alpha_1x_dark_light.png'
APPROVED_SHA = '49ca2af9db90803a071fe629481be476cd15539b9a033eb3df3cfd6eb29b12dc'
SIZE = 309
N = 16

def sha(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()

def extract_rgba(rgb: Image.Image) -> Image.Image:
    """Undo a near-black matte, without changing authored shape/timing.

    Estimated alpha is a conservative screen-color key; original GIF is kept for
    traceability and the result is checked over dark/light to spot edge artifacts.
    """
    color = np.asarray(rgb.convert('RGB'), dtype=np.float32)
    bg = np.array([8.0, 3.0, 5.0], dtype=np.float32)
    delta = np.maximum(color - bg, 0)
    strength = np.maximum.reduce([delta[..., 0], delta[..., 1] * 1.35, delta[..., 2] * 1.20])
    alpha = np.clip((strength - 6.0) / 175.0, 0.0, 1.0) ** .84
    alpha = np.where(strength < 9.0, 0.0, alpha)
    foreground = np.divide(color - bg * (1-alpha[..., None]), np.maximum(alpha[..., None], .01))
    foreground = np.uint8(np.clip(foreground, 0, 255))
    rgba = np.dstack((foreground, np.uint8(np.round(alpha * 255))))
    rgba[rgba[...,3] == 0,:3] = 0
    return Image.fromarray(rgba, mode='RGBA')

def run() -> None:
    # GitHub stores a base64 encoding because the connector's Contents API
    # accepts UTF-8 files, not arbitrary binary. This restores exact GIF bytes.
    # Never silently replace an existing source file if its hash is wrong.
    if not SRC.exists():
        encoded = ENCODED_SOURCE.read_text(encoding='ascii').strip()
        payload = base64.b64decode(encoded, validate=True)
        assert hashlib.sha256(payload).hexdigest() == APPROVED_SHA, 'Encoded GIF differs from owner-approved source'
        SRC.parent.mkdir(parents=True,exist_ok=True)
        SRC.write_bytes(payload)
    assert sha(SRC) == APPROVED_SHA, 'Approved original GIF has changed — hard stop'
    gif = Image.open(SRC)
    assert gif.n_frames == N and gif.size == (SIZE, SIZE), 'Unexpected source dimensions/frame count'
    atlas = Image.new('RGBA', (4 * SIZE, 4 * SIZE))
    rgb_master = Image.new('RGBA', (4 * SIZE, 4 * SIZE), (0, 0, 0, 255))
    frames = []
    for i in range(N):
        gif.seek(i)
        rgb = gif.convert('RGBA')
        rgb_master.paste(rgb, ((i % 4) * SIZE, (i // 4) * SIZE))
        frame = extract_rgba(rgb.convert('RGB'))
        atlas.alpha_composite(frame, ((i % 4) * SIZE, (i // 4) * SIZE))
        frames.append(frame)
    ATLAS.parent.mkdir(parents=True, exist_ok=True)
    atlas.save(ATLAS, optimize=True)
    RGB_MASTER.parent.mkdir(parents=True,exist_ok=True)
    rgb_master.save(RGB_MASTER,optimize=True)
    # Three immutable phase atlases are exact sub-regions of the 16-frame
    # derived sheet, not new drawings. All frames remain independently authored.
    for name,first,count in [('charge',0,4),('pressure',4,8),('impact',12,4)]:
        rows = (count + 3) // 4
        sub = Image.new('RGBA',(4 * SIZE,rows * SIZE))
        for k in range(count):
            frame = frames[first+k]
            sub.alpha_composite(frame,((k%4)*SIZE,(k//4)*SIZE))
        (ATLAS.parent / f'fist14_r11_{name}_rgba.png').parent.mkdir(parents=True,exist_ok=True)
        sub.save(ATLAS.parent / f'fist14_r11_{name}_rgba.png',optimize=True)
    assert all(f.getpixel((0,0))[3] == 0 for f in frames), 'Matte bleed at corner'
    review = Image.new('RGB',(1280,720),(25,33,43))
    draw = ImageDraw.Draw(review)
    draw.rectangle((640,0,1280,720), fill=(216,226,233))
    for i, title in enumerate(('DARK MAP — REAL GAME SIZE', 'LIGHT MAP — REAL GAME SIZE')):
        x0 = i * 640
        draw.text((x0+20,22),title,fill=(240,242,244) if i == 0 else (23,42,60))
        for j,idx in enumerate((2,5,9,11,13)):
            cel = frames[idx]
            cel.thumbnail((115,115), Image.Resampling.LANCZOS)
            x = x0 + 5 + j * 126
            y = 258
            review.paste(cel,(x,y),cel)
            draw.text((x + 4,385),f'F{idx+1:02d}',fill=(240,242,244) if i == 0 else (23,42,60))
        # One 1x full native-size sprite at the intended gameplay scale (~220px).
        cel = frames[9].resize((218,218),Image.Resampling.LANCZOS)
        review.paste(cel,(x0+212,455),cel)
        draw.text((x0+20,700),'SOURCE-ONLY MATTE PROOF — NOT GODOT CAPTURE',
                  fill=(236,239,241) if i == 0 else (39,60,70))
    REVIEW.parent.mkdir(parents=True,exist_ok=True)
    review.save(REVIEW,optimize=True)
    record = {
      'schema':'tmb.fist14.owner_review_source.v1',
      'skill_id':'tmb.skill.fist.huyet_quyen.active_04.human',
      'revision':'R11', 'owner_approved_scope':'GIF_VISUAL_ONLY',
      'approval_notes':'Owner replied: ok ddungs r đấy, chốt (21 November 2026)',
      'master_gif':'source/FIST14_R11_ORIGINAL_OWNER_GIF.gif',
      'master_sha256':sha(SRC), 'master_frame_count':16, 'master_size':[SIZE,SIZE],
      'derived_rgba_atlas':'assets/fist14_r11_rgba_atlas_4x4.png',
      'atlas_sha256':sha(ATLAS), 'atlas_size':[SIZE*4,SIZE*4],
      'matte_removal':'Near-black-matte RGB to RGBA approximation; source GIF immutable',
      'frame_durations_ms':[90]*N,
      'qa':{'source_preserved':True,'frames_distinct':len({hashlib.sha256(f.tobytes()).hexdigest() for f in frames})==N,
            'g3_dark_light_review':'source_composite_only',
            'godot_native':'NOT_RUN','chrome':'NOT_RUN', 'android':'NOT_RUN',
            'owner_native':'PENDING','pve':'HOLD'},
    }
    PROVENANCE.write_text(json.dumps(record,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print('R11_SOURCE_CONVERSION_PASS', 'frames',N, 'atlas',ATLAS.stat().st_size,'sha',record['atlas_sha256'])
    print('NATIVE_GODOT_NOT_RUN / NO_GAMEPLAY_CHANGE / MATTE_REVIEW_PENDING')

if __name__ == '__main__':
    run()
