import io
import json
from pathlib import Path
import struct
import tempfile
import unittest
from PIL import Image
from studio import init_vault,stage_files,curated_jxqy_pilot,probe_map,map_patch,skill_graph,skill_preview,skill_visual_recipe,map_preview,safe_relpath


def make_mpc(color=(255,80,60,255)):
    i=Image.new('RGBA',(32,32),color);b=io.BytesIO();i.save(b,format='PNG');png=b.getvalue()
    a=bytearray(48);a[:15]=b'IMG File Ver1.0'
    struct.pack_into('<iii',a,16,8,8,100)
    for j in range(8): a+=struct.pack('<4i',len(png),16,28,0)+png
    return bytes(a)


def make_map():
    w,h=3,2;raw=bytearray(16512+w*h*10)
    raw[:15]=b'MAP File Ver2.0'
    struct.pack_into('<4i',raw,68,w,h,64,32)
    name='ground.mpc'.encode()
    raw[192:192+len(name)]=name
    struct.pack_into('<i',raw,224,1)
    for idx in range(w*h):raw[16512+idx*10+1]=1
    raw[16512+6]=0xc0
    return bytes(raw)


class StudioFocused(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory();self.base=Path(self.tmp.name)
        self.vault=self.base/'vault';self.src=self.base/'source';self.src.mkdir()
    def tearDown(self):self.tmp.cleanup()

    def test_init_and_stage_idempotent_immutable(self):
        d=init_vault(self.vault)
        self.assertTrue(Path(d['source_registry']).exists())
        (self.src/'bmp').mkdir();original=self.src/'bmp'/'a.png';original.write_bytes(b'first')
        s=stage_files(self.vault,'SOURCE_A',self.src,['bmp/a.png'])
        self.assertEqual(s['copied'],['bmp/a.png'])
        self.assertEqual(stage_files(self.vault,'SOURCE_A',self.src,['bmp/a.png'])['already_identical'],['bmp/a.png'])
        original.write_bytes(b'second')
        result=stage_files(self.vault,'SOURCE_A',self.src,['bmp/a.png'])
        self.assertEqual(result['conflicts_not_overwritten'],['bmp/a.png'])
        self.assertEqual((self.vault/'01_raw/SOURCE_A/bmp/a.png').read_bytes(),b'first')

    def test_no_traversal_or_unknown_extension(self):
        for bad in ['../secret.png','/etc/passwd','C:/tmp/test.png',r'a\b.png']:
            with self.assertRaises(ValueError):safe_relpath(bad)
        with self.assertRaises(ValueError):stage_files(self.vault,'INVALID-ID',self.src,['anything.png'])
        (self.src/'a.exe').write_bytes(b'abc')
        with self.assertRaises(ValueError):stage_files(self.vault,'JX1_OWNER',self.src,['a.exe'])

    def test_map_metadata_and_safe_edit(self):
        src=self.src/'demo.map';src.write_bytes(make_map())
        meta=probe_map(src)
        self.assertEqual((meta['width'],meta['height'],meta['blocked_cells']), (3,2,1))
        self.assertEqual(meta['tile_dictionary'][1],'ground.mpc')
        recipe=self.base/'edit.json';recipe.write_text(json.dumps({'source_sha256':meta['sha256'],'edits':[{'x':1,'y':0,'field':'obstacle','value':192},{'x':1,'y':1,'field':'layer0_id','value':1}]}))
        out=self.base/'edited.map'
        edited=map_patch(src,recipe,out)
        self.assertEqual(edited['edits'],2)
        self.assertTrue(edited['raw_unchanged'])
        self.assertEqual(probe_map(out)['blocked_cells'],2)
        with self.assertRaises(FileExistsError):map_patch(src,recipe,out)
        recipe.write_text(json.dumps({'source_sha256': 'BAD', 'edits':[]}))
        with self.assertRaises(ValueError):map_patch(src,recipe,self.base/'b.map')
        recipe.write_text(json.dumps({'source_sha256':meta['sha256'],'edits':[{'x':0,'y':1,'field':'layer2_id','value':99}]}))
        with self.assertRaises(ValueError):map_patch(src,recipe,self.base/'c.map')

    def test_real_mpc_map_preview(self):
        src=self.src/'demo.map';src.write_bytes(make_map())
        (self.src/'tiles').mkdir();(self.src/'tiles'/'ground.mpc').write_bytes(make_mpc())
        out=self.base/'preview.png'
        report=map_preview(src,self.src,'tiles',out)
        self.assertEqual(report['rendered_cells'],6)
        self.assertEqual(report['MPC_decoded'],1)
        self.assertTrue(out.is_file())
        with Image.open(out) as pic:self.assertGreater(pic.width,500)
        with self.assertRaises(FileNotFoundError):map_preview(src,self.src,'not_existing',self.base/'bad.png')
        cropped=map_preview(src,self.src,'tiles',self.base/'cropped.png',(1,0,2,2))
        self.assertEqual(cropped['viewport'],[1,0,2,2])
        with self.assertRaises(ValueError):map_preview(src,self.src,'tiles',self.base/'oversized.png',(0,0,400,2))

    def test_player_skill_links_and_preview(self):
        for rel,text in [
            ('save/rpg0/player.ini','[init]\nname=Player\nnpcini=z-test.ini\n'),
            ('ini/npcres/z-test.ini','[magic]\nimage=char-magic.mpc\n[astand]\nimage=char-st.mpc\n'),
            ('ini/magic/player-magic-天意剑诀.ini','[init]\nname=天意剑诀\nflyingimage=fly.mpc\nvanishimage=hit.mpc\nimage=icon.mpc\n')
        ]:
            p=self.src/rel;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(text,encoding='utf8')
        for rel in ['mpc/character/char-magic.mpc','mpc/character/char-st.mpc','mpc/effect/fly.mpc','mpc/effect/hit.mpc']:
            p=self.src/rel;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(make_mpc())
        graph=skill_graph(self.src,'天意剑诀')
        self.assertEqual(graph['visual_links']['generic_player_cast']['state'],'FOUND')
        self.assertEqual(graph['visual_links']['ui_image']['state'],'MISSING')
        path=self.base/'skill.png'
        p=skill_preview(self.src,'天意剑诀',path)
        self.assertTrue(path.exists())
        self.assertEqual(len(p['source_assets']),3)
        visual=self.base/'visual.json'
        recipe=skill_visual_recipe(self.src,'天意剑诀',{'projectile':{'offset_x':12,'offset_y':-4,'scale':1.2}},visual)
        self.assertEqual(recipe['status'],'DERIVED_VISUAL_RECIPE_UNPUBLISHED')
        self.assertFalse(json.loads(visual.read_text())['gameplay_change'])
        with self.assertRaises(FileExistsError):skill_visual_recipe(self.src,'天意剑诀',{'projectile':{'offset_x':2}},visual)
        with self.assertRaises(ValueError):skill_visual_recipe(self.src,'天意剑诀',{'damage':{'offset_x':2}},self.base/'bad-recipe.json')
        curated=curated_jxqy_pilot(self.src)
        self.assertIn('mpc/character/char-st.mpc',curated)
        self.assertIn('ini/magic/player-magic-天意剑诀.ini',curated)
        staged=stage_files(self.vault,'JXQY2_OFFLINE',self.src,curated)
        self.assertEqual(len(staged['copied']),len(curated))

if __name__=='__main__':unittest.main()