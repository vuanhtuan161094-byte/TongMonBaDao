#!/usr/bin/env python3
"""E2E mechanical scalability check, with PURPOSELY NOT production art.
Creates 24 state-direction clips from a tiny generic fixture, exports two
outfits and two interchangeable swords using just 4 shared weapon pose cels.
No skeleton, no gameplay, no owner-approved art, no Godot engine invocation.
"""
import argparse
import hashlib
import json
import shutil
import sys
import tempfile
import time
from pathlib import Path
from PIL import Image, ImageDraw

THIS=Path(__file__).resolve()
sys.path.insert(0,str(THIS.parent))
sys.path.insert(0,str(THIS.parents[1]/'tests'))
from build_modular import export, STATES, DIRECTIONS
import test_modular

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--out',required=True,type=Path)
    args=parser.parse_args()
    out=args.out.resolve(); out.mkdir(parents=True,exist_ok=True)
    fixture=test_modular.TestModular('test_real_atlases_two_swappable_weapons')
    fixture.setUp()
    try:
        source=out/'_TECHNICAL_FIXTURE_ONLY';source.mkdir(exist_ok=True)
        for filename in fixture.root.glob('*.png'):
            shutil.copy2(filename,source/filename.name)
        # Make a 4th sample deliberately not a real character to test export plumbing.
        for key in ('body','underwear','inner','blue','gold','eye','eye_alt','hair','hair_alt'):
            original=source/f'{key}_0.png'
            img=Image.open(original).copy()
            ImageDraw.Draw(img).rectangle((60,80,62,81),fill=(185,80,72,255))
            img.save(source/f'{key}_3.png')
        weapon_library={}
        for item,color in [('jian_blue',(80,200,250,255)),('jian_gold',(225,195,110,255))]:
            poses={}
            for pname,offset in [('guard',(82,44)),('slash',(87,69))]:
                filename=f'{item}_{pname}_reusable.png'; img=Image.new('RGBA',(128,128))
                ImageDraw.Draw(img).line([(64,64),offset],fill=color,width=2)
                ImageDraw.Draw(img).rectangle((63,63,66,66),fill=(224,225,232,255))
                img.save(source/filename)
                poses[pname]={'front':filename,'grip':[64,64]}
            weapon_library[item]={'family':'jian','poses':poses}
        spec={'schema':'tmb.modular.no_rig.1','actor_id':'feasibility_lab',
              'canvas':[128,128],'foot_pivot':[64,104],
              'status':'LAB','weapon_family':'jian','weapon_library':weapon_library,'frames':[]}
        for state in STATES:
            for direction in DIRECTIONS:
                for i in range(4):
                    sockx=75+i
                    f={
                        'state':state,'direction':direction,'index':i,
                        'layers':{'body_base':f'body_{i}.png','underwear':f'underwear_{i}.png',
                                  'outfit_inner':f'inner_{i}.png','outfit_outer':f'blue_{i}.png',
                                  'eyes':f'eye_{i}.png','hair_back':f'hair_{i}.png'},
                        'variants':{
                          'outfits':{'cobalt':{'outfit_outer':f'blue_{i}.png'},'golden':{'outfit_outer':f'gold_{i}.png'}},
                          'faces':{'calm':{'eyes':f'eye_{i}.png'},'focused':{'eyes':f'eye_alt_{i}.png'}},
                          'hairs':{'dark':{'hair_back':f'hair_{i}.png'},'silver':{'hair_back':f'hair_alt_{i}.png'}}
                         },
                        'anchors':{'foot_root':[64,104],'head_center':[54,30],
                                   'hand_r_grip':[sockx,66],'hand_l_grip':[42,65]},
                        'weapon_pose':'guard' if i%2==0 else 'slash'}
                    spec['frames'].append(f)
        input_path=source/'actor.json'
        input_path.write_text(json.dumps(spec,indent=2),encoding='utf8')
        results={}
        for outfit in ('cobalt','golden'):
            target=out/f'export_{outfit}'
            t=time.perf_counter()
            manifest=export(input_path,target,f'res://labs/character_family/as_char40_modular/proof/export_{outfit}',{'outfits':outfit,'faces':'calm','hairs':'silver'})
            duration=round(time.perf_counter()-t,3)
            results[outfit]={'seconds':duration,'clip_count':manifest['clip_count'],
                             'source_frame_count':manifest['source_frame_count'],
                             'spriteframe_resources':len(manifest['spriteframes']),
                             'weapon_items':manifest['weapon_items'],
                             'pose_bank_cels':sum(len(e['poses']) for e in weapon_library.values()),
                             'weapon_atlases':len([p for p in target.glob('*.png') if '__jian_' in p.name]),
                             'preview_gifs':len(list(target.glob('*.gif'))),
                             'exports_megabytes':round(sum(p.stat().st_size for p in target.iterdir() if p.is_file())/1_000_000,3),
                             'art_approved':manifest['art_approved'],
                             'godot_runtime_pass':manifest['godot_runtime_pass']}
        body_name='feasibility_lab__body__walk_front.png'
        wb='feasibility_lab__jian_blue_front__walk_front.png'
        results['invariants']={
            'outfit_changes_body_pixels':hashlib.sha256((out/'export_cobalt'/body_name).read_bytes()).hexdigest()!=hashlib.sha256((out/'export_golden'/body_name).read_bytes()).hexdigest(),
            'outfit_does_not_change_weapon_pixels':(out/'export_cobalt'/wb).read_bytes()==(out/'export_golden'/wb).read_bytes(),
            'no_runtime_rig':True,
            'drawn_24_real_human_motion_clips':False,
            'native_pixel_master_approved':False,
            'godot_engine_tested':False,
            'input_is_technical_fixture_not_character':True}
        results['original_source_frames_required']=len(spec['frames'])
        results['outfit_layer_pose_files_minimum']=len(STATES)*len(DIRECTIONS)*4 # per outfit, per actor, for this example
        results['applicability']='TECHNICAL AUTOMATION FEASIBLE; ART MOTION QUALITY UNPROVEN'
        (out/'RESULTS.json').write_text(json.dumps(results,indent=2,ensure_ascii=False),encoding='utf8')
        print(json.dumps(results,indent=2))
    finally:
        fixture.doCleanups()

if __name__=='__main__':main()
