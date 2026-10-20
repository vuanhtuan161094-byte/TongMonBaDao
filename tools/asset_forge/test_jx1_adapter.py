import json
import struct
import tempfile
import unittest
from pathlib import Path
from jx1_adapter import Spr,pak_index,read_raw_pak_entry,validate_playable,playable_sheet


def sprite(runs=((2,255,[1,2]),(1,0,[]),(1,255,[1])),dirs=2):
    # 2x2 frame: red / blue / transparency / red
    body=b''.join(bytes((length,alpha))+bytes(indices) for length,alpha,indices in runs)
    frame=struct.pack('<4H',2,2,0,0)+body
    hdr=struct.pack('<4s8H12s',b'SPR ',2,2,0,0,dirs,3,dirs,90,b'')
    pal=bytes((0,0,0,255,0,0,0,0,255))
    return hdr+pal+b''.join(struct.pack('<II',i*len(frame),len(frame)) for i in range(dirs))+frame*dirs

class JX1AdapterTests(unittest.TestCase):
    def test_spr_decode_true_alpha_and_directons(self):
        raw=sprite()
        sp=Spr(raw)
        self.assertEqual(sp.header['directions'],2)
        rgba,meta=sp.decode_rgba(1)
        self.assertEqual(meta['direction'],1)
        self.assertEqual(rgba[:4],b'\xff\x00\x00\xff')
        self.assertEqual(rgba[4:8],b'\x00\x00\xff\xff')
        self.assertEqual(rgba[8:12],bytes(4))
    def test_spr_reject_truncated_overrun(self):
        with self.assertRaises(ValueError):Spr(sprite()[:-1])
        raw=sprite(runs=((10,0,[]),))
        with self.assertRaises(ValueError):Spr(raw).decode_rgba(0)
    def test_pak_index_raw_and_compressed_refusal(self):
        with tempfile.TemporaryDirectory() as tmp:
            p=Path(tmp)/'data.pak';item=sprite()
            def mk(method):
                hdr=struct.pack('<4s4I12s',b'PAK ',1,32+len(item),0,0,b'')
                idx=struct.pack('<III3sB',123,32,len(item),len(item).to_bytes(3,'little'),method)
                p.write_bytes(hdr+item+idx)
            mk(0)
            self.assertEqual(read_raw_pak_entry(p,123),item)
            self.assertEqual(pak_index(p)['count'],1)
            mk(2)
            with self.assertRaisesRegex(ValueError,'unsupported'):read_raw_pak_entry(p,123)
    def test_playable_no_forged_proof(self):
        with tempfile.TemporaryDirectory() as tmp:
            root=Path(tmp);(root/'body.spr').write_bytes(sprite())
            pose={'name':'stand/0','layers':[{'part':'body','variant':'default','spr':'body.spr','z':5,'anchor':[0,0],'frame':0}]}
            spec={'kind':'JX1_PLAYABLE','poses':[pose]}
            with self.assertRaisesRegex(ValueError,'PLAYABLE_UNVERIFIED'):validate_playable(spec,root)
            spec['playable_proof']={'resource_mode':'NPC_RES_SPECIAL','player_resource_record':'player.xls:1','part_table_record':'body.tbl:7'}
            self.assertEqual(len(validate_playable(spec,root)['validated_layers']),1)
            try:from PIL import Image
            except ImportError:return
            target=root/'sheet.png'
            result=playable_sheet(spec,root,target,{'body':'default'})
            self.assertTrue(target.is_file())
            self.assertEqual(result['kind'],'JX1_PLAYABLE')
            with self.assertRaises(FileExistsError):playable_sheet(spec,root,target,{'body':'default'})
    def test_missing_source_or_bad_anchor_refused(self):
        with tempfile.TemporaryDirectory() as tmp:
            root=Path(tmp);(root/'body.spr').write_bytes(sprite())
            spec={'kind':'JX1_PLAYABLE','playable_proof':{'resource_mode':'NPC_RES_SPECIAL','player_resource_record':'x','part_table_record':'y'},'poses':[{'name':'a','layers':[{'part':'body','variant':'default','spr':'../body.spr','z':0,'anchor':[0,0],'frame':0}]}]}
            with self.assertRaises(ValueError):validate_playable(spec,root)

if __name__=='__main__':unittest.main()