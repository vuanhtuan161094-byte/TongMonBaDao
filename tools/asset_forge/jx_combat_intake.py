#!/usr/bin/env python3
"""C5/JX1 intake: bounded, non-destructive inventory of two Windows source roots.

No archive extraction, no executable invocation and no modification to inputs.
Only summary/hash evidence and selected JX1 table+PACK-ID pilot probes.
"""
from __future__ import annotations
import argparse
from collections import Counter
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import struct
import sys

TRACKED={'.pak':'pak','.spr':'spr','.mpc':'mpc','.asf':'asf','.map':'map','.mpi':'mpi',
 '.lua':'lua','.gd':'gd','.cpp':'cxx','.h':'cxx','.dll':'binary','.exe':'binary',
 '.txt':'table','.ini':'table','.tab':'table','.csv':'table',
 '.png':'image','.jpg':'image','.jpeg':'image','.webp':'image',
 '.wav':'sound','.ogg':'sound','.mp3':'sound','.json':'json',
 '.rar':'archive','.zip':'archive','.7z':'archive','.tar':'archive','.gz':'archive'}
# Only enumerate; never extract unknown archives, execute binaries, or overwrite input.
SKIP_DIR={'.git','node_modules','.venv','venv','__pycache__','.godot','$recycle.bin','system volume information'}
MAX_PATHS=350_000
MAX_SAMPLE=24
MAX_HASH_BYTES=6*1024*1024
PACK_HEADER=struct.Struct('<4s4I12s')
PROTAGONISTS=('男主角','女主角')
TABLE_NAMES={'skills.txt':'skill_table','missles.txt':'missile_table',
             'missiles.txt':'missile_table','人物类型.txt':'player_kind_table',
             'npcres.txt':'npc_resource_table','magic.ini':'magic_config'}


def shafile(file:Path, limit=MAX_HASH_BYTES)->str|None:
    if file.stat().st_size>limit:return None
    h=hashlib.sha256()
    with file.open('rb') as f:
        for block in iter(lambda:f.read(128*1024),b''):h.update(block)
    return h.hexdigest()


def table_preview(file:Path)->dict:
    data=file.read_bytes()[:4096]
    for encoding in ('utf-8-sig','gb18030'):
        try:text=data.decode(encoding);break
        except UnicodeDecodeError:continue
    else:return {'decode':'UNSUPPORTED','sample_lines':[]}
    # Preview cell count, not all original dialogue/source lines.
    return {'decode':encoding,'sample_lines':[row[:350] for row in text.splitlines()[:2]]}


def pack_header(file:Path)->dict:
    try:
        with file.open('rb') as f: head=f.read(PACK_HEADER.size)
        if len(head)<PACK_HEADER.size:return {'status':'NOT_JX1_PACK','reason':'short header'}
        sign,count,idx,data,crc,_=PACK_HEADER.unpack(head)
        size=file.stat().st_size
        if sign!=b'PACK':return {'status':'NOT_JX1_PACK','signature_hex':head[:4].hex()}
        ok=0<count<=100_000 and 32<=data<=idx<=size and idx+count*16<=size
        return {'status':'JX1_PACK_HEADER_VALID' if ok else 'JX1_PACK_HEADER_INVALID',
                'count':count,'index_offset':idx,'data_offset':data,'file_bytes':size,'crc_header':crc}
    except (OSError,ValueError) as exc:return {'status':'READ_ERROR','reason':type(exc).__name__}


def _focus_name(name:str,category:str)->str|None:
    low=name.casefold()
    if low in TABLE_NAMES:return TABLE_NAMES[low]
    if any(word in low for word in ('skill','missle','missile','magic','effect','npcres','monster','character','weapon','actor','地图','技能','人物类型')):
        return 'possible_combat_resource'
    if category in ('pak','spr','map','mpc','asf'):return category+'_sample'
    return None


def scan_root(root:Path, display:str,max_files:int,max_depth:int=12)->dict:
    root=Path(root).resolve(strict=True)
    if not root.is_dir():raise ValueError('source root must be a directory: '+str(root))
    counts=Counter();paths=[];paks=[];tables=[];examples={}
    errors=[];total=0;hidden_dirs=0;truncated=False;source_size=0;bin_paths=[]
    def onerror(err): errors.append(str(getattr(err,'filename','unknown'))+': '+type(err).__name__)
    for folder,dirs,files in os.walk(root,topdown=True,followlinks=False,onerror=onerror):
        here=Path(folder)
        depth=len(here.relative_to(root).parts)
        dirs[:]=sorted(d for d in dirs if d.casefold() not in SKIP_DIR and not (here/d).is_symlink() and not (hasattr(here/d,'is_junction') and (here/d).is_junction())) if depth<max_depth else []
        hidden_dirs+=1
        for name in sorted(files):
            if total>=max_files:truncated=True;break
            if '\x00' in name:continue
            item=here/name
            try:
                if item.is_symlink() or not item.is_file():continue
                size=item.stat().st_size
            except (OSError,ValueError):errors.append('stat failed: '+str(item));continue
            total+=1;source_size+=size
            category=TRACKED.get(item.suffix.lower(),'other')
            counts[category]+=1
            if len(examples.get(category,[]))<5:examples.setdefault(category,[]).append(item.relative_to(root).as_posix())
            focus=_focus_name(name,category)
            relative=item.relative_to(root).as_posix()
            if focus and (len(paths)<200 or focus in ('player_kind_table','skill_table','missile_table')):
                paths.append({'relpath':relative,'category':category,'focus':focus,'bytes':size})
            if category=='pak':
                paks.append({'relpath':relative,'bytes':size,'header':pack_header(item)})
            if category=='table' and focus in ('player_kind_table','skill_table','missile_table'):
                try:meta={'relpath':relative,'kind':focus,'bytes':size,'sha256':shafile(item)}
                except OSError:meta={'relpath':relative,'kind':focus,'bytes':size,'status':'READ_ERROR'}
                if size<=MAX_HASH_BYTES:
                    try:meta['preview']=table_preview(item)
                    except OSError:meta['preview']={'decode':'READ_ERROR'}
                tables.append(meta)
            if category in ('spr','mpc','asf') and len(bin_paths)<MAX_SAMPLE:
                bin_paths.append({'relpath':relative,'bytes':size})
        if truncated:break
    return {'label':display,'root':str(root),'scanned_files':total,'scanned_directories':hidden_dirs,
            'total_file_bytes_seen':source_size,'counts':dict(sorted(counts.items())),
            'truncated':truncated,'max_depth':max_depth,'errors':errors[:20],
            'samples':examples,'focus_paths':paths[:250],
            'pak_files':paks[:150],'pak_count_total':len(paks),
            'key_tables':tables[:250], 'table_count_total':len(tables),
            'sprite_samples':bin_paths}


def pilot_protagonist(root:Path,packs:list[Path],character:str='男主角',action:str='空手站立1')->dict:
    # This DOES NOT extract. Probe exact table chain and resource IDs against indexed PAK files.
    from jx1_player_pipeline_v4 import catalog_equipment_variants
    try:
        catalog=catalog_equipment_variants(root,character,action,packs)
        return {'status':'SOURCE_TABLE_CATALOG_VERIFIED','character':character,'action':action,
                'variants_found':catalog.get('variants_found'),
                'resource_base':catalog.get('resource_base'),
                'table_sha256':catalog.get('kind_table_sha256'),
                'groups':[{'label':g.get('label'),'variant_count':len(g.get('available_variants',[]))}
                          for g in catalog.get('groups',[])],
                'selected_paks':[str(x) for x in packs],
                'full_catalog':'Use AF-04 Playable UI for per-part full JSON and 8-direction render.'}
    except (OSError,ValueError,KeyError,TypeError) as exc:
        return {'status':'PENDING_SOURCE_MATCH','character':character,'reason':str(exc)[:500]}


def find_kind_root(scan:dict)->Path|None:
    base=Path(scan['root'])
    for row in scan['key_tables']:
        if row['kind']!='player_kind_table':continue
        path=Path(row['relpath'])
        parts=[x.casefold() for x in path.parts]
        if len(parts)<3 or parts[-3:]!=['settings','npcres','人物类型.txt']:
            continue
        result=base.joinpath(*path.parts[:-3]);
        if result.is_dir():return result
    return None


def audit(source:Path,tool:Path,out:Path,max_files:int=MAX_PATHS,max_depth:int=12,
          pak_pilot_limit:int=3)->dict:
    source=source.resolve(strict=True);tool=tool.resolve(strict=True)
    dest=out.resolve(strict=False)
    if (dest==source or dest.is_relative_to(source) or dest==tool or dest.is_relative_to(tool)):
        raise ValueError('REPORT OUTPUT MUST BE OUTSIDE SOURCE ROOTS: read-only source isolation')
    results=[scan_root(source,'SOURCE',max_files,max_depth),scan_root(tool,'TOOL_JX',max_files,max_depth)]
    candidates=[]
    for result in results:
        kind_root=find_kind_root(result)
        valid_paks=[(Path(result['root'])/r['relpath']).resolve() for r in result['pak_files']
                    if r['header']['status']=='JX1_PACK_HEADER_VALID']
        candidates.append({'source_label':result['label'],
                           'client_root':str(kind_root) if kind_root else None,
                           'pak_header_valid':len(valid_paks),
                           'pak_paths_for_pilot':[str(x) for x in valid_paks[:pak_pilot_limit]],
                           'source_player_table_present':bool(kind_root),
                           'unverified_real_binaries':True})
    pilot=[]
    for c in candidates:
        if c['client_root']:
            root=Path(c['client_root'])
            packs=[Path(x) for x in c['pak_paths_for_pilot']]
            pilot.append(pilot_protagonist(root,packs))
    result={'schema':'TMB_C5_JX1_COMBAT_INTAKE_V1',
            'timestamp_utc':datetime.now(timezone.utc).isoformat(),
            'scope':'READ_ONLY_LOCAL_OWNER_SOURCE','source_roots':[str(source),str(tool)],
            'sources':results,'candidate_clients':candidates,'player_catalog_probes':pilot,
            'performance_targets':{'display':'Android landscape 1280x720',
                'combat_rules':'Combat V2 unchanged',
                'camera':'free pan; follow only explicitly selected character',
                'render':'tile/chunk viewport culling, texture cache, draw interpolation between real V2 positions',
                'fx':'cap visible particles/impact; do not drop gameplay damage',
                'actor':'source-derived 8/16 direction atlas, anchor/ordering validated',
                'load':'do not eagerly decode entire PAK or map at game startup',
                'qa':'Windows 4.7.2 runtime and Android frame time PENDING USER'},
            'safety':{'input_files_modified':False,'pak_bulk_extracted':False,
                      'source_executables_run':False,'archive_unpacking_performed':False},
            'status':'INVENTORY_COMPLETE_REAL_BINARY_DECODING_PENDING_PILOT'}
    out.mkdir(parents=True,exist_ok=True)
    manifest=out/'JX1_COMBAT_SOURCE_MANIFEST.json';summary=out/'JX1_COMBAT_SUMMARY.md'
    manifest.write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
    lines=['# TÔNG MÔN BÁ ĐẠO — Source Combat Intake',
           'READ-ONLY, no code/gameplay/save edits, no archive extraction.',
           '', '## Inventory']
    for s in results:
        lines.extend([f"- **{s['label']}**: `{s['root']}`", f"  - {s['scanned_files']} files, {s['scanned_directories']} directories, truncated={s['truncated']}",
                      f"  - Categories: {json.dumps(s['counts'],ensure_ascii=False)}",
                      f"  - JX1 PACK candidates: {len(s['pak_files'])}; key tables: {s['table_count_total']}"])
    lines.extend(['','## Candidate original JX1 client & player pipeline'])
    for c in candidates:lines.append('- '+json.dumps(c,ensure_ascii=False))
    for p in pilot:lines.append('- '+json.dumps(p,ensure_ascii=False))
    lines.extend(['','## Next technical gate','- Verify source Kind/Part/Sect tables and PACK hash hits.',
                  '- Export one original JX1 male/female idle/walk/attack/skill SPR preview (AF-04).',
                  '- Build source-backed animation/FX/map manifests; use visible-chunk culling and frame-time profiling in Godot 4.7.2.',
                  '- Preserve Combat V2, 6/team, 30+40 stress fixture, free camera and mobile landscape.',
                  '- Windows physical runtime and FPS are PENDING until logs/screenshots exist.', ''])
    summary.write_text('\n'.join(lines),encoding='utf-8')
    return {'manifest':str(manifest),'summary':str(summary),'candidate_clients':candidates,
            'pilot':pilot,'files_scanned':sum(x['scanned_files'] for x in results),
            'status':result['status']}


def main(argv:list[str]|None=None)->int:
    p=argparse.ArgumentParser(description='AF C5/JX1 two-root read-only combat inventory')
    p.add_argument('--source',default=r'E:\Source');p.add_argument('--tool',default=r'E:\Tool JX')
    p.add_argument('--out',default=r'E:\TongMonBaDao_AssetVault\06_reports\JX1_Combat_Intake')
    p.add_argument('--max-files',type=int,default=MAX_PATHS)
    p.add_argument('--max-depth',type=int,default=12)
    p.add_argument('--pak-pilot-limit',type=int,default=3)
    args=p.parse_args(argv)
    if not 1<=args.max_files<=MAX_PATHS or not 1<=args.max_depth<=20 or not 0<=args.pak_pilot_limit<=6:
        p.error('invalid scan limits')
    try:report=audit(Path(args.source),Path(args.tool),Path(args.out),args.max_files,args.max_depth,args.pak_pilot_limit)
    except (OSError,ValueError) as e:
        print('ERROR:',e,file=sys.stderr);return 2
    print(json.dumps(report,ensure_ascii=False,indent=2));return 0

if __name__=='__main__':sys.exit(main())
