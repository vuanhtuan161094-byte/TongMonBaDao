#!/usr/bin/env python3
"""Tông Môn Bá Đạo Asset Forge Studio V1.

Offline CLI for curated staging, evidence-based JXQY2 map/skill inspection and
non-destructive edit recipes. No gameplay, save or Godot runtime edits.
"""
from __future__ import annotations
import argparse
import hashlib
import io
import json
import os
from pathlib import Path
import re
import shutil
import struct
import sys
from typing import Any
from forge import digest, jxqy_player, load_ini, map_probe, mpc_metadata, safe_file, write_json

MAX_COPY_BYTES = 256 * 1024 * 1024
SUPPORTED = {'.map', '.mpi', '.mpc', '.asf', '.ini', '.txt', '.spr', '.pak', '.png', '.webp', '.json', '.skel', '.atlas', '.wav', '.ogg', '.tpsheet', '.tres', '.tscn'}
FOLDERS = ['00_inbox', '01_raw', '02_catalog', '03_derived', '04_previews', '05_approved_packs', '06_reports', '07_tools_cache', 'quarantine']
SOURCES = {'SOURCE_A':'owner_approved','JX1_OWNER':'owner_approved', 'JXQY2_OFFLINE':'review_required', 'JX1M_UNITY':'review_required', 'JX2_ONLINE':'review_required'}


def json_print(data: Any) -> None:
    print(json.dumps(data, ensure_ascii=False, indent=2))


def vault_paths(base: Path) -> dict[str, Path]:
    base = Path(base).resolve()
    return {name: base / name for name in FOLDERS}


def init_vault(base: Path) -> dict:
    d = vault_paths(base)
    for path in d.values(): path.mkdir(parents=True, exist_ok=True)
    for source in SOURCES: (d['01_raw'] / source).mkdir(exist_ok=True)
    for target in ['maps', 'skills', 'players']:
        (d['03_derived'] / target).mkdir(parents=True, exist_ok=True)
        (d['04_previews'] / target).mkdir(parents=True, exist_ok=True)
    registry = d['02_catalog'] / 'source_registry.json'
    if not registry.exists():
        write_json(registry, {'schema':1,'sources':{name:{'rights_status':state,'source_type':'local_user_supplied' if state=='owner_approved' else 'public_reference','approval_scope':'OWNER_PROVIDED_ONLY' if state=='owner_approved' else 'NOT_APPROVED_FOR_PUBLISH'} for name,state in SOURCES.items()}})
    return {'vault':str(Path(base).resolve()), 'created':[str(p) for p in d.values()], 'source_registry':str(registry), 'status':'READY_NO_RAW_FILES_COPIED'}


def safe_source_id(source_id: str) -> str:
    if not re.fullmatch(r'[A-Z0-9_]{2,40}',source_id):
        raise ValueError('source_id must contain only A-Z 0-9 underscore')
    return source_id


def safe_relpath(raw: str) -> Path:
    if not isinstance(raw,str) or not raw or '\x00' in raw or '\\' in raw:
        raise ValueError('invalid relative path')
    p=Path(raw)
    if p.is_absolute() or any(item in ('','.', '..') for item in p.parts) or ':' in raw:
        raise ValueError('path traversal/absolute path refused')
    return p


def staged_manifest_path(base:Path,source_id:str) -> Path:
    return vault_paths(base)['02_catalog'] / ('staged_'+safe_source_id(source_id)+'.json')


def stage_files(vault:Path,source_id:str,source_root:Path,relpaths:list[str]) -> dict:
    init_vault(vault)
    sid=safe_source_id(source_id)
    source_root=Path(source_root).resolve(strict=True)
    if not source_root.is_dir(): raise ValueError('source root is not a directory')
    dstroot=vault_paths(vault)['01_raw']/sid
    if dstroot == source_root or dstroot.is_relative_to(source_root) or source_root.is_relative_to(dstroot):
        raise ValueError('cannot stage into/from an overlapping raw directory')
    manifest=staged_manifest_path(vault,sid)
    prior=json.loads(manifest.read_text(encoding='utf-8')) if manifest.exists() else {'schema':1,'source_id':sid,'files':{}}
    copied=[];unchanged=[];conflicts=[]
    for path_string in sorted(set(relpaths)):
        rel=safe_relpath(path_string)
        if rel.suffix.lower() not in SUPPORTED: raise ValueError('unsupported extension: '+str(rel))
        source=safe_file(source_root,rel)
        if not source.is_file() or source.is_symlink(): raise FileNotFoundError('missing/symlink source: '+str(rel))
        sha,size=digest(source)
        if size>MAX_COPY_BYTES: raise ValueError(f'oversized asset {rel}; stage separately after review')
        target=safe_file(dstroot,rel)
        if target.is_symlink() or target.parent == source.parent: raise ValueError('unsafe target path')
        if target.exists():
            before,target_size=digest(target)
            if before!=sha or target_size!=size:
                conflicts.append(str(rel))
                continue  # Never overwrite immutable staged raw.
            unchanged.append(str(rel))
        else:
            target.parent.mkdir(parents=True,exist_ok=True)
            tmp=target.with_name(target.name+'.af_tmp')
            if tmp.exists(): raise ValueError('existing staging temp file requires manual inspection: '+str(tmp))
            try:
                with source.open('rb') as fin, tmp.open('xb') as fout:
                    shutil.copyfileobj(fin,fout,1024*1024)
                actual,actual_size=digest(tmp)
                if (actual,actual_size)!=(sha,size): raise OSError('copy/hash mismatch')
                os.replace(tmp,target)
            finally:
                if tmp.exists(): tmp.unlink()
            copied.append(str(rel))
        prior['files'][rel.as_posix()]={'sha256':sha,'size_bytes':size,'from_root':str(source_root),'stage':'RAW_IMMUTABLE','classification':'CANDIDATE_UNVERIFIED','rights':'owner_provided' if sid in ('SOURCE_A','JX1_OWNER') else 'review_required'}
    write_json(manifest,prior)
    return {'source_id':sid,'copied':copied,'already_identical':unchanged,'conflicts_not_overwritten':conflicts,'files_total':len(prior['files']),'manifest':str(manifest),'raw_destination':str(dstroot)}


def probe_map(path:Path) -> dict:
    data=path.read_bytes()
    info=map_probe(data)
    offset=192+255*64
    names={}
    for i in range(255):
        pos=192+i*64
        raw=data[pos:pos+32].split(b'\0',1)[0]
        if raw:
            try: name=raw.decode('utf-8')
            except UnicodeDecodeError: name=raw.decode('gb18030',errors='replace')
            number=struct.unpack_from('<i',data,pos+32)[0]
            names[number]=name
    info.update({'source_file':str(path),'sha256':hashlib.sha256(data).hexdigest(), 'tile_dictionary':names,'grid_offset':offset,'cell_bytes':10,'editable_fields':['layer0_frame','layer0_id','layer1_frame','layer1_id','layer2_frame','layer2_id','obstacle','trap']})
    return info


def map_patch(src:Path,recipe:Path,dest:Path)->dict:
    src=src.resolve(strict=True);dest=dest.resolve()
    if src==dest: raise ValueError('output must be different from immutable input')
    baseline=src.read_bytes();info=probe_map(src)
    spec=json.loads(recipe.read_text(encoding='utf-8'))
    if not isinstance(spec,dict) or spec.get('source_sha256')!=info['sha256']:
        raise ValueError('recipe requires exact matching source_sha256 (stale/mismatched source)')
    edits=spec.get('edits',[])
    if not isinstance(edits,list) or not 0<len(edits)<=5000: raise ValueError('invalid edits count')
    valid_fields={'layer0_frame':0,'layer0_id':1,'layer1_frame':2,'layer1_id':3,'layer2_frame':4,'layer2_id':5,'obstacle':6,'trap':7}
    output=bytearray(baseline)
    seen=set()
    for edit in edits:
        if not isinstance(edit,dict):raise ValueError('invalid edit object')
        x,y,field,value=edit.get('x'),edit.get('y'),edit.get('field'),edit.get('value')
        if type(x)!=int or type(y)!=int or field not in valid_fields or type(value)!=int or not 0<=value<=255:
            raise ValueError('invalid coordinates/field/value')
        if not 0<=x<info['width'] or not 0<=y<info['height']: raise ValueError('cell out of map')
        if (x,y,field) in seen:raise ValueError('duplicate edit')
        seen.add((x,y,field))
        if field.endswith('_id') and value!=0 and value not in info['tile_dictionary']:
            raise ValueError('tile id not defined in source map dictionary: '+str(value))
        offset=info['grid_offset']+(y*info['width']+x)*10+valid_fields[field]
        output[offset]=value
    map_probe(output)
    dest.parent.mkdir(parents=True,exist_ok=True)
    if dest.exists(): raise FileExistsError('output already exists; no overwrite')
    dest.write_bytes(output)
    result={'status':'NEW_DERIVED_MAP_NOT_GAMEPLAY','source_path':str(src),'source_sha256':info['sha256'],'derived_path':str(dest),'derived_sha256':hashlib.sha256(output).hexdigest(),'edits':len(edits),'collision_source':'MAP_BINARY','raw_unchanged':hashlib.sha256(src.read_bytes()).hexdigest()==info['sha256']}
    write_json(dest.with_suffix(dest.suffix+'.provenance.json'),result)
    return result


def first_frames_by_direction(data:bytes, max_dirs:int=8):
    dec=mpc_metadata(data)
    frames=[]
    for direction in range(min(dec['directions'],max_dirs)):
        frame_idx=direction*dec['frames_per_direction']
        png, anchor=dec['frames'][frame_idx]
        frames.append((direction,frame_idx,png,anchor))
    return dec,frames


def contact_sheet(items:list[tuple[str, bytes]], dest:Path, title:str, max_dirs:int=8)->dict:
    try: from PIL import Image,ImageDraw
    except ImportError as e:raise RuntimeError('Pillow required: pip install pillow') from e
    if not items:raise ValueError('no real source MPC frames provided')
    cellw,cellh=155,200
    cols=4; rows=0
    decoded=[]
    for label,raw in items:
        dec,frames=first_frames_by_direction(raw,max_dirs)
        decoded.append((label,dec,frames))
        rows+=(len(frames)+cols-1)//cols
    sheet=Image.new('RGBA',(cols*cellw,max(65+rows*cellh,180)),(29,34,42,255))
    d=ImageDraw.Draw(sheet)
    d.text((12,12),title,fill='white')
    y0=65; manifest=[]
    for label,dec,frames in decoded:
        numrows=(len(frames)+cols-1)//cols
        for index,(direction,frame_idx,png,anchor) in enumerate(frames):
            pic=Image.open(io.BytesIO(png)).convert('RGBA')
            pic.thumbnail((135,151),Image.Resampling.LANCZOS)
            x=(index%cols)*cellw+10;y=y0+(index//cols)*cellh
            sheet.alpha_composite(pic,(x+(135-pic.width)//2,y+25+(150-pic.height)))
            d.text((x,y+5),label[:21],fill=(232,239,250))
            d.text((x,y+181),f'dir={direction} frame={frame_idx}',fill=(170,210,175))
        manifest.append({'asset':label,'frames':dec['frame_count'],'directions':dec['directions'],'interval_ms':dec['interval_ms']})
        y0+=numrows*cellh
    dest.parent.mkdir(parents=True,exist_ok=True)
    sheet.convert('RGB').save(dest,'PNG')
    return {'preview':str(dest),'source_assets':manifest,'status':'RENDERED_FROM_REAL_MPC_BYTES'}


def skill_graph(root:Path,name:str)->dict:
    ini_rel='ini/magic/player-magic-'+name+'.ini'
    p=safe_file(root,ini_rel)
    if not p.is_file():raise FileNotFoundError(str(p))
    skill=load_ini(p)
    if not skill.has_section('init'):raise ValueError('missing [init] section')
    links={}
    columns={'icon':('icon','mpc/magic'), 'ui_image':('image','mpc/magic'), 'projectile':('flyingimage','mpc/effect'), 'impact':('vanishimage','mpc/effect'), 'cast_action_override':('actionfile','mpc/character')}
    for key,(field,folder) in columns.items():
        original=skill.get('init',field,fallback='').strip()
        if not original:links[key]={'state':'NOT_DECLARED','relative_path':None};continue
        rel=folder+'/'+original
        real=safe_file(root,rel)
        links[key]={'state':'FOUND' if real.is_file() else 'MISSING','relative_path':rel,'sha256':digest(real)[0] if real.is_file() else None}
    # A generic actor cast is an independent resource, never inferred from UI icon.
    try:
        player=jxqy_player(root)
        caster=player['animations'].get('magic',{})
        cast={'state':'FOUND' if caster.get('exists') else 'MISSING', 'relative_path':caster.get('path'), 'sha256':caster.get('sha256'), 'basis':'playable.ini -> npcres [magic]'}
    except (OSError,ValueError,KeyError):cast={'state':'NOT_VERIFIED','relative_path':None}
    links['generic_player_cast']=cast
    return {'source':'JXQY2_OFFLINE_NOT_JX1_MMO','source_ini':ini_rel,'source_sha256':digest(p)[0], 'skill_name':name,'visual_links':links,'numeric_gameplay_imported':False,'school_and_weapon_requirement':'UNVERIFIED'}


def skill_preview(root:Path,name:str,dest:Path)->dict:
    graph=skill_graph(root,name)
    assets=[]
    for kind in ['generic_player_cast','projectile','impact']:
        data=graph['visual_links'].get(kind,{})
        if data.get('state')=='FOUND':
            path=safe_file(root,data['relative_path'])
            assets.append((kind,path.read_bytes()))
    if not assets:raise ValueError('no evidenced cast/projectile/impact MPC available')
    result=contact_sheet(assets,dest,f'JXQY2 skill (verified source paths): {name}')
    result['skill_graph']=graph
    write_json(dest.with_suffix('.json'),result)
    return result



def skill_visual_recipe(root:Path,name:str,adjustments:dict,dest:Path)->dict:
    """Create a *visual-only* recipe. Never write to source skill INI or Combat V2.

    This recipe is deliberately NOT auto-imported into Godot. The visual layer
    may consume it only after a separate explicit adapter integration.
    """
    graph=skill_graph(root,name)
    if not isinstance(adjustments,dict) or not adjustments:
        raise ValueError('nonempty visual adjustments required')
    allowed={'cast','projectile','impact'}
    defaults={'offset_x':0,'offset_y':0,'scale':1.0,'speed':1.0,'opacity':1.0,'z_index':0}
    validated={}
    for stage,params in adjustments.items():
        if stage not in allowed or not isinstance(params,dict):
            raise ValueError('only cast/projectile/impact stage adjustments allowed')
        if not set(params).issubset(defaults):raise ValueError('unknown or gameplay-affecting field')
        values=defaults.copy();values.update(params)
        for f in ['offset_x','offset_y','z_index']:
            if type(values[f])!=int or abs(values[f])>512:
                raise ValueError('offset/z must be small integer')
        for f,lo,hi in [('scale',0.1,4.0),('speed',0.1,4.0),('opacity',0.0,1.0)]:
            if type(values[f]) not in (int,float) or not lo<=values[f]<=hi:
                raise ValueError('invalid visual value: '+f)
        link={'cast':'generic_player_cast','projectile':'projectile','impact':'impact'}[stage]
        evidence=graph['visual_links'][link]
        if evidence.get('state')!='FOUND':
            raise ValueError(stage+' missing authentic source asset; recipe cannot reference it')
        validated[stage]={'source_path':evidence['relative_path'],'source_sha256':evidence['sha256'],'display':values}
    doc={'schema':'tmb_asset_forge_visual_skill_v1','source_family':'JXQY2_OFFLINE',
         'source_skill_ini':graph['source_ini'],'source_skill_sha256':graph['source_sha256'],
         'visual_skill_name':name,'stages':validated,'gameplay_change':False,
         'godot_published':False,'status':'DERIVED_VISUAL_RECIPE_UNPUBLISHED'}
    dest=Path(dest).resolve()
    if dest.exists():raise FileExistsError('visual recipe exists: refuse overwrite')
    write_json(dest,doc)
    return {'out':str(dest),'status':doc['status'],'stages':list(validated)}


def map_preview(map_path:Path,asset_root:Path,tile_dir:str,dest:Path,crop:tuple[int,int,int,int]|None=None,limit_cells:int=200000)->dict:
    try:from PIL import Image,ImageDraw
    except ImportError as e:raise RuntimeError('Pillow required') from e
    raw=map_path.read_bytes(); meta=probe_map(map_path)
    w,h=meta['width'],meta['height']
    cx,cy,cw,ch = crop or (0,0,w,h)
    if any(type(v)!=int for v in (cx,cy,cw,ch)) or min(cx,cy)<0 or min(cw,ch)<1 or cx+cw>w or cy+ch>h:
        raise ValueError('invalid map viewport crop')
    pixels=(cw*64+400)*(ch*16+550)
    if cw*ch>limit_cells or pixels>40_000_000 or cw*64+400>12000 or ch*16+550>12000:
        raise ValueError('preview too large; use --crop x y width height to render a region')
    image=Image.new('RGBA',(cw*64+400,ch*16+550),(19,24,32,255))
    offset=meta['grid_offset'];decoded={};missing=set();tiles=0
    # Authentic MAP staggered projection & MPC source tiles. No inferred background.
    for layer in range(3):
        for y in range(cy,cy+ch):
            for x in range(cx,cx+cw):
                cell=offset+(y*w+x)*10
                frame_idx=int(raw[cell+2*layer]);tile_id=int(raw[cell+2*layer+1])
                if not tile_id:continue
                name=meta['tile_dictionary'].get(tile_id)
                if not name:missing.add(f'id={tile_id}');continue
                rel=safe_relpath(tile_dir+'/'+name)
                tile=safe_file(asset_root,rel)
                if not tile.is_file():missing.add(rel.as_posix());continue
                if rel.as_posix() not in decoded:
                    decoded[rel.as_posix()]=mpc_metadata(tile.read_bytes())
                frames=decoded[rel.as_posix()]['frames']
                if frame_idx>=len(frames): missing.add(str(rel)+f'#frame={frame_idx}');continue
                png,(ax,ay)=frames[frame_idx]
                pix=Image.open(io.BytesIO(png)).convert('RGBA')
                foot_x=200+(x-cx)*64+(y%2)*32
                foot_y=200+(y-cy)*16
                if 0<=foot_x-ax and foot_x-ax+pix.width<=image.width and 0<=foot_y-ay and foot_y-ay+pix.height<=image.height:
                    image.alpha_composite(pix,(foot_x-ax,foot_y-ay))
                tiles+=1
    if missing:raise FileNotFoundError('real MPC tiles missing or invalid: '+', '.join(sorted(missing)[:25])+f' (total={len(missing)})')
    dest.parent.mkdir(parents=True,exist_ok=True)
    image.convert('RGB').save(dest,'PNG')
    out={'preview':str(dest),'map_sha256':meta['sha256'],'map_size':[w,h],'viewport':[cx,cy,cw,ch],'rendered_cells':tiles,'MPC_decoded':len(decoded),'source_asset_root':str(asset_root),'tile_dir':tile_dir,'status':'SOURCE_BACKED_MAP_RENDER_NOT_GODOT_QA'}
    write_json(dest.with_suffix('.json'),out)
    return out


def curated_jxqy_pilot(root:Path,skill:str='天意剑诀',map_name:str='中都-矿山',tile_dir:str='mpc/map/矿山')->list[str]:
    root=root.resolve(strict=True)
    player=jxqy_player(root)
    paths=['save/rpg0/player.ini',*player['role_evidence'][1:]]
    paths += [v['path'] for v in player['animations'].values() if v['exists']]
    try:
        graph=skill_graph(root,skill)
        paths.append(graph['source_ini'])
        paths += [v['relative_path'] for v in graph['visual_links'].values() if v.get('state')=='FOUND' and v.get('relative_path')]
    except FileNotFoundError:pass
    mp='map/'+map_name+'.map'
    if safe_file(root,mp).is_file():
        paths.append(mp)
        info=probe_map(safe_file(root,mp))
        # Source-backed MAP dictionary; do not guess tiles from filename.
        raw=safe_file(root,mp).read_bytes()
        used=set()
        for i in range(info['width']*info['height']):
            at=info['grid_offset']+i*10
            for layer in range(3):
                tile_id=raw[at+layer*2+1]
                if tile_id:
                    name=info['tile_dictionary'].get(tile_id)
                    if name:used.add((tile_dir+'/'+name).replace('\\','/'))
        paths.extend(t for t in sorted(used) if safe_file(root,t).is_file())
    return sorted(set(paths))


def run_cli():
    p=argparse.ArgumentParser(description='TMB Asset Forge Studio: local, non-destructive')
    sub=p.add_subparsers(dest='command',required=True)
    x=sub.add_parser('init');x.add_argument('--vault',required=True)
    x=sub.add_parser('stage');x.add_argument('--vault',required=True);x.add_argument('--source-id',required=True);x.add_argument('--from-root',required=True);x.add_argument('--path',action='append',required=True)
    x=sub.add_parser('stage-jxqy-pilot');x.add_argument('--vault',required=True);x.add_argument('--from-root',required=True);x.add_argument('--skill',default='天意剑诀');x.add_argument('--map',default='中都-矿山');x.add_argument('--tile-dir',default='mpc/map/矿山')
    x=sub.add_parser('map-info');x.add_argument('--file',required=True);x.add_argument('--out')
    x=sub.add_parser('map-preview');x.add_argument('--file',required=True);x.add_argument('--asset-root',required=True);x.add_argument('--tile-dir',required=True);x.add_argument('--out',required=True);x.add_argument('--crop',nargs=4,type=int,metavar=('X','Y','W','H'))
    x=sub.add_parser('map-edit');x.add_argument('--file',required=True);x.add_argument('--recipe',required=True);x.add_argument('--out',required=True)
    x=sub.add_parser('skill-info');x.add_argument('--root',required=True);x.add_argument('--name',required=True);x.add_argument('--out')
    x=sub.add_parser('skill-preview');x.add_argument('--root',required=True);x.add_argument('--name',required=True);x.add_argument('--out',required=True)
    x=sub.add_parser('skill-edit');x.add_argument('--root',required=True);x.add_argument('--name',required=True);x.add_argument('--adjustments',required=True,help='JSON file of presentation-only offsets, scale, speed, opacity, z-index');x.add_argument('--out',required=True)
    x=sub.add_parser('serve');x.add_argument('--vault',required=True);x.add_argument('--port',type=int,default=8791)
    args=p.parse_args()
    try:
        if args.command=='init':result=init_vault(Path(args.vault))
        elif args.command=='stage':result=stage_files(Path(args.vault),args.source_id,Path(args.from_root),args.path)
        elif args.command=='stage-jxqy-pilot':
            paths=curated_jxqy_pilot(Path(args.from_root),args.skill,args.map,args.tile_dir)
            result=stage_files(Path(args.vault),'JXQY2_OFFLINE',Path(args.from_root),paths)
            result['selected_evidenced_paths']=paths
        elif args.command=='map-info':result=probe_map(Path(args.file))
        elif args.command=='map-edit':result=map_patch(Path(args.file),Path(args.recipe),Path(args.out))
        elif args.command=='map-preview':result=map_preview(Path(args.file),Path(args.asset_root),args.tile_dir,Path(args.out),tuple(args.crop) if args.crop else None)
        elif args.command=='skill-info':result=skill_graph(Path(args.root),args.name)
        elif args.command=='skill-preview':result=skill_preview(Path(args.root),args.name,Path(args.out))
        elif args.command=='skill-edit':result=skill_visual_recipe(Path(args.root),args.name,json.loads(Path(args.adjustments).read_text(encoding='utf-8')),Path(args.out))
        elif args.command=='serve':
            from web_ui import serve
            serve(Path(args.vault),args.port)
            return
        else:raise ValueError('unsupported command')
        if getattr(args,'out',None) and args.command in ['map-info','skill-info']:
            write_json(args.out,result)
        json_print(result)
    except (OSError, ValueError, RuntimeError, KeyError, json.JSONDecodeError) as e:
        print('ERROR:',e,file=sys.stderr);sys.exit(2)


if __name__=='__main__':run_cli()