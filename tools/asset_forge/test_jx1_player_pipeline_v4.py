"""AF-04 synthetic binary tests; character/table names match verified SourceInit-JX1 records.
THE FIXTURES ARE NOT GAME ASSET QA.
"""
import json
import struct
import tempfile
import unittest
from pathlib import Path

from jx1_pak_v2 import jx1_path_hash
from jx1_player_pipeline_v4 import catalog_equipment_variants,catalog_selected_player,render_player_sheet,_sort_for
from test_jx1_adapter import sprite


def fixture(root:Path,missing_pack:bool=False,wrong_kind:bool=False):
    tables=root/'settings/npcres'
    tables.mkdir(parents=True)
    # Actual column order/role names observed in original source's 人物类型.txt.
    kind='人物名称\t人物类型\t资源文件路经\t部件说明文件名\t动作贴图顺序表\t躯体\t右手武器\n'
    kind+='男主角\t'+('普通npc' if wrong_kind else '特殊npc')+'\tspr\\npcres\\man\t男主角部件列表.txt\tsort.ini\t男主角躯体.txt\t男主角右手武器.txt\n'
    (tables/'人物类型.txt').write_bytes(kind.encode('gb18030'))
    (tables/'男主角部件列表.txt').write_text('序号\t组成\t部件1\t部件2\t部件3\t部件4\n'
          '0\t头盔\t\t\t\t\n'
          '1\t装备\t\t躯体\t\t\n'
          '2\t武器\t\t右手武器\t\t\n'
          '3\t马\t\t\t\t\n',encoding='utf-8')
    (tables/'男主角躯体.txt').write_text('装备名称\t空手站立1\n躯体01\tMA_BD_001_ST01.spr\n躯体02\tMA_BD_002_ST01.spr\n',encoding='utf-8')
    (tables/'男主角右手武器.txt').write_text('装备名称\t空手站立1\n空手\tMA_RW_000_ST01.spr\n单手剑1\tMA_RW_001_ST01.spr\n',encoding='utf-8')
    # DIR1 draws body then right-hand weapon; DIR2 reverse, both source-referenced.
    sort='[DEFAULT]\n'+''.join(f'Dir{i}=-1,{"5,9" if i%2 else "9,5"},\n' for i in range(1,17))
    (tables/'sort.ini').write_text(sort,encoding='utf-8')
    graphics=root/'spr/npcres/man'
    graphics.mkdir(parents=True)
    body=sprite(dirs=8)
    weapon=sprite(runs=((4,255,[2,2,2,2]),),dirs=8)
    (graphics/'MA_BD_001_ST01.spr').write_bytes(body)
    (graphics/'MA_BD_002_ST01.spr').write_bytes(body)
    (graphics/'MA_RW_000_ST01.spr').write_bytes(weapon)
    pack=root/'only_one.pak'
    virt='\\spr\\npcres\\man\\MA_RW_001_ST01.spr'
    uid=jx1_path_hash(virt)
    if not missing_pack:
        pack.write_bytes(struct.pack('<4s4I12s',b'PACK',1,32+len(weapon),32,0,b'')+
                         weapon+struct.pack('<4I',uid,32,len(weapon),len(weapon)))
    return pack


class AF04PipelineTests(unittest.TestCase):
    def test_full_chain_binary_source_8_directions_two_variants(self):
        with tempfile.TemporaryDirectory() as td:
            root=Path(td);pak=fixture(root)
            choices={'躯体':1,'右手武器':1}
            r=catalog_selected_player(root,'男主角','空手站立1',choices,[pak])
            self.assertEqual(r['directions'],8)
            self.assertEqual(len(r['selected']),2)
            self.assertEqual({x['source']['source'] for x in r['selected']},{'PACK_ID','LOOSE_SPR'})
            self.assertEqual(r['playable_source_proof']['kind_value'],'特殊npc')
            self.assertEqual([x['label'] for x in r['selected']],['躯体','右手武器'])
            try:from PIL import Image
            except ImportError:self.skipTest('Pillow unavailable')
            target=root/'output/sheet.png'
            out=render_player_sheet(r,target,0,8)
            self.assertTrue(target.is_file())
            self.assertEqual(len(out['rendered_directions']),8)
            self.assertNotEqual(out['rendered_directions'][0]['source_sort_order'],out['rendered_directions'][1]['source_sort_order'])
            self.assertEqual(out['png_sha256'],__import__('hashlib').sha256(target.read_bytes()).hexdigest())
            meta=json.loads(target.with_suffix('.json').read_text(encoding='utf-8'))
            self.assertIn('VISUAL_PENDING',meta['status'])
            with Image.open(target) as img:self.assertEqual(img.size,(944,520))
            with self.assertRaises(FileExistsError):render_player_sheet(r,target,0,8)

    def test_real_names_catalog_only_does_not_need_pack_sprites(self):
        with tempfile.TemporaryDirectory() as td:
            root=Path(td);fixture(root)
            result=catalog_equipment_variants(root,'男主角','空手站立1',[])
            self.assertEqual(result['variants_found'],4)
            body=next(x for x in result['groups'] if x['label']=='躯体')
            self.assertEqual(body['available_variants'][1]['name'],'躯体02')
            self.assertEqual(body['available_variants'][0]['virtual_path'],'\\spr\\npcres\\man\\MA_BD_001_ST01.spr')
            self.assertIn('SPR_RENDER_AND_OWNER_QA_PENDING',result['status'])

    def test_reject_other_composite_and_normal_npc(self):
        with tempfile.TemporaryDirectory() as td:
            root=Path(td);fixture(root)
            with self.assertRaisesRegex(ValueError,'playable proof missing'):
                catalog_selected_player(root,'enemy003','空手站立1',{},[])
        with tempfile.TemporaryDirectory() as td:
            root=Path(td);fixture(root,wrong_kind=True)
            with self.assertRaisesRegex(ValueError,'unresolved'):
                catalog_selected_player(root,'男主角','空手站立1',{},[])

    def test_reject_pack_absent_unknown_variant_and_sort(self):
        with tempfile.TemporaryDirectory() as td:
            root=Path(td);fixture(root,missing_pack=True)
            with self.assertRaises(FileNotFoundError):
                catalog_selected_player(root,'男主角','空手站立1',{'右手武器':1},[])
            with self.assertRaisesRegex(ValueError,'variant'):
                catalog_selected_player(root,'男主角','空手站立1',{'躯体':1000},[])
            with self.assertRaisesRegex(ValueError,'unknown source'):
                catalog_selected_player(root,'男主角','空手站立1',{'fake':1},[])

    def test_reject_source_pack_mismatch(self):
        with tempfile.TemporaryDirectory() as td:
            root=Path(td);pak=fixture(root)
            local=root/'spr/npcres/man/MA_RW_001_ST01.spr'
            local.write_bytes(sprite(dirs=8))
            with self.assertRaisesRegex(ValueError,'mismatch'):
                catalog_selected_player(root,'男主角','空手站立1',{'右手武器':1},[pak])

    def test_localhost_studio_af04_catalog_and_sheet(self):
        import contextlib
        import http.client
        import socket
        import threading
        import time
        from web_ui import serve
        with tempfile.TemporaryDirectory() as td:
            root=Path(td)/'jx_source';root.mkdir()
            pak=fixture(root)
            vault=Path(td)/'vault'
            with socket.socket() as sk:
                sk.bind(('127.0.0.1',0));port=sk.getsockname()[1]
            runner=threading.Thread(target=serve,args=(vault,port),daemon=True)
            runner.start()
            for _ in range(100):
                try:
                    client=http.client.HTTPConnection('127.0.0.1',port,timeout=2)
                    client.request('GET','/')
                    page=client.getresponse();content=page.read()
                    if page.status==200:break
                except OSError:time.sleep(.02)
            else:self.fail('Studio server failed to start')
            self.assertIn(b'/api/jx1-af04-sheet',content)
            args={'source_root':str(root),'character':'男主角','action':'空手站立1',
                  'choices':{'躯体':1,'右手武器':1},'paks':[str(pak)]}
            def post(endpoint,req):
                conn=http.client.HTTPConnection('127.0.0.1',port,timeout=10)
                conn.request('POST',endpoint,body=json.dumps(req,ensure_ascii=False).encode('utf-8'),
                    headers={'Content-Type':'application/json','X-TMB-Local':'1'})
                response=conn.getresponse();data=json.loads(response.read());return response.status,data
            status,catalog=post('/api/jx1-af04-catalog',args)
            self.assertEqual(status,200,catalog)
            self.assertEqual(catalog['variants_found'],4)
            status,sheet=post('/api/jx1-af04-sheet',args)
            self.assertEqual(status,200,sheet)
            self.assertEqual(len(sheet['rendered_directions']),8)
            self.assertTrue(Path(sheet['png_path']).exists())
            # Repeat is genuinely idempotent (no rewrite).
            status,again=post('/api/jx1-af04-sheet',args)
            self.assertEqual(status,200,again)
            self.assertIn('EXISTING_VERIFIED',again['status'])
            status,bad=post('/api/jx1-af04-sheet',{**args,'character':'enemy003'})
            self.assertEqual(status,400)
            self.assertIn('playable proof',bad['error'])

    def test_sort_frame_overrides_and_unknown_directions(self):
        rules={'DEFAULT':{'Dir1':'-1,9,5,'},'空手站立1':{'Line1':'0,5,9,'}}
        self.assertEqual(_sort_for(rules,'空手站立1',0,0,{5,9}),[5,9])
        with self.assertRaisesRegex(ValueError,'missing source sort'):
            _sort_for(rules,'空手站立1',2,4,{5,9})
        with self.assertRaises(ValueError):
            _sort_for({'DEFAULT':{'Dir1':'-1,9,9,'}},'other',0,0,{9})

if __name__=='__main__':unittest.main()