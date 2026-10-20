import tempfile
import unittest
from pathlib import Path
from jx1_tables_v2 import player_table_catalog,decode_table,link_catalog_to_pack
from jx1_pak_v2 import jx1_path_hash
import struct
from test_jx1_adapter import sprite


class JX1TablesTests(unittest.TestCase):
    def test_special_table_chain_exact_links_and_gbk(self):
        with tempfile.TemporaryDirectory() as tmp:
            base=Path(tmp);tables=base/'settings/npcres';tables.mkdir(parents=True)
            kind='ID\t人物类型\t部件说明文件名\t资源文件路经\tHEAD\tBODY\nhero01\t特殊npc\tparts.txt\tcharacter\thead.txt\tbody.txt\n'
            (tables/'人物类型.txt').write_bytes(kind.encode('gb18030'))
            (tables/'parts.txt').write_bytes(('part\tunused\tpart0\tpart1\tpart2\tpart3\n'
                          '0\t0\tHEAD\tBODY\t\t\n1\t0\t\t\t\t\n2\t0\t\t\t\t\n3\t0\t\t\t\t\n').encode('gb18030'))
            (tables/'head.txt').write_bytes('id\tstand\tattack\ndefault\thead0.spr\thead1.spr\nhelmet\thead2.spr\t\n'.encode('gb18030'))
            (tables/'body.txt').write_bytes('id\tstand\ndefault\tbody0.spr\n'.encode('gb18030'))
            asset=base/'character';asset.mkdir()
            (asset/'head0.spr').write_bytes(sprite())
            r=player_table_catalog(tables/'人物类型.txt','hero01',tables,base)
            self.assertEqual(r['active_part_count'],2)
            self.assertEqual(r['groups'][0]['label'],'HEAD')
            self.assertEqual(r['groups'][0]['variants'][0]['equip_variant_row'],0)
            self.assertTrue(r['groups'][0]['variants'][0]['actions']['stand']['source_asset_exists'])
            self.assertFalse(r['groups'][0]['variants'][0]['actions']['attack']['source_asset_exists'])
            self.assertEqual(r['stage'],'SOURCE_TABLE_CATALOGED_NO_PLAYABLE_IDENTITY_ASSERTION')
            self.assertFalse(r['status']=='PLAYABLE_VERIFIED')
            with self.assertRaises(ValueError):player_table_catalog(tables/'人物类型.txt','missing',tables)
    def test_exact_virtual_filename_hash_to_pack_index(self):
        with tempfile.TemporaryDirectory() as tmp:
            base=Path(tmp);archive=base/'sprite.pak'
            virtual='\\character\\head0.spr'
            uid=jx1_path_hash(virtual)
            entry=b'JX1'
            hdr=struct.pack('<4s4I12s',b'PACK',1,32+len(entry),32,0,b'')
            archive.write_bytes(hdr+entry+struct.pack('<4I',uid,32,len(entry),len(entry)))
            catalog={'resource_base':'character','groups':[{'label':'HEAD','variants':[
                {'equip_variant_row':0,'actions':{'stand':{'spr_leaf':'head0.spr'}}}]}]}
            linked=link_catalog_to_pack(catalog,[archive])
            self.assertEqual(linked['records'][0]['computed_id'],uid)
            self.assertEqual(linked['records'][0]['status'],'HASH_ID_MATCH_PAK_INDEX_ONLY')
            self.assertFalse(linked['decode_or_player_verification'])

    def test_refuse_npc_normal_and_path_escape(self):
        with tempfile.TemporaryDirectory() as tmp:
            base=Path(tmp);(base/'kind.txt').write_text('ID\t人物类型\t部件说明文件名\nnpc\t普通npc\tparts.txt\nhero\t特殊npc\t../secret.txt\n',encoding='utf-8')
            normal=player_table_catalog(base/'kind.txt','npc',base)
            self.assertFalse(normal['is_composite_kind'])
            with self.assertRaisesRegex(ValueError,'unsafe source table'):player_table_catalog(base/'kind.txt','hero',base)
    def test_reject_binary_and_oversize(self):
        with tempfile.TemporaryDirectory() as tmp:
            p=Path(tmp)/'a.txt';p.write_bytes(b'\x00abc')
            with self.assertRaises(ValueError):decode_table(p)

if __name__=='__main__':unittest.main()