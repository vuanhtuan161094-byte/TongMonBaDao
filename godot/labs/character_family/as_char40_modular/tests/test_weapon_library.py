"""Demonstrates weapon reuse without item × animation-frame authored sprites.
All source images are temporary TECHNICAL FIXTURES, not production character art.
"""
import hashlib
import json
import sys
import tempfile
import unittest
from pathlib import Path
from PIL import Image, ImageDraw, ImageSequence
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'tools'))
from build_modular import export, AssetError
import test_modular

class ReusableWeaponLibraryProof(unittest.TestCase):
    def setUp(self):
        self.fixture=test_modular.TestModular('test_real_atlases_two_swappable_weapons')
        self.fixture.setUp()
        self.addCleanup(self.fixture.doCleanups)
        self.root=self.fixture.root
        self.spec=self.fixture.spec
        for item, color in [('jian_blue',(44,210,243,255)),('jian_gold',(252,184,68,255))]:
            poses={}
            for pose in ['guard','slash']:
                name=f'{item}_{pose}_reusable.png'
                img=Image.new('RGBA',(128,128))
                dr=ImageDraw.Draw(img)
                tip=(82,43) if pose=='guard' else (91,65)
                dr.line([(64,64),tip],fill=color,width=2)
                dr.rectangle((63,63,67,66),fill=(214,214,217,255))
                img.save(self.root/name)
                poses[pose]={'grip':[64,64],'front':name}
            self.spec.setdefault('weapon_library',{})[item]={'family':'jian','poses':poses}
        for f in self.spec['frames']:
            f['weapons']={}
            f['weapon_pose']='guard' if f['index']%2==0 else 'slash'
        self.fixture.save_spec()
    def test_reusable_pose_bank_generates_valid_atlases_and_preview(self):
        r=export(self.fixture.manifest,self.root/'out','res://lab/out',{})
        self.assertEqual(r['weapon_mode'],'reusable_pose_library')
        self.assertEqual(r['source_frame_count'],3)
        self.assertEqual(len(r['weapon_items']),2)
        self.assertEqual(len([x for x in r['sources_sha256'] if 'reusable.png' in x]),4)
        self.assertEqual(len(r['spriteframes']),5)
        pix=Image.open(self.root/'out'/'test_actor__jian_blue_front__walk_front.png')
        self.assertEqual(pix.size,(384,128))
        for i in range(3):
            gp=self.spec['frames'][i]['anchors']['hand_r_grip']
            # The native grip on sword artwork is at (64,64). Its guard pixel
            # gets translated to exactly the frame's right-hand grip.
            self.assertGreater(pix.getpixel((gp[0]+i*128,gp[1]))[3],0)
        with Image.open(self.root/'out'/'test_actor__preview__jian_gold__walk_front.gif') as g:
            self.assertEqual(getattr(g,'n_frames',1),3)
            self.assertEqual(g.info.get('loop'),0)
        self.assertFalse(r['art_approved'])
    def test_outfit_swap_changes_body_not_weapon_atlas(self):
        a=export(self.fixture.manifest,self.root/'out_a','res://lab/out_a',{'outfits':'cobalt'})
        b=export(self.fixture.manifest,self.root/'out_b','res://lab/out_b',{'outfits':'golden'})
        self.assertNotEqual((self.root/'out_a'/'test_actor__body__walk_front.png').read_bytes(),
                            (self.root/'out_b'/'test_actor__body__walk_front.png').read_bytes())
        for item in ('jian_blue','jian_gold'):
            self.assertEqual((self.root/'out_a'/f'test_actor__{item}_front__walk_front.png').read_bytes(),
                             (self.root/'out_b'/f'test_actor__{item}_front__walk_front.png').read_bytes())
    def test_reject_missing_authored_weapon_direction(self):
        del self.spec['weapon_library']['jian_blue']['poses']['slash']
        self.fixture.save_spec()
        with self.assertRaisesRegex(AssetError,'Missing authored weapon pose'):
            export(self.fixture.manifest,self.root/'out','res://lab/out',{})
    def test_reject_clipped_socket_placement(self):
        self.spec['frames'][0]['anchors']['hand_r_grip']=[118,66]
        self.fixture.save_spec()
        with self.assertRaisesRegex(AssetError,'Clipped weapon after socket'):
            export(self.fixture.manifest,self.root/'out','res://lab/out',{})

if __name__=='__main__':unittest.main()
