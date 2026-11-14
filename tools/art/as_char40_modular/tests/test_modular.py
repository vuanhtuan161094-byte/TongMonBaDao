import copy
import hashlib
import json
import sys
import tempfile
import unittest
from pathlib import Path
from PIL import Image, ImageDraw

sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'tools'))
from build_modular import export, AssetError

class TestModular(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root=Path(self.temp.name)
        self.manifest=self.root/'actor.json'
        self.spec={'schema':'tmb.modular.no_rig.1','actor_id':'test_actor',
            'canvas':[128,128],'foot_pivot':[64,104],'status':'LAB','weapon_family':'jian','frames':[]}
        for i in range(3):
            sock_x=76+i
            body=self.paint(f'body_{i}',(15,24,76,102),(36,47,68,255))
            underwear=self.paint(f'underwear_{i}',(41+i,68,63+i,98),(56,88,113,255))
            inner=self.paint(f'inner_{i}',(39,42,72,76),(85,122,157,255))
            blue=self.paint(f'blue_{i}',(38,53,75,87),(49,71,129,255))
            gold=self.paint(f'gold_{i}',(38,53,75,87),(119,87,52,255))
            eye=self.paint(f'eye_{i}',(50,37,57,38),(180,210,245,255))
            alt_eye=self.paint(f'eye_alt_{i}',(54,37,59,38),(180,210,245,255))
            hair=self.paint(f'hair_{i}',(30,20,66,34),(80,84,117,255))
            alt_hair=self.paint(f'hair_alt_{i}',(29,19,67,36),(166,173,188,255))
            swords={}
            for item,col in [('jian_blue',(80,220,255,255)),('jian_gold',(230,182,64,255))]:
                swords[item]={"family":"jian", "grip":[sock_x,66],
                    "front":self.paint(f'{item}_{i}',(sock_x,66,sock_x+21,70),col)}
            self.spec['frames'].append({'state':'walk','direction':'front','index':i,
                'layers':{'body_base':body,'underwear':underwear,'outfit_inner':inner,'outfit_outer':blue,'eyes':eye,'hair_back':hair},
                'variants':{
                    'outfits':{'cobalt':{'outfit_outer':blue},'golden':{'outfit_outer':gold}},
                    'faces':{'calm':{'eyes':eye},'focused':{'eyes':alt_eye}},
                    'hairs':{'dark':{'hair_back':hair},'silver':{'hair_back':alt_hair}}},
                'anchors':{'foot_root':[64,104],'head_center':[54,30],
                           'hand_r_grip':[sock_x,66],'hand_l_grip':[41,64]},'weapons':swords})
        self.save_spec()
    def paint(self,name,rect,color):
        filename=name+'.png'
        im=Image.new('RGBA',(128,128))
        ImageDraw.Draw(im).rectangle(rect,fill=color)
        im.save(self.root/filename)
        return filename
    def save_spec(self):
        self.manifest.write_text(json.dumps(self.spec),encoding='utf8')
    def doexport(self,where='out',**selected):
        return export(self.manifest,self.root/where,'res://labs/character_family/as_char40_modular/out',selected)
    def test_real_atlases_two_swappable_weapons(self):
        m=self.doexport()
        self.assertEqual(m['clip_count'],1)
        self.assertEqual(m['source_frame_count'],3)
        self.assertEqual(len(m['spriteframes']),5) # 1 body + 2 items x front/back
        self.assertEqual(m['weapon_items'],['jian_blue','jian_gold'])
        self.assertFalse(m['art_approved'])
        out=self.root/'out'
        for i in range(3):
            src=Image.open(self.root/f'jian_blue_{i}.png')
            sheet=Image.open(out/'test_actor__jian_blue_front__walk_front.png')
            self.assertEqual(sheet.crop((i*128,0,(i+1)*128,128)).tobytes(),src.tobytes())
        self.assertNotEqual((out/'test_actor__jian_gold_front__walk_front.png').read_bytes(),
                            (out/'test_actor__jian_blue_front__walk_front.png').read_bytes())
    def test_outfit_and_face_swap_without_changing_weapon(self):
        default=self.doexport('out1')
        variant=self.doexport('out2',outfits='golden',faces='focused',hairs='silver')
        name='test_actor__body__walk_front.png'
        self.assertNotEqual((self.root/'out1'/name).read_bytes(),(self.root/'out2'/name).read_bytes())
        w='test_actor__jian_blue_front__walk_front.png'
        self.assertEqual((self.root/'out1'/w).read_bytes(),(self.root/'out2'/w).read_bytes())
        self.assertFalse(default['art_approved'] or variant['art_approved'])
    def test_reject_fake_or_missing_outfit_variant(self):
        with self.assertRaisesRegex(AssetError,'Missing authored outfits variant'):
            self.doexport(outfits='unpainted')
    def test_reject_missing_frame(self):
        self.spec['frames'][1]['layers']['body_base']='missing.png';self.save_spec()
        with self.assertRaisesRegex(AssetError,'Missing artist-authored PNG'):
            self.doexport()
    def test_reject_partial_alpha(self):
        im=Image.open(self.root/'body_0.png');im.putpixel((25,25),(20,30,40,100));im.save(self.root/'body_0.png')
        with self.assertRaisesRegex(AssetError,'antialiased alpha'):
            self.doexport()
    def test_reject_bad_grip(self):
        self.spec['frames'][0]['weapons']['jian_blue']['grip']=[90,66];self.save_spec()
        with self.assertRaisesRegex(AssetError,'grip disconnected'):
            self.doexport()
    def test_reject_fake_walk_frame_indices(self):
        self.spec['frames'][1]['index']=10;self.save_spec()
        with self.assertRaisesRegex(AssetError,'Non-contiguous'):
            self.doexport()
    def test_reject_unauthorised_approval(self):
        self.spec['status']='OWNER_ART_APPROVED';self.save_spec()
        with self.assertRaisesRegex(AssetError,'approval cannot be self asserted'):
            self.doexport()
    def test_reject_incomplete_approval(self):
        self.spec['status']='OWNER_ART_APPROVED';self.spec['approval_evidence']='owner linked approval';self.save_spec()
        with self.assertRaisesRegex(AssetError,'complete 24'):
            self.doexport()
    def test_reject_embedded_weapon(self):
        self.spec['frames'][0]['layers']['weapon']='body_0.png';self.save_spec()
        with self.assertRaisesRegex(AssetError,'baked weapon'):
            self.doexport()
    def test_reject_non_rgba_source(self):
        p=self.root/'body_0.png';Image.open(p).convert('RGB').save(p)
        with self.assertRaisesRegex(AssetError,'Native RGBA'):
            self.doexport()
    def test_reject_incompatible_weapon_family(self):
        self.spec['frames'][0]['weapons']['jian_blue']['family']='spear';self.save_spec()
        with self.assertRaisesRegex(AssetError,'motion pack'):
            self.doexport()
    def test_reject_duplicate_body_frames(self):
        self.spec['frames'][1]['layers']=dict(self.spec['frames'][0]['layers'])
        self.spec['frames'][2]['layers']=dict(self.spec['frames'][0]['layers'])
        self.save_spec()
        with self.assertRaisesRegex(AssetError,'fake motion'):
            self.doexport()
    def test_no_skeleton_godot_and_exact_frame(self):
        self.doexport()
        r=(self.root/'out'/'test_actor__body.tres').read_text('utf8')
        self.assertNotIn('Skeleton2D',r)
        self.assertNotIn('Bone2D',r)
        self.assertIn('walk_front',r)
        self.assertIn('region = Rect2(256, 0, 128, 128)',r)
        self.assertEqual(r.count('SubResource("a'),3)

if __name__ == '__main__':unittest.main()