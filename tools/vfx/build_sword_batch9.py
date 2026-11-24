#!/usr/bin/env python3
"""Bake 9 candidate 24-frame atlases from existing painted transparent source cels.
No synthetic vector effect, no image-generation claim, no gameplay authority.
Outputs only to explicitly supplied staging directory. Original 03-08 untouched.
"""
import argparse, hashlib, json, math
from pathlib import Path
from PIL import Image

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('--godot',type=Path,required=True)
    ap.add_argument('--output',type=Path,required=True)
    a=ap.parse_args()
    base=a.godot/'labs/combat_lab/sword_batch6_20261124/source'
    spec=json.loads((a.godot/'labs/combat_lab/sword_batch9_20261124/manifest.json').read_text())
    source=json.loads((base/'batch6_atlas_manifest.json').read_text())
    sheets={}
    for item in source['files']:
        p=base/item['file']
        assert hashlib.sha256(p.read_bytes()).hexdigest()==item['sha256'],p
        sheets[item['tag']]=Image.open(p).convert('RGBA')
    def cel(tag,n):
        x,y=n%4*512,n//4*512
        return sheets[tag].crop((x,y,x+512,y+512))
    def layer(dst,im,scale=1.,angle=0.,offset=(0,0),tint=(1.,1.,1.),alpha=1.):
        box=im.getchannel('A').getbbox()
        if box is None:return
        im=im.crop(box)
        w,h=im.size
        im=im.resize((max(1,round(w*scale)),max(1,round(h*scale))),Image.Resampling.LANCZOS)
        if angle: im=im.rotate(angle,resample=Image.Resampling.BICUBIC,expand=True)
        channels=im.split()
        im=Image.merge('RGBA',tuple(ch.point(lambda x,minv=minv: min(255,round(x*minv))) for ch,minv in zip(channels,(*tint,alpha))))
        dst.alpha_composite(im,(round((512-im.width)/2+offset[0]),round((512-im.height)/2+offset[1])))
    a.output.mkdir(parents=True,exist_ok=True)
    records=[]
    for skill in spec['skills']:
        tag,style=skill['tag'],skill['style']
        atlas=Image.new('RGBA',(2048,3072))
        frames=[]
        for n in range(24):
            f=Image.new('RGBA',(512,512))
            t=n/23; envelope=math.sin(math.pi*(n+1)/25)
            if style in ('dash','travel'):
                # Draw existing painted sword/wind source, not a damage burst.
                for j in range(3 if style=='dash' else 2):
                    layer(f,cel('06',9+j),0.60-j*.13,-8+2*j,(-j*48,12*j), (1.05,.86,.65) if style=='dash' else (.72,1.12,1.05),envelope*(1-j*.23))
            elif style=='heavy':
                if n<7: layer(f,cel('05',min(n,5)),.80,0,(0,10),(1.14,.92,.64),.90)
                elif n<17:
                    layer(f,cel('08',min(15,n)),1.04, -25,(0,0),(1.18,.90,.62),1.)
                    layer(f,cel('06',11),.85,-65,(0,-42),(1.18,.96,.68),.85)
                else: layer(f,cel('05',min(21,n)),1.02,0,(0,0),(1.20,.91,.66),1.)
            elif style in ('self_shield','ally_shield','realm'):
                # Existing transparent crescent sprites form a protective orbit, no enemy-contact flash.
                count={'self_shield':2,'ally_shield':3,'realm':4}[style]
                for j in range(count):
                    ang=360*j/count+t*100
                    radius=28 if style=='self_shield' else (48 if style=='ally_shield' else 65)
                    layer(f,cel('08',11+j%3),.49 if style!='realm' else .62,ang,(radius*math.cos(math.radians(ang)),radius*.54*math.sin(math.radians(ang))),(.78,1.15,1.04) if style!='realm' else (1.18,1.02,.66),envelope*.85)
                if style=='realm': layer(f,cel('05',12),.75,0,(0,0),(1.12,1.03,.77),envelope*.55)
            elif style=='counter':
                layer(f,cel('08',n),.76,18 if n<12 else -18,(0,0),(.93,1.10,.95),1.)
                if 17<=n<=21: layer(f,cel('05',n),.32,0,(15,0),(.90,1.10,1.0),.75)
            elif style=='line_guard':
                for j in range(2):
                    layer(f,cel('03',n),.58,0,(j*74-37,j*22-11),(1.10,1.06,.71),.90)
            else:
                layer(f,cel('08',n),.55,-15,(0,0),(.95,1.03,1.04),.95)
            assert f.getchannel('A').getbbox(),(tag,n)
            frames.append(hashlib.sha256(f.tobytes()).hexdigest())
            atlas.alpha_composite(f,(n%4*512,n//4*512))
        assert len(set(frames))>=8,tag
        p=a.output/f'sword_{tag}_24f.png';atlas.save(p,optimize=True)
        records.append({'tag':tag,'id':skill['id'],'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'frames':24,'unique_frames':len(set(frames)),'approval':'PENDING'})
    (a.output/'generated_manifest.json').write_text(json.dumps({'source_status':spec['source_status'],'pve':'HOLD','files':records},indent=2))
    print('BATCH9_DERIVED_CANDIDATES_GENERATED=9/9 frames=216 PvE=HOLD')
if __name__=='__main__':main()
