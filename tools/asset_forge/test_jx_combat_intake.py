import json
import struct
import tempfile
import unittest
from pathlib import Path
from jx_combat_intake import scan_root, audit, find_kind_root, pack_header, shafile, table_preview


class JxCombatIntakeTests(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.dir=Path(self.temp.name)
        self.source=self.dir/'Source'; self.source.mkdir()
        self.tool=self.dir/'Tool JX'; self.tool.mkdir()
        self.reports=self.dir/'reports'

    def add_kind(self):
        folder=self.tool/'Client_VLTK'/'settings'/'npcres'
        folder.mkdir(parents=True)
        (folder/'人物类型.txt').write_text('人物名称\t人物类型\n男主角\t特殊npc\n',encoding='utf-8')
        return folder/'人物类型.txt'

    def add_pak(self, data=b'PACK'):
        path=self.source/'data.pak'
        if data==b'PACK':
            path.write_bytes(struct.pack('<4s4I12s',data,0,32,32,0,b'\0'*12))
        else:path.write_bytes(data + b'\0'*28)
        return path

    def test_basic_inventory_scans_both_roots_and_preserves_source(self):
        kind=self.add_kind()
        self.add_pak()
        skill=self.source/'skills.txt';skill.write_text('SkillId\tName\n15\tSword\n',encoding='utf-8')
        src_before={p:str(p.stat().st_mtime_ns) for p in (skill,kind)}
        report=audit(self.source,self.tool,self.reports)
        self.assertEqual(report['files_scanned'],3)
        self.assertTrue((self.reports/'JX1_COMBAT_SOURCE_MANIFEST.json').exists())
        manifest=json.loads((self.reports/'JX1_COMBAT_SOURCE_MANIFEST.json').read_text(encoding='utf-8'))
        self.assertEqual(manifest['sources'][0]['counts']['pak'],1)
        self.assertEqual(manifest['sources'][0]['pak_files'][0]['header']['status'],'JX1_PACK_HEADER_INVALID')
        self.assertEqual(manifest['candidate_clients'][1]['client_root'],str(self.tool/'Client_VLTK'))
        self.assertEqual(src_before,{p:str(p.stat().st_mtime_ns) for p in (skill,kind)})

    def test_non_jx_pak_never_false_valid(self):
        p=self.add_pak(b'ZZZ!')
        self.assertEqual(pack_header(p)['status'],'NOT_JX1_PACK')

    def test_bounds_limit_does_not_bulk_process(self):
        for i in range(12): (self.source/f'f{i:02}.spr').write_bytes(b'A')
        r=scan_root(self.source,'SOURCE',max_files=3)
        self.assertTrue(r['truncated']);self.assertEqual(r['scanned_files'],3)

    def test_no_write_inside_either_source(self):
        with self.assertRaisesRegex(ValueError,'OUTSIDE SOURCE ROOTS'):
            audit(self.source,self.tool,self.source/'reports')
        with self.assertRaisesRegex(ValueError,'OUTSIDE SOURCE ROOTS'):
            audit(self.source,self.tool,self.tool/'reports')

    def test_symlink_never_dereferenced(self):
        link=self.source/'other.spr';link.symlink_to(self.dir/'fake.spr')
        r=scan_root(self.source,'SOURCE',10)
        self.assertEqual(r['scanned_files'],0)

    def test_small_table_hash_and_decode(self):
        p=self.add_kind();self.assertEqual(len(shafile(p)),64)
        self.assertIn('男主角',table_preview(p)['sample_lines'][1])

    def test_wrong_structured_table_path_not_accepted(self):
        f=self.tool/'人物类型.txt';f.write_text('dummy',encoding='utf-8')
        self.assertIsNone(find_kind_root(scan_root(self.tool,'T',10)))


if __name__=='__main__':unittest.main()
