#!/usr/bin/env python3
"""PAF06 zero-cast PASSIVE native QA. No fake 'contact' phase allowed."""
from pathlib import Path
from PIL import Image,ImageChops
import hashlib,json,argparse,sys
ROOT=Path(__file__).resolve().parents[2]
SID='tmb.skill.talisman.phong_an_phu.passive_01.human'
def ck(ok,msg):
    if not ok: raise RuntimeError('PAF06_QA_FAILED '+msg)
def assets():
    j=json.loads((ROOT/'godot/data/combat/v63_talisman_combat_catalog.json').read_text())
    r=[x for x in j['skills'] if x.get('id')==SID]
    ck(len(r)==1,'skill record exactly once')
    s=r[0]
    for k,v in {'effect':'passive','element':'wind','shape':'single_target','target_limit':1,'cast_time':0,'cooldown':0,'range':0,'radius':0,'duration':0,'projectile_speed':0,'damage_ratio':0,'ai_profile':'passive_always_on'}.items():
        ck(s.get(k)==v, 'catalogue '+k)
    ck(abs(s['passive_modifiers']['cooldown_recovery_factor']-.015)<1e-10,'modifier')
    base=ROOT/'godot/labs/combat_lab/talisman16'
    manifest=json.loads((base/'art_sources/PAF06_SOURCE_MANIFEST.json').read_text())
    ck(manifest['skill']==SID and manifest['frames_per_layer']==24,'manifest skill/poses')
    for name in ('back','front','heart'):
        f=base/'assets'/('paf06_'+name+'.webp')
        ck(f.exists(),'atlas '+name)
        with Image.open(f) as origin:im=origin.convert('RGBA')
        ck(im.size==(1920,1280),'atlas dimensions '+name)
        ck(im.getchannel('A').getextrema()[0]==0,'transparent background '+name)
        frames=[]
        for k in range(24):
            x=(k%6)*320;y=(k//6)*320
            a=im.crop((x,y,x+320,y+320))
            ck(a.getchannel('A').getextrema()[1]>=120,'occupied frame '+name+' #'+str(k))
            frames.append(hashlib.sha256(a.tobytes()).hexdigest())
        ck(len(set(frames))>=12,'no keyed morphology '+name)
        data=f.read_bytes()
        ck(manifest[name+'_atlas']['sha256']==hashlib.sha256(data).hexdigest(),'exact source hash '+name)
    print('PAF06_R1_PACKET_ASSET_TECH_PASS source_rgba=true poses_per_layer=24 fake_proc=false')
def evidence(out):
    d=Path(out)
    for f in ['paf06-r1-native.mp4','paf06-calm.png','paf06-flow.png','paf06-breath.png','paf06-off-flow.png','godot-r1.log','focused-r1.log']:
        ck((d/f).exists() and (d/f).stat().st_size>0,'missing evidence '+f)
    a=Image.open(d/'paf06-flow.png').convert('RGB')
    b=Image.open(d/'paf06-off-flow.png').convert('RGB')
    ck(a.size==b.size==(1280,720),'native resolution')
    # The two genuine Godot scenes are identical except for passive_equipped.
    # No actor animation, enemy motion or "hit" generates the difference.
    a=a.crop((485,313,773,575));b=b.crop((485,313,773,575))
    delta=ImageChops.difference(a,b).convert('RGB')
    px=list(delta.getdata())
    active=sum(1 for r,g,blue in px if max(r,g,blue)>24)
    ck(active>=350,'VFX not visible at 1x; delta-pixels='+str(active))
    report={'schema':'PAF06_PASSIVE_NATIVE_EVIDENCE','source_sha':d.joinpath('exact-sha.txt').read_text().strip(),'comparison':'ON_vs_OFF_GENUINE_GODOT_SAME_CLOCK','pixels_changed_gt24':active,'native':'1280x720','gameplay':'PASSIVE_ALWAYS_ON_NO_ACTOR_TARGET_RECEIPT','tech':'PASS','owner':'OWNER_VISUAL_PENDING','pve':'HOLD'}
    (d/'PAF06_R1_TECH_MANIFEST.json').write_text(json.dumps(report,indent=2)+'\n')
    print('PAF06_R1_G3_6_NATIVE_VISIBILITY_PASS changed_pixels='+str(active)+' owner_art=PENDING')
if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('--stage',choices=['assets','evidence'],required=True)
    p.add_argument('--out')
    args=p.parse_args()
    try:
        assets()
        if args.stage=='evidence':
            ck(args.out is not None,'--out mandatory')
            evidence(args.out)
    except Exception as e:
        print(str(e),file=sys.stderr)
        sys.exit(1)
