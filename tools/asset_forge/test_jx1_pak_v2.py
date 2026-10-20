import struct
import tempfile
import unittest
from pathlib import Path
from jx1_pak_v2 import pak_index,read_pak_entry,nrv2b_decompress,jx1_path_hash
from jx1_adapter import Spr
from test_jx1_adapter import sprite


class BitWriter:
    def __init__(self):self.data=bytearray();self.n=0;self.slot=None
    def bit(self,b):
        if self.n==0:
            self.slot=len(self.data);self.data.append(0)
        if b:self.data[self.slot]|=1<<(7-self.n)
        self.n=(self.n+1)%8
    def byte(self,b):self.data.append(b)
    def bytes(self):return bytes(self.data)


def nrv_literals(data:bytes)->bytes:
    # Independent NRV2B bitstream producer for literal-only frames + terminator.
    out=BitWriter()
    for value in data:out.bit(1);out.byte(value)
    out.bit(0)
    # A match offset marker of 0xffffffff terminates UCL NRV2B.
    code=0x1000002
    digits=bin(code)[3:]
    for i,b in enumerate(digits):
        out.bit(int(b));out.bit(int(i==len(digits)-1))
    out.byte(0xff)
    return out.bytes()


def pak(path,entry_id,real,payload,method):
    header=struct.pack('<4s4I12s',b'PACK',1,32+len(payload),32,0,b'')
    idx=struct.pack('<4I',entry_id,32,real,len(payload)|(method<<24))
    path.write_bytes(header+payload+idx)


class PackV2Tests(unittest.TestCase):
    def test_ucl_literal_stream_decode(self):
        raw=b'Hello JX1!'
        blob=nrv_literals(raw)
        self.assertEqual(nrv2b_decompress(blob,len(raw)),raw)
        with self.assertRaises(ValueError):nrv2b_decompress(blob,len(raw)-1)
        with self.assertRaises(ValueError):nrv2b_decompress(blob[:-1],len(raw))
        with self.assertRaises(ValueError):nrv2b_decompress(blob+b'X',len(raw))

    def test_ucl_lookbehind_match(self):
        writer=BitWriter()
        writer.bit(1);writer.byte(ord('A'))
        writer.bit(1);writer.byte(ord('B'))
        writer.bit(0) # Enter back-reference
        writer.bit(1);writer.bit(1) # m_off code 3
        writer.byte(1) # m_off=(3-3)*256+1+1 => 2
        writer.bit(0);writer.bit(1) # copy 2 bytes
        writer.bit(0)
        code=0x1000002
        digits=bin(code)[3:]
        for i,b in enumerate(digits):
            writer.bit(int(b));writer.bit(int(i==len(digits)-1))
        writer.byte(0xff)
        self.assertEqual(nrv2b_decompress(writer.bytes(),4),b'ABAB')

    def test_pack_full_ucl_and_raw_and_new_flag(self):
        with tempfile.TemporaryDirectory() as tmp:
            p=Path(tmp)/'a.pak';spr=sprite();cmp=nrv_literals(spr)
            for mode,payload in [(0,spr),(1,cmp),(0x20,cmp)]:
                pak(p,55,len(spr),payload,mode)
                self.assertEqual(read_pak_entry(p,55),spr)
                self.assertEqual(Spr(read_pak_entry(p,55)).header['frames'],2)
                self.assertEqual(pak_index(p)['entries'][0]['method'],mode)
            pak(p,55,len(spr),cmp,2)
            with self.assertRaisesRegex(ValueError,'unsupported'):read_pak_entry(p,55)

    def test_frame_pak_raw_and_compressed(self):
        with tempfile.TemporaryDirectory() as tmp:
            p=Path(tmp)/'a.pak';src=sprite()
            _,_,_,_,_,n,colors,_,_,_=struct.unpack_from('<4s8H12s',src)
            base=32+colors*3
            off=base+n*8
            frames=[]
            for i in range(n):
                start,length=struct.unpack_from('<II',src,base+i*8)
                frames.append(src[off+start:off+start+length])
            for frame_method in (0x10,0x11):
                infos=[];blocks=[]
                for i,frame in enumerate(frames):
                    if frame_method==0x11 and i==1:
                        packed=nrv_literals(frame);infos.append((len(packed),len(frame)))
                    else:
                        packed=frame;infos.append((len(frame),-len(frame)))
                    blocks.append(packed)
                framed=src[:base]+b''.join(struct.pack('<ii',*x) for x in infos)+b''.join(blocks)
                pak(p,62,len(src),framed,frame_method)
                self.assertEqual(read_pak_entry(p,62),src)
            # Random malformed packed stream refuses (never swaps in another SPR).
            pak(p,62,len(src),framed[:-1],0x11)
            with self.assertRaises(ValueError):read_pak_entry(p,62)

    def test_pack_signature_range_and_hash(self):
        with tempfile.TemporaryDirectory() as tmp:
            p=Path(tmp)/'bad.pak';p.write_bytes(b'PAK '+b'\0'*80)
            with self.assertRaisesRegex(ValueError,'PACK signature'):pak_index(p)
            pak(p,1,3,b'abc',0)
            self.assertEqual(read_pak_entry(p,1),b'abc')
            self.assertEqual(jx1_path_hash('\\a\\B.spr'),jx1_path_hash('/A/B.SPR'))
            self.assertNotEqual(jx1_path_hash('\\a\\b.spr'),jx1_path_hash('a\\b.spr'))
            with self.assertRaises(ValueError):read_pak_entry(p,2)

if __name__=='__main__':unittest.main()