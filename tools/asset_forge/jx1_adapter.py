#!/usr/bin/env python3
"""Read-only Kingsoft JX1 SPR/PAK adapter and evidence-gated playable contact sheets.

Format evidence: mapic91/MpcAsfTool SprDecode.cpp; JX1 C++ KNpcResNode,
KNpcRes; Kingsoft PAK header/index. Unknown pack compression is refused.
No reverse inference of player identity from sprite filename.
"""
from __future__ import annotations
import argparse
import hashlib
import io
import json
from pathlib import Path
import struct
from typing import Any

SPR_HEADER = struct.Struct('<4s8H12s')  # 32-byte SPR header
PAK_HEADER = struct.Struct('<4s4I12s')  # 32-byte PAK header
PAK_ITEM = struct.Struct('<II I 3s B')   # ID, file offset, real length, packed len[3], method
MAX_SPR_BYTES = 32 * 1024 * 1024
MAX_FRAMES = 4096
MAX_PIXELS = 4 * 1024 * 1024
MAX_PAK_ITEMS = 100000
MAX_RAW_ENTRY = 64 * 1024 * 1024
PARTS = frozenset(('body', 'head', 'armor', 'helm', 'weapon', 'horse', 'shadow'))


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def read_local(root: Path, rel: str) -> bytes:
    if not isinstance(rel, str) or not rel or '\\' in rel or ':' in rel or '\x00' in rel:
        raise ValueError('relative asset path required')
    q = Path(rel)
    if q.is_absolute() or any(v in ('.', '..') for v in q.parts):
        raise ValueError('unsafe relative path')
    base = root.resolve(strict=True)
    p = (base / q).resolve(strict=True)
    if not p.is_relative_to(base) or not p.is_file() or p.is_symlink():
        raise ValueError('asset path escapes source root or is not regular file')
    if p.stat().st_size > MAX_SPR_BYTES:
        raise ValueError('SPR exceeds safe preview limit')
    return p.read_bytes()


class Spr:
    def __init__(self, binary: bytes):
        if len(binary) < SPR_HEADER.size or len(binary) > MAX_SPR_BYTES:
            raise ValueError('SPR header missing or oversized')
        signature, width, height, cx, cy, count, colors, dirs, interval, _ = SPR_HEADER.unpack_from(binary)
        if signature[:3] != b'SPR' or not 1 <= count <= MAX_FRAMES or not 1 <= colors <= 256 or not 1 <= dirs <= count:
            raise ValueError('unsupported SPR header')
        if width == 0 or height == 0 or width * height > MAX_PIXELS or count % dirs:
            raise ValueError('SPR dimensions/frames/directions invalid')
        base = 32 + colors * 3
        table_end = base + 8 * count
        if len(binary) < table_end:
            raise ValueError('truncated SPR palette/table')
        self.data = binary
        self.header = {'width':width, 'height':height, 'center_x':cx, 'center_y':cy,
                       'frames':count, 'colors':colors, 'directions':dirs,
                       'frames_per_direction':count//dirs, 'interval_ms':interval,
                       'sha256':sha256(binary)}
        self.palette = [tuple(binary[32+i*3:35+i*3]) for i in range(colors)]
        self.frames = []
        for i in range(count):
            offset, length = struct.unpack_from('<II', binary, base+i*8)
            start = table_end + offset
            if length < 8 or start < table_end or start + length > len(binary):
                raise ValueError(f'SPR frame {i} out of range')
            w,h,offx,offy = struct.unpack_from('<4H',binary,start)
            if not w or not h or w*h > MAX_PIXELS:
                raise ValueError(f'SPR frame {i} invalid dimensions')
            self.frames.append({'start':start+8,'end':start+length,'width':w,'height':h,
                                'offset_x':offx,'offset_y':offy})

    def decode_rgba(self, frame_index: int) -> tuple[bytes, dict]:
        if type(frame_index) is not int or not 0 <= frame_index < len(self.frames):
            raise ValueError('SPR frame index out of bounds')
        f = self.frames[frame_index]
        raw = self.data
        pos, end = f['start'],f['end']
        total = f['width']*f['height']
        result = bytearray(total*4)
        pixels = 0
        while pos < end:
            if pos+2 > end:
                raise ValueError('SPR truncated run header')
            n, alpha = raw[pos],raw[pos+1]
            pos += 2
            if not n or pixels+n > total:
                raise ValueError('SPR RLE run overflows frame')
            if alpha == 0:
                pixels += n  # initialized transparent
                continue
            if pos+n > end:
                raise ValueError('SPR truncated color run')
            for index in raw[pos:pos+n]:
                if index >= len(self.palette):
                    raise ValueError('SPR palette index out of bounds')
                r,g,b = self.palette[index]
                result[pixels*4:pixels*4+4] = bytes((r,g,b,alpha))
                pixels += 1
            pos += n
        if pixels != total:
            raise ValueError('SPR RLE ends before last pixel')
        return bytes(result), {'width':f['width'],'height':f['height'],
                              'offset_x':f['offset_x'],'offset_y':f['offset_y'],
                              'frame':frame_index,'direction':frame_index//self.header['frames_per_direction']}


def pak_index(path: Path) -> dict[str, Any]:
    """PAK metadata only; DOES NOT decompress unknown compression methods."""
    with path.open('rb') as stream:
        stream.seek(0,2)
        size=stream.tell()
        if size < 32: raise ValueError('truncated PAK')
        stream.seek(0)
        signature,count,index_off,_,_,_=PAK_HEADER.unpack(stream.read(32))
        if signature != b'PAK ' or not 0 <= count <= MAX_PAK_ITEMS or index_off < 32 or index_off + count*16 > size:
            raise ValueError('invalid PAK header/index')
        stream.seek(index_off)
        records=[]
        for _ in range(count):
            id_, off, real_len, length3, method = PAK_ITEM.unpack(stream.read(16))
            packed_len=int.from_bytes(length3,'little')
            if off < 32 or off + packed_len > size or packed_len == 0:
                raise ValueError('PAK entry offset/length out of range')
            records.append({'id':id_, 'offset':off, 'real_length':real_len,
                            'stored_length':packed_len,'method':method,
                            'raw_read_supported':method==0 and packed_len==real_len})
    return {'path':str(path),'size_bytes':size,'count':count,'entries':records,
            'status':'INDEX_ONLY_NO_PATH_HASH_REVERSE'}


def read_raw_pak_entry(path: Path, entry_id: int) -> bytes:
    catalog=pak_index(path)
    matches=[r for r in catalog['entries'] if r['id']==entry_id]
    if len(matches)!=1: raise ValueError('PAK ID missing or not unique')
    e=matches[0]
    if not e['raw_read_supported'] or e['real_length'] > MAX_RAW_ENTRY:
        raise ValueError('PAK compression unsupported/oversized; metadata only, no fabricated decode')
    with path.open('rb') as stream:
        stream.seek(e['offset'])
        content=stream.read(e['stored_length'])
    if len(content)!=e['real_length']: raise ValueError('PAK truncated entry')
    return content


def validate_playable(spec: dict, source_root: Path) -> dict:
    """An explicit specific player record and modular table are required.

    Neither NPC sprite appearance nor filename is evidence of playable identity.
    """
    proof=spec.get('playable_proof') or {}
    if (spec.get('kind') != 'JX1_PLAYABLE' or proof.get('resource_mode') != 'NPC_RES_SPECIAL'
        or not proof.get('player_resource_record') or not proof.get('part_table_record')):
        raise ValueError('JX1 PLAYABLE_UNVERIFIED: exact player resource and part table required')
    poses=spec.get('poses')
    if not isinstance(poses,list) or not poses:
        raise ValueError('no evidenced pose/direction layers')
    results=[]
    for pose in poses:
        layers=pose.get('layers')
        if not isinstance(layers,list) or not layers:
            raise ValueError('no pose layers')
        seen=set()
        for layer in layers:
            part=layer.get('part')
            if part not in PARTS or not layer.get('variant') or type(layer.get('z')) is not int:
                raise ValueError('invalid part/variant/sort; explicit source sort required')
            key=(part,layer['variant'])
            if key in seen: raise ValueError('duplicate part+variant in pose')
            seen.add(key)
            buf=read_local(source_root,layer['spr'])
            sp=Spr(buf)
            idx=layer.get('frame')
            sp.decode_rgba(idx)
            expected=layer.get('sha256')
            if expected and expected.lower()!=sha256(buf): raise ValueError('SPR SHA mismatch')
            results.append({'pose':pose.get('name'), 'part':part, 'variant':layer['variant'],
                            'spr':layer['spr'], 'sha256':sha256(buf),'frame':idx,
                            'sort_z':layer['z']})
    return {'kind':'JX1_PLAYABLE','actor':spec.get('id'),'validated_layers':results,
            'status':'PLAYER_EVIDENCE_DECLARED_SPR_BYTES_VERIFIED__TABLE_MATCH_PENDING_EXTERNAL'}


def playable_sheet(spec: dict, source_root: Path, out: Path, loadout: dict) -> dict:
    try: from PIL import Image,ImageDraw
    except ImportError as exc: raise RuntimeError('Pillow needed to render contact sheet') from exc
    validation=validate_playable(spec,source_root)
    selected=[]
    for pose in spec['poses']:
        parts={}
        for layer in pose['layers']:
            if loadout.get(layer['part'],'default') == layer['variant']:
                parts[layer['part']]=layer
        if not parts:
            raise ValueError('no matching layers for pose / loadout')
        if not any(k in parts for k in ('body','armor')):
            raise ValueError('body/armor part missing: refusing false playable composite')
        selected.append((pose,sorted(parts.values(),key=lambda v:v['z'])))
    tilew,tileh=256,288
    cols=min(4,len(selected))
    rows=(len(selected)+cols-1)//cols
    canvas=Image.new('RGBA',(cols*tilew,rows*tileh),(21,27,36,255))
    draw=ImageDraw.Draw(canvas)
    records=[]
    for i,(pose,layers) in enumerate(selected):
        area=Image.new('RGBA',(tilew,tileh),(0,0,0,0))
        for layer in layers:
            sp=Spr(read_local(source_root,layer['spr']))
            rgba,meta=sp.decode_rgba(layer['frame'])
            pic=Image.frombytes('RGBA',(meta['width'],meta['height']),rgba)
            # Source-defined per-layer anchor required; no arbitrary re-centering each layer.
            anchor=layer.get('anchor')
            if not isinstance(anchor,list) or len(anchor)!=2 or any(type(a)!=int for a in anchor):
                raise ValueError('missing source-verified per-layer anchor [x,y]')
            px=tilew//2-anchor[0]
            py=tileh-35-anchor[1]
            area.alpha_composite(pic,(px,py))
        x=(i%cols)*tilew;y=(i//cols)*tileh
        canvas.alpha_composite(area,(x,y))
        draw.text((x+6,y+6),str(pose.get('name','pose'))[:32],fill=(238,240,244))
        records.append({'pose':pose.get('name'),'parts':[{'part':v['part'],'variant':v['variant'],
                                                         'spr':v['spr'],'z':v['z']} for v in layers]})
    out.parent.mkdir(parents=True,exist_ok=True)
    if out.exists():raise FileExistsError('preview must not overwrite a prior run')
    canvas.save(out)
    provenance={'kind':'JX1_PLAYABLE','source_root':str(source_root.resolve()),
                'out':str(out),'loadout':loadout,'poses':records,
                'validation':validation,'status':'PREVIEW_ONLY_NOT_GAMEPLAY'}
    out.with_suffix(out.suffix+'.json').write_text(json.dumps(provenance,ensure_ascii=False,indent=2),encoding='utf-8')
    return provenance


def main():
    cli=argparse.ArgumentParser(description='JX1 owner SPR/PAK inspection and playable renderer')
    subs=cli.add_subparsers(dest='cmd',required=True)
    p=subs.add_parser('spr-info');p.add_argument('path')
    p=subs.add_parser('pak-index');p.add_argument('path');p.add_argument('--out')
    p=subs.add_parser('pak-spr');p.add_argument('path');p.add_argument('--id',required=True,type=lambda x:int(x,0));p.add_argument('--out',required=True)
    p=subs.add_parser('player-check');p.add_argument('--spec',required=True);p.add_argument('--source-root',required=True)
    p=subs.add_parser('player-sheet');p.add_argument('--spec',required=True);p.add_argument('--source-root',required=True);p.add_argument('--out',required=True);p.add_argument('--loadout',default='{}')
    args=cli.parse_args()
    if args.cmd=='spr-info':result=Spr(Path(args.path).read_bytes()).header
    elif args.cmd=='pak-index':
        result=pak_index(Path(args.path))
        if args.out: Path(args.out).write_text(json.dumps(result,indent=2),encoding='utf-8')
    elif args.cmd=='pak-spr':
        buf=read_raw_pak_entry(Path(args.path),args.id)
        result=Spr(buf).header
        output=Path(args.out)
        output.parent.mkdir(parents=True,exist_ok=True)
        if output.exists(): raise FileExistsError('output already exists')
        output.write_bytes(buf)
        result.update({'extracted':str(output),'source_pak_id':args.id})
    else:
        spec=json.loads(Path(args.spec).read_text(encoding='utf-8'))
        if args.cmd=='player-check':result=validate_playable(spec,Path(args.source_root))
        else:result=playable_sheet(spec,Path(args.source_root),Path(args.out),json.loads(args.loadout))
    print(json.dumps(result,ensure_ascii=False,indent=2))

if __name__=='__main__':main()