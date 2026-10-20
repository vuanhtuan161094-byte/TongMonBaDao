#!/usr/bin/env python3
"""AF-04: evidence-gated JX1 protagonist equipment/animation catalog and contact sheet.

Kingsoft tables: 人物类型.txt (male/female protagonist), Kind -> Part -> Sect;
XPackFile 'PACK', ZPackFile filename hash, CSortTable direction and frame ordering.
No gameplay import. Does not infer a player from Special NPC alone. Never modifies raw.
"""
from __future__ import annotations
import argparse
import hashlib
import json
import re
from pathlib import Path
from dataclasses import dataclass
from typing import Any

from jx1_adapter import Spr
from jx1_pak_v2 import jx1_path_hash, pak_index, read_pak_entry_record
from jx1_tables_v2 import player_table_catalog, _canonical_within

PROTAGONIST_RECORDS = {'男主角':'MALE_PLAYER_RESOURCE', '女主角':'FEMALE_PLAYER_RESOURCE'}
SOURCE_REVISION = 'b2e251a93f862571221b17cc1e92ceb121fc3069'
MAX_CHOICES=16
MAX_PACKS=6
MAX_DIRECTIONS=16
MAX_PREVIEW_LAYERS=16
MAX_CONTACT_SHEET_PIXELS=6_000_000


def sha(data:bytes)->str:
    return hashlib.sha256(data).hexdigest()


def _load_sort(path:Path)->tuple[dict[str,dict[str,str]],str]:
    path=Path(path)
    raw=path.read_bytes()
    if len(raw)>8*1024*1024:raise ValueError('sort table too large')
    for encoding in ('utf-8-sig','gb18030'):
        try:
            data=raw.decode(encoding);break
        except UnicodeDecodeError:continue
    else:raise ValueError('sort table encoding unsupported')
    if '\x00' in data:raise ValueError('sort table binary data')
    sections={}; current=None
    for rawline in data.splitlines():
        line=rawline.strip()
        if not line or line.startswith((';','#')):continue
        if line.startswith('[') and line.endswith(']'):
            current=line[1:-1].strip()
            if not current or current in sections:raise ValueError('duplicate/empty sort section')
            sections[current]={};continue
        if current is None or '=' not in line:raise ValueError('invalid sort INI')
        key,value=[x.strip() for x in line.split('=',1)]
        if key in sections[current]:raise ValueError('duplicate sort key')
        sections[current][key]=value
    if 'DEFAULT' not in sections:raise ValueError('JX1 sort DEFAULT missing')
    return sections,sha(raw)


def _order(text:str,available:set[int])->list[int]:
    try: seq=[int(x.strip()) for x in text.split(',') if x.strip()]
    except ValueError as e:raise ValueError('invalid sort integer') from e
    if not seq or len(seq)>17:raise ValueError('invalid JX1 sort order length')
    # First integer in CSortTable is a sentinel frame-index -1 for Dir*, else Line frame number.
    order=seq[1:]
    if len(order)!=len(set(order)) or any(v < -1 or v>15 for v in order):
        raise ValueError('invalid/duplicate JX1 part sort indices')
    listed=[idx for idx in order if idx>=0]
    # An original JX1 direction can hide an equipment layer intentionally.
    # Keep that source order instead of inventing an order for omitted parts.
    return listed


def _sort_for(sections:dict[str,dict[str,str]],action:str,direction:int,frame:int,available:set[int])->list[int]:
    act=sections.get(action,{})
    for key,value in act.items():
        if re.fullmatch(r'Line\d+',key):
            try: target=int(value.split(',',1)[0].strip())
            except ValueError as e:raise ValueError('invalid special frame sort') from e
            if target==frame:return _order(value,available)
    val=act.get(f'Dir{direction+1}') or sections['DEFAULT'].get(f'Dir{direction+1}')
    if not val:raise ValueError(f'missing source sort for direction {direction+1}')
    return _order(val,available)


def _select_actions(catalog:dict,action:str,choices:dict[str,int])->list[dict]:
    if not isinstance(choices,dict) or len(choices)>MAX_CHOICES or any(not isinstance(k,str) for k in choices):
        raise ValueError('equipment choices must be <=16 string-keyed object')
    items=[];known=set()
    for group in catalog['groups']:
        key=group['label']; idx=group['group']*4+group['section']
        known.add(key)
        choice=choices.get(key,0)
        if type(choice) is not int or choice<0:raise ValueError('variant index must be nonnegative integer')
        # Some equipment groups genuinely lack a graphic for an action. Keep report exact.
        variants={v['equip_variant_row']:v for v in group['variants']}
        if not variants:
            if key in choices:raise ValueError(f'no variants defined for selected source part {key}')
            items.append({'label':key,'part_index':idx,'variant':choice,'status':'NO_EQUIPMENT_ROWS_IN_TABLE'})
            continue
        if choice not in variants:raise ValueError(f'variant {choice} not in source part {key}')
        original=variants[choice]['actions'].get(action)
        if not original:
            items.append({'label':key,'part_index':idx,'variant':choice,'status':'NO_ACTION_GRAPHIC_IN_TABLE'})
            continue
        leaf=original['spr_leaf']
        if not leaf.lower().endswith('.spr'):
            raise ValueError('non-SPR entry referenced by JX1 part table')
        full='\\'+catalog['resource_base'].strip('\\/')+'\\'+leaf.lstrip('\\/')
        if '/' in full:full=full.replace('/','\\')
        uid=jx1_path_hash(full)
        items.append({'label':key,'part_index':idx,'group':group['group'],'section':group['section'],
                      'variant':choice,'action':action,'leaf':leaf,'virtual_path':full,'id':uid,
                      'sect_table_sha256':group['table_sha256'],'status':'REFERENCE_FROM_SOURCE_TABLE'})
    extra=set(choices)-known
    if extra:raise ValueError('unknown source part labels: '+', '.join(sorted(extra)))
    if len(items)>MAX_PREVIEW_LAYERS:raise ValueError('too many JX1 player parts')
    return items


def _resolve_spr(root:Path,item:dict,pack_indexes:list[tuple[Path,dict]])->tuple[bytes,dict]:
    uid=item['id']
    matches=[(path,index[uid]) for path,index in pack_indexes if uid in index]
    if len(matches)>1:raise ValueError('ambiguous resource ID present in multiple selected PACKs')
    loose=_canonical_within(root,item['virtual_path'])
    raw_loose=None
    if loose.is_file():
        if loose.is_symlink() or loose.stat().st_size>32*1024*1024:
            raise ValueError('unsafe loose SPR file')
        raw_loose=loose.read_bytes()
    raw_pack=None
    if matches:
        path,entry=matches[0]
        raw_pack=read_pak_entry_record(path,entry)
    if raw_pack is None and raw_loose is None:
        raise FileNotFoundError('JX1 SPR absent from selected loose root and PACKs: '+item['virtual_path'])
    if raw_loose is not None and raw_pack is not None and raw_loose!=raw_pack:
        raise ValueError('loose SPR / PACK mismatch, refusing ambiguous source')
    raw=raw_pack if raw_pack is not None else raw_loose
    provenance={'source':'PACK_ID' if raw_pack is not None else 'LOOSE_SPR',
                'loose_path':str(loose) if raw_loose is not None else None,
                'pak':str(matches[0][0]) if matches else None,
                'pak_id':uid if matches else None,'sha256':sha(raw),'size':len(raw)}
    return raw,provenance


def catalog_selected_player(root:Path,character:str,action:str,choices:dict[str,int],packs:list[Path],
                            max_rows:int=64)->dict:
    """Build one exact action/loadout without touching original files or game state."""
    root=Path(root).resolve(strict=True)
    if not root.is_dir():raise ValueError('source root must be a directory')
    # Only two precisely sourced playable records in SourceInit-JX1 reference tables.
    # Other NPC_RES_SPECIAL entries need an independent playable proof, not guesses.
    if character not in PROTAGONIST_RECORDS:
        raise ValueError('JX1 playable proof missing: AF-04 only supports source 男主角 or 女主角')
    if not action or len(action)>80 or '/' in action or '\\' in action:
        raise ValueError('invalid source action column')
    if len(packs)>MAX_PACKS:raise ValueError('select at most six PAK files')
    kind=_canonical_within(root,'settings/npcres/人物类型.txt')
    if not kind.is_file():raise FileNotFoundError('missing source Kind table: '+str(kind))
    catalog=player_table_catalog(kind,character,kind.parent,max_rows=max_rows)
    if not catalog['is_composite_kind'] or catalog['unresolved']:
        raise ValueError('source protagonist composite tables unresolved: '+', '.join(catalog['unresolved']))
    if not catalog['groups']:raise ValueError('player part table contains no groups')
    part=_select_actions(catalog,action,choices)
    active=[item for item in part if item['status']=='REFERENCE_FROM_SOURCE_TABLE']
    if not active:raise ValueError('no selected JX1 source SPR references for action')
    if not any(item['label'] in ('躯体','身躯') for item in active):
        raise ValueError('protagonist body part missing for selected action')
    sort_rel=catalog['player_resource_record']['columns'].get('动作贴图顺序表','')
    if not sort_rel:raise ValueError('player source sort table not declared')
    sort_path=_canonical_within(kind.parent,sort_rel)
    if not sort_path.is_file():raise FileNotFoundError('source sort table missing: '+str(sort_path))
    orders,order_hash=_load_sort(sort_path)
    indexed=[]
    for p in packs:
        pp=Path(p).resolve(strict=True)
        if not pp.is_file():raise ValueError('PACK path not a real file')
        info=pak_index(pp)
        ids={}
        for entry in info['entries']:
            if entry['id'] in ids:raise ValueError('duplicate PACK asset IDs')
            ids[entry['id']]=entry
        indexed.append((pp,ids))
    spr_cache={};by_part={};report=[]
    for item in active:
        raw,prov=_resolve_spr(root,item,indexed)
        spr=Spr(raw)
        by_part[item['part_index']]=spr
        spr_cache[item['part_index']]=raw
        report.append({**item,'source':prov,'spr_header':spr.header,'status':'REAL_SPR_BYTES_VALIDATED'})
    # All selected part sprites must define a consistent direction count.
    directions={spr.header['directions'] for spr in by_part.values()}
    if len(directions)!=1:raise ValueError('JX1 part direction counts conflict; alignment pending')
    ndirs=directions.pop()
    if ndirs not in (8,16):raise ValueError('JX1 playable contact sheet requires 8 or 16 actual directions')
    for d in range(ndirs):_sort_for(orders,action,d,0,set(by_part))
    return {'source_family':'JX1_SOURCEINIT','character':character,'playable_source_proof':{
               'kind_row':catalog['player_resource_record']['row_number'],
               'kind_table_sha256':catalog['player_resource_record']['table_sha256'],
               'kind_value':'特殊npc','player_role':PROTAGONIST_RECORDS[character],
               'public_source_revision':SOURCE_REVISION,'part_table_sha256':catalog['part_table']['sha256']},
            'action':action,'choices':choices,'directions':ndirs,'selected':report,
            'skipped':[item for item in part if item['status']!='REFERENCE_FROM_SOURCE_TABLE'],
            'source_sort_sha256':order_hash,'source_sort_path':str(sort_path),
            'source_sort_rules':orders,'source_root':str(root),'pack_paths':[str(x[0]) for x in indexed],
            'status':'SOURCE_PLAYER_ROW_AND_SELECTED_SPR_BYTES_VALIDATED__VISUAL_ACCEPTANCE_PENDING',
            '_render_sprs':by_part}


def render_player_sheet(report:dict,target:Path,frame:int=0,render_dirs:int=8)->dict:
    """Render chosen source-backed modular layers. Geometry remains visual-QA provisional."""
    try:
        from PIL import Image, ImageDraw
    except ImportError as exc:
        raise RuntimeError('Pillow needed for contact sheet: pip install pillow') from exc
    if type(frame) is not int or frame<0:raise ValueError('frame must be >=0')
    if type(render_dirs) is not int or not 1<=render_dirs<=MAX_DIRECTIONS:
        raise ValueError('render_dirs outside 1..16')
    render_dirs=min(render_dirs,report['directions'])
    selected=report['_render_sprs']
    if not selected:raise ValueError('no source-backed SPR assets')
    if any(frame>=spr.header['frames_per_direction'] for spr in selected.values()):
        raise ValueError('selected frame unavailable in at least one real source SPR')
    cols=min(4,render_dirs)
    rows=(render_dirs+cols-1)//cols
    tilew,tileh=236,260
    if cols*tilew*rows*tileh>MAX_CONTACT_SHEET_PIXELS:raise ValueError('sheet too large')
    canvas=Image.new('RGBA',(cols*tilew,rows*tileh),(18,25,33,255))
    painter=ImageDraw.Draw(canvas)
    drows=[]
    for d in range(render_dirs):
        order=_sort_for(report['source_sort_rules'],report['action'],d,frame,set(selected))
        ox=(d%cols)*tilew;oy=(d//cols)*tileh
        painter.text((ox+8,oy+8),f"JX1 {report['character']}  dir {d+1}",fill=(245,247,249))
        for idx in order:
            if idx not in selected:continue
            spr=selected[idx]
            frame_idx=d*spr.header['frames_per_direction']+frame
            rgba,details=spr.decode_rgba(frame_idx)
            pic=Image.frombytes('RGBA',(details['width'],details['height']),rgba)
            # Derived from actual source SPR metadata, not magic UI layering constants.
            # Preview geometry is still provisional until direct Windows art acceptance.
            x=ox+tilew//2 + details['offset_x']-spr.header['center_x']
            y=oy+tileh-28 + details['offset_y']-spr.header['center_y']
            if not (ox-pic.width<x<ox+tilew and oy-pic.height<y<oy+tileh):
                raise ValueError('SPR layer outside its preview tile; visual alignment pending')
            # Clip at tile edges: directions must never bleed into adjacent cells.
            ix0=max(ox,x);iy0=max(oy,y)
            ix1=min(ox+tilew,x+pic.width);iy1=min(oy+tileh,y+pic.height)
            if ix1>ix0 and iy1>iy0:
                cropped=pic.crop((ix0-x,iy0-y,ix1-x,iy1-y))
                canvas.alpha_composite(cropped,(ix0,iy0))
        drows.append({'direction':d,'source_sort_order':order,'frame_sampled':frame})
    out=Path(target).resolve()
    if out.suffix.lower()!='.png' or out.exists() or out.with_suffix('.json').exists():
        raise FileExistsError('new .png output path required; never overwrite preview')
    out.parent.mkdir(parents=True,exist_ok=True)
    manifest={key:value for key,value in report.items() if not key.startswith('_') and key!='source_sort_rules'}
    manifest.update({'rendered_directions':drows,'png_path':str(out),
                     'status':'CONTACT_SHEET_GENERATED_FROM_SELECTED_SPR_BYTES__OWNER_VISUAL_PENDING',
                     'warning':'Source SPR offsets/direction order used; pixel alignment requires real Windows GUI review.'})
    png_temp=out.with_name(out.name+'.tmp')
    try:
        canvas.save(png_temp,format='PNG')
        manifest['png_sha256']=sha(png_temp.read_bytes())
        json_temp=out.with_name(out.stem+'.json.tmp')
        json_temp.write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
        png_temp.rename(out)
        json_temp.rename(out.with_suffix('.json'))
    finally:
        png_temp.unlink(missing_ok=True)
        out.with_name(out.stem+'.json.tmp').unlink(missing_ok=True)
    return manifest



def catalog_equipment_variants(root:Path,character:str,action:str,packs:list[Path],max_rows:int=64)->dict:
    """Catalog actual Kind/Part/Sect row variants even if SPR binaries are missing.

    This is a genuine source-table catalog, NOT a playable sprite visual QA.
    """
    root=Path(root).resolve(strict=True)
    if character not in PROTAGONIST_RECORDS:
        raise ValueError('only source-proven male/female protagonist rows allowed')
    kind=_canonical_within(root,'settings/npcres/人物类型.txt')
    source=player_table_catalog(kind,character,kind.parent,max_rows=max_rows)
    if not source['is_composite_kind'] or source['unresolved']:
        raise ValueError('incomplete source Kind/Part/Sect chain: '+', '.join(source['unresolved']))
    if len(packs)>MAX_PACKS:raise ValueError('too many selected PAK archives')
    packrefs=[]
    for p in packs:
        pp=Path(p).resolve(strict=True)
        index=pak_index(pp)
        packrefs.append((pp,{e['id'] for e in index['entries']}))
    out=[]
    for g in source['groups']:
        variants=[]
        for variant in g['variants']:
            a=variant['actions'].get(action)
            if not a:continue
            leaf=a['spr_leaf']
            path='\\'+source['resource_base'].strip('\\/')+'\\'+leaf.lstrip('\\/')
            path=path.replace('/','\\')
            uid=jx1_path_hash(path)
            variants.append({'row':variant['equip_variant_row'],
                             'name':variant.get('source_variant_name',''),
                             'spr_leaf':leaf,'virtual_path':path,'id':uid,
                             'pak_index_hits':[str(pp) for pp,ids in packrefs if uid in ids],
                             'loose_exists':_canonical_within(root,path).is_file()})
        out.append({'label':g['label'],'part_index':g['group']*4+g['section'],
                    'table_sha256':g.get('table_sha256'), 'available_variants':variants})
    return {'source_family':'JX1_SOURCEINIT','character':character,
            'character_source_role':PROTAGONIST_RECORDS[character],
            'kind_table_sha256':source['player_resource_record']['table_sha256'],
            'part_table_sha256':source['part_table']['sha256'],
            'action':action,'groups':out,'variants_found':sum(len(x['available_variants']) for x in out),
            'selected_paks':[str(x) for x in packs],
            'status':'SOURCE_CHARACTER_COSTUME_CATALOG__SPR_RENDER_AND_OWNER_QA_PENDING'}


def main()->None:
    p=argparse.ArgumentParser(description='AF-04 JX1 source protagonist catalog + 8/16-dir contact sheet')
    p.add_argument('--source-root',type=Path,required=True,help='Unmodified owner JX1 source folder with settings/npcres')
    p.add_argument('--character',choices=sorted(PROTAGONIST_RECORDS),required=True)
    p.add_argument('--action',required=True,help='Exact JX1 action header, e.g. 空手站立1')
    p.add_argument('--choices',default='{}',help='JSON part label -> 0-based outfit/equipment row')
    p.add_argument('--pak',type=Path,action='append',default=[],help='Only selected PACK archive(s), max 6')
    p.add_argument('--out',type=Path,required=True,help='New PNG output (JSON alongside)')
    p.add_argument('--frame',type=int,default=0)
    p.add_argument('--directions',type=int,choices=(8,16),default=8)
    p.add_argument('--catalog-only',action='store_true',help='Write source-backed variant JSON, no binary SPR required')
    args=p.parse_args()
    choices=json.loads(args.choices)
    if args.catalog_only:
        data=catalog_equipment_variants(args.source_root,args.character,args.action,args.pak)
        dest=args.out.resolve()
        if dest.suffix.lower()!='.json' or dest.exists():raise FileExistsError('new .json path required for catalog')
        dest.parent.mkdir(parents=True,exist_ok=True)
        with dest.open('x',encoding='utf-8') as handle: json.dump(data,handle,ensure_ascii=False,indent=2)
        print(json.dumps({'catalog':str(dest),'variants':data['variants_found'],'status':data['status']},ensure_ascii=False))
    else:
        report=catalog_selected_player(args.source_root,args.character,args.action,choices,args.pak)
        exported=render_player_sheet(report,args.out,args.frame,args.directions)
        print(json.dumps({'png':str(args.out),'parts':len(report['selected']),
                          'directions':len(exported['rendered_directions']),'status':exported['status']},ensure_ascii=False,indent=2))

if __name__=='__main__':main()