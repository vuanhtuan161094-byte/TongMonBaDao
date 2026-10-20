#!/usr/bin/env python3
"""Evidence-based, bounded JX1 PACK reader. Read-only; never writes source PAK.

Kingsoft SourceInit-JX1 XPackFile.cpp @ b2e251a: PACK, 32-byte header,
16-byte entries, high byte compression flags. Method 1/0x20 = NRV2B-8;
0x10 adds independently-compressed SPR frames. Method 2 is deliberately
unsupported because the inspected Kingsoft decoder has its BZIP2 path disabled.

NRV2B bitstream behavior follows its published format; no native executable or
network access needed. Limits protect memory, I/O, and malformed streams.
"""
from __future__ import annotations
from pathlib import Path
import hashlib
import struct
from typing import Any

PACK_HEADER=struct.Struct('<4s4I12s')
PACK_ENTRY=struct.Struct('<IIII')
SPR_HEADER=struct.Struct('<4s8H12s')
MAX_ITEMS=100000
MAX_ENTRY=64*1024*1024
MAX_FRAMES=4096
MAX_PACKED=64*1024*1024


class _NRVBits:
    def __init__(self, data: bytes):
        self.data=data
        self.i=0
        self.bb=0
    def bit(self)->int:
        if self.bb & 0x7f:
            self.bb *= 2
        else:
            if self.i >= len(self.data): raise ValueError('NRV2B truncated bitstream')
            self.bb = self.data[self.i]*2+1
            self.i+=1
        return (self.bb>>8)&1
    def byte(self)->int:
        if self.i >= len(self.data): raise ValueError('NRV2B truncated literal/offset')
        result=self.data[self.i]
        self.i+=1
        return result


def nrv2b_decompress(payload: bytes, expected_size: int)->bytes:
    """Decode UCL NRV2B bit-buffer-8, requiring exact size and full input use."""
    if not isinstance(expected_size,int) or expected_size < 0 or expected_size > MAX_ENTRY:
        raise ValueError('NRV2B requested size unsafe')
    cur=_NRVBits(payload)
    out=bytearray()
    last_off=1
    steps=0
    while True:
        steps+=1
        if steps>max(1000,expected_size*8+100): raise ValueError('NRV2B excessive commands')
        while cur.bit():
            if len(out)>=expected_size: raise ValueError('NRV2B output overflow')
            out.append(cur.byte())
        m_off=1
        while True:
            m_off=m_off*2+cur.bit()
            if m_off > 0x1000002: raise ValueError('NRV2B invalid offset code')
            if cur.bit(): break
        if m_off==2:
            m_off=last_off
        else:
            m_off=((m_off-3)*256+cur.byte())&0xffffffff
            if m_off==0xffffffff:
                if len(out)!=expected_size or cur.i!=len(payload):
                    raise ValueError('NRV2B size/trailing-data mismatch')
                return bytes(out)
            last_off=m_off+1
            m_off=last_off
        m_len=cur.bit()
        m_len=m_len*2+cur.bit()
        if m_len==0:
            m_len+=1
            while True:
                m_len=m_len*2+cur.bit()
                if m_len>expected_size: raise ValueError('NRV2B excessive match length')
                if cur.bit(): break
            m_len+=2
        m_len+=int(m_off>0xd00)
        count=m_len+1
        if m_off<=0 or m_off>len(out): raise ValueError('NRV2B invalid lookbehind')
        if len(out)+count>expected_size: raise ValueError('NRV2B match output overflow')
        for _ in range(count): out.append(out[-m_off])


def pak_index(path: Path)->dict[str,Any]:
    path=Path(path)
    with path.open('rb') as f:
        f.seek(0,2); size=f.tell()
        if size<PACK_HEADER.size: raise ValueError('PACK header truncated')
        f.seek(0); sign,count,index_off,data_off,crc,_=PACK_HEADER.unpack(f.read(PACK_HEADER.size))
        if sign!=b'PACK':raise ValueError('JX1 PACK signature required (PAK-space is not this format)')
        if count>MAX_ITEMS or not 32<=data_off<=index_off<=size or index_off+count*16>size:
            raise ValueError('PACK header invalid or unsafe')
        f.seek(index_off)
        records=[]
        for _ in range(count):
            uid,off,real,flags=PACK_ENTRY.unpack(f.read(16))
            packed=flags & 0xffffff
            method=flags>>24
            if real>MAX_ENTRY or packed>MAX_PACKED or real<=0 or packed<=0:
                raise ValueError('PACK entry size invalid or unsafe')
            if off<data_off or off+packed>index_off:
                raise ValueError('PACK entry overlaps index or escapes data')
            records.append({'id':uid,'offset':off,'real_length':real,'stored_length':packed,
                            'method':method,'frame_flag':bool(method&0x10),
                            'codec':(method&0x0f),
                            'read_supported': (method & 0x0f) in (0,1) or method==0x20})
    return {'path':str(path),'signature':'PACK','size_bytes':size,'count':count,
            'data_offset':data_off,'index_offset':index_off,'crc32_header':crc,
            'entries':records,'status':'INDEX_VERIFIED_FILENAME_HASH_NOT_REVERSED'}


def _decompress_data(payload:bytes,method:int,expected_size:int)->bytes:
    if expected_size>MAX_ENTRY:raise ValueError('PACK extracted size exceeds limit')
    if method==0:
        if len(payload)!=expected_size:raise ValueError('PACK raw size mismatch')
        return payload
    if method in (1,0x20):return nrv2b_decompress(payload,expected_size)
    raise ValueError(f'PACK compression 0x{method:x} unsupported (no guessed bzip2)')


def _frame_spr(payload: bytes,real_length:int,method:int)->bytes:
    if len(payload)<32:raise ValueError('SPR framed entry truncated')
    sig,w,h,cx,cy,n,colors,dirs,interval,_=SPR_HEADER.unpack_from(payload)
    if sig[:3]!=b'SPR' or n<=0 or n>MAX_FRAMES or colors>256 or colors<=0 or dirs<=0 or n%dirs:
        raise ValueError('SPR framed header invalid')
    base=32+colors*3
    if len(payload)<base+n*8:raise ValueError('SPR framed metadata truncated')
    table=[]
    cursor=base+n*8
    for idx in range(n):
        stored,decoded_signed=struct.unpack_from('<ii',payload,base+idx*8)
        if stored<=0 or abs(decoded_signed)>MAX_ENTRY or decoded_signed==0 or cursor+stored>len(payload):
            raise ValueError('SPR framed payload extent invalid')
        blob=payload[cursor:cursor+stored];cursor+=stored
        decoded=_decompress_data(blob,0 if decoded_signed<0 else (method&0x0f),abs(decoded_signed))
        if len(decoded)<8:raise ValueError('SPR framed frame too short')
        fw,fh,*_=struct.unpack_from('<4H',decoded)
        if not fw or not fh or fw*fh>4*1024*1024:raise ValueError('SPR framed frame dimensions bad')
        table.append(decoded)
    if cursor!=len(payload):raise ValueError('SPR framed trailing data')
    prefix=payload[:base]
    out=bytearray(prefix)
    offset=0
    for frame in table:
        out+=struct.pack('<II',offset,len(frame));offset+=len(frame)
    for frame in table:out+=frame
    if len(out)!=real_length:raise ValueError('SPR framed decompression size mismatch')
    return bytes(out)


def read_pak_entry_record(path:Path,e:dict)->bytes:
    """Read one previously verified indexed record; avoids reindexing large PACK per layer."""
    if not isinstance(e,dict) or type(e.get('id')) is not int:
        raise ValueError('PACK indexed record required')
    index_fields=('offset','stored_length','real_length','method','id')
    if any(type(e.get(field)) is not int for field in index_fields):
        raise ValueError('PACK record fields invalid')
    if e['real_length']<=0 or e['real_length']>MAX_ENTRY or e['stored_length']<=0 or e['stored_length']>MAX_PACKED:
        raise ValueError('PACK record size unsafe')
    with Path(path).open('rb') as stream:
        stream.seek(0,2); fsize=stream.tell()
        if e['offset']<PACK_HEADER.size or e['offset']+e['stored_length']>fsize:
            raise ValueError('PACK record bounds invalid')
        stream.seek(e['offset'])
        payload=stream.read(e['stored_length'])
    if len(payload)!=e['stored_length']:raise ValueError('PACK truncated payload')
    if e['frame_flag']:
        if e['method'] & ~0x1f:raise ValueError('PACK unknown framed flags')
        return _frame_spr(payload,e['real_length'],e['method'])
    return _decompress_data(payload,e['method'],e['real_length'])


def read_pak_entry(path: Path,uid:int)->bytes:
    if not isinstance(uid,int) or not 0<=uid<=0xffffffff:raise ValueError('PACK ID invalid')
    entries=[v for v in pak_index(path)['entries'] if v['id']==uid]
    if len(entries)!=1:raise ValueError('PACK ID missing/duplicate')
    return read_pak_entry_record(path,entries[0])


def jx1_path_hash(name:str)->int:
    """JX1 ZPackFile.cpp rolling filename hash; caller supplies exact virtual path.

    Backslash & leading slash are meaningful: this DOES NOT guess names from IDs.
    """
    if not name or '\x00' in name:raise ValueError('invalid virtual name')
    raw=name.replace('/','\\').encode('gbk')
    val=0
    for i,b in enumerate(raw,1):
        if 65<=b<=90:b+=32
        signed=b-256 if b>=128 else b
        val=((((val+i*signed)&0xffffffff)%0x8000000b)*0xffffffef)&0xffffffff
    return val^0x12345678


def inspect_pak_asset(path:Path,uid:int)->dict:
    data=read_pak_entry(path,uid)
    return {'pak':str(path),'id':uid,'sha256':hashlib.sha256(data).hexdigest(),
            'size_bytes':len(data),'spr':data[:3]==b'SPR','status':'DECODED_PAYLOAD_VERIFIED_SIZE'}