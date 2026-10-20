import io
import struct
import tempfile
import unittest
from pathlib import Path
from forge import map_probe, mpc_metadata, jxqy_player

class FocusedTests(unittest.TestCase):
    def test_map_v2_exact_binary(self):
        b=bytearray(16512+20)
        b[:15]=b"MAP File Ver2.0"
        struct.pack_into('<4i', b,68,2,1,64,32)
        b[16512+6]=0xC0
        b[16512+7]=1
        b[16512+1]=4
        d=map_probe(bytes(b))
        self.assertEqual((d['width'],d['height'],d['blocked_cells'],d['trap_cells']),(2,1,1,1))
        self.assertEqual(d['populated_cells_per_layer'],[1,0,0])
        with self.assertRaises(ValueError): map_probe(bytes(b[:-1]))
        with self.assertRaises(ValueError): map_probe(b'not a map')

    def test_mpc_v1_exact_png_frames(self):
        from PIL import Image
        im=Image.new('RGBA',(3,3),(200,0,0,255))
        f=io.BytesIO();im.save(f,'PNG');payload=f.getvalue()
        buf=bytearray(48)
        buf[:15]=b'IMG File Ver1.0'
        struct.pack_into('<iii',buf,16,2,2,60)
        for _ in range(2): buf+=struct.pack('<iiii',len(payload),2,3,0)+payload
        result=mpc_metadata(bytes(buf))
        self.assertEqual(result['directions'],2)
        self.assertEqual(result['frames_per_direction'],1)
        with self.assertRaises(ValueError):mpc_metadata(bytes(buf[:-5]))

    def test_player_npc_chain_and_unknown_outfit(self):
        with tempfile.TemporaryDirectory() as t:
            r=Path(t);(r/'save/rpg0').mkdir(parents=True);(r/'ini/npcres').mkdir(parents=True)
            (r/'save/rpg0/player.ini').write_text('[init]\nname=Test playable\nnpcini=z-test.ini\n',encoding='utf-8')
            (r/'ini/npcres/z-test.ini').write_text('[stand]\nimage=figure-st.mpc\n',encoding='utf-8')
            p=jxqy_player(r)
            self.assertEqual(p['role'],'playable_source_evidenced')
            self.assertEqual(p['equipment_visual_swap'],'NOT_VERIFIED')
            self.assertEqual(p['verified_assets'],0)

if __name__=='__main__':unittest.main()