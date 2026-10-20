#!/usr/bin/env python3
"""Evidence-preserving JX1 character equipment resource table reader.

Based on KNpcResNode.cpp and CoreUseNameDef.h in SourceInit-JX1@b2e251a.
Input must be exact explicitly selected original tables; does not infer playable
identity or treat a `特殊npc` category as a game-created player by itself.
"""
from __future__ import annotations
import argparse
import csv
import hashlib
import json
from pathlib import Path
from jx1_pak_v2 import pak_index,jx1_path_hash

COLUMNS=('人物类型','部件说明文件名','武器行为关联表1','武器行为关联表2','动作贴图顺序表','资源文件路经')
MAX_TABLE=8*1024*1024
MAX_PARTS=16


def decode_table(path:Path)->tuple[list[list[str]],str,str]:
    raw=Path(path).read_bytes()
    if len(raw)>MAX_TABLE:raise ValueError('JX1 resource table too large')
    enc=None
    for candidate in ('utf-8-sig','gb18030'):
        try:
            text=raw.decode(candidate,errors='strict');enc=candidate;break
        except UnicodeDecodeError:continue
    if enc is None:raise ValueError('JX1 table encoding unsupported')
    if '\x00' in text:raise ValueError('Binary file is not a JX1 tabular table')
    rows=[[v.strip() for v in row] for row in csv.reader(text.splitlines(),delimiter='\t')]
    if not rows:raise ValueError('JX1 table empty')
    return rows,enc,hashlib.sha256(raw).hexdigest()


def keyed_row(path:Path,key:str)->dict:
    rows,enc,digest=decode_table(path)
    head=rows[0]
    matches=[(ix,row) for ix,row in enumerate(rows[1:],start=2) if row and row[0].strip()==key]
    if len(matches)!=1:raise ValueError('JX1 character resource row missing/ambiguous')
    _,values=matches[0]
    return {'table_path':str(path),'table_sha256':digest,'encoding':enc,
            'row_number':matches[0][0], 'id':key,
            'columns':{field: values[i] if i<len(values) else '' for i,field in enumerate(head)}}


def _canonical_within(root:Path,virtual:str)->Path:
    # Files from original C++ contain leading backslashes and GBK paths.
    # Only accept a virtual path mapped explicitly under the user's root.
    normalized=virtual.replace('\\','/').lstrip('/')
    parts=Path(normalized).parts
    if not parts or any(v in ('..','.') for v in parts) or ':' in virtual or '\x00' in virtual:
        raise ValueError('unsafe source table reference')
    anchor=root.resolve()
    dest=(anchor/Path(*parts)).resolve()
    if not dest.is_relative_to(anchor):raise ValueError('source table reference leaves root')
    return dest


def player_table_catalog(kind_file:Path,character:str,table_root:Path,asset_root:Path|None=None,max_rows:int=20)->dict:
    row=keyed_row(kind_file,character)
    fields=row['columns']
    for name in ('人物类型','部件说明文件名'):
        if name not in fields:raise ValueError('JX1 kind table missing canonical column: '+name)
    result={'source_family':'JX1_SOURCEINIT_TABLES','player_resource_record':row,
            'status':'NOT_GAMEPLAY_PLAYABLE_PROOF', 'is_composite_kind': fields['人物类型']=='特殊npc',
            'resource_base':fields.get('资源文件路经',''),
            'part_table':None,'groups':[],
            'unresolved':[],'stage':'TABLE_ONLY_NO_IMPORT'}
    if not result['is_composite_kind']:
        result['unresolved'].append('NPC_RES_NORMAL is not the source composite player path')
        return result
    part_filename=fields.get('部件说明文件名','')
    if not part_filename:
        result['unresolved'].append('Special character row has no part table name')
        return result
    part_path=_canonical_within(table_root,part_filename)
    if not part_path.is_file():
        result['unresolved'].append('Missing source part table: '+str(part_path))
        return result
    part_rows,enc,digest=decode_table(part_path)
    result['part_table']={'path':str(part_path),'sha256':digest,'encoding':enc,
                          'source_file':part_filename}
    # C++ KNpcResNode: i+2 rows, j+3 columns, for i,j=0..3.
    # KTabFile positions are one-based (header = row 1).
    groups=[]
    for i in range(4):
        cells=[]
        for j in range(4):
            val=part_rows[i+1][j+2] if len(part_rows)>i+1 and len(part_rows[i+1])>j+2 else ''
            if not val:continue
            sectname=fields.get(val,'')
            element={'group':i,'section':j,'label':val,'sect_table_file':sectname,
                     'variants':[],'evidence':{'part_row_1based':i+2,'part_col_1based':j+3}}
            if not sectname:
                result['unresolved'].append('Kind row missing subpart table for '+val)
            else:
                sect_path=_canonical_within(table_root,sectname)
                if not sect_path.is_file():
                    result['unresolved'].append('Missing variant table: '+str(sect_path))
                else:
                    rows,sect_enc,sect_digest=decode_table(sect_path)
                    element['table_sha256']=sect_digest
                    element['table_encoding']=sect_enc
                    # Variant order is 0-based row ordinal; columns 2+ are actions.
                    for num,variants in enumerate(rows[1:max_rows+1]):
                        actions={}
                        for k in range(1,len(variants)):
                            value=variants[k]
                            if not value:continue
                            action=(rows[0][k] if k<len(rows[0]) else f'column_{k+1}')
                            obj={'spr_leaf':value,'action_col_1based':k+1}
                            if asset_root is not None:
                                joined=fields.get('资源文件路经','').strip('\\/')+'\\'+value
                                source_path=_canonical_within(asset_root,joined)
                                obj['source_asset_exists']=source_path.is_file()
                                obj['source_asset_path']=str(source_path)
                                if source_path.is_file():
                                    obj['source_asset_sha256']=hashlib.sha256(source_path.read_bytes()).hexdigest()
                            actions[action]=obj
                        if actions:element['variants'].append({'equip_variant_row':num,
                                                             'source_variant_name':variants[0] if variants else '',
                                                             'actions':actions})
            cells.append(element)
        groups.extend(cells)
    result['groups']=groups
    result['active_part_count']=len(groups)
    result['linked_variant_count']=sum(len(g['variants']) for g in groups)
    result['stage']='SOURCE_TABLE_CATALOGED_NO_PLAYABLE_IDENTITY_ASSERTION'
    return result


def link_catalog_to_pack(catalog:dict,pak_paths:list[Path],limit:int=160)->dict:
    """Resolve EXACT referenced SectFile filename through JX1's own path hash.

    A hash hit proves an entry index exists, not that the payload or equipped
    appearance is right; caller must decode the selected SPR and compare art.
    """
    if len(pak_paths)>6:raise ValueError('pilot max six explicitly selected PACK archives')
    indexes=[]
    for path in pak_paths:
        index=pak_index(path)
        indexed={item['id']:item for item in index['entries']}
        indexes.append((path,indexed))
    report=[]
    base=catalog.get('resource_base','')
    for group in catalog.get('groups',[]):
        for variant in group.get('variants',[]):
            for action,asset in variant.get('actions',{}).items():
                if len(report)>=limit:break
                leaf=asset.get('spr_leaf','')
                if not leaf:continue
                full='\\'+base.strip('\\/')+'\\'+leaf.lstrip('\\/')
                # Preserve the source's visible path spelling for provenance.
                full=full.replace('/','\\')
                uid=jx1_path_hash(full)
                matches=[{'pak':str(path),'entry':index[uid]} for path,index in indexes if uid in index]
                status='HASH_ID_MATCH_PAK_INDEX_ONLY' if len(matches)==1 else (
                    'HASH_COLLISION_OR_MULTIPLE_PACKS_REVIEW' if matches else 'NOT_FOUND_IN_SELECTED_PAKS')
                report.append({'subpart':group['label'],'action':action,'equip_variant_row':variant['equip_variant_row'],
                               'source_virtual_path':full,'computed_id':uid,'matches':matches,'status':status})
    return {'kind':'JX1_SOURCE_TABLE_PATH_TO_PAK_INDEX', 'records':report,
            'selected_paks':[str(p) for p in pak_paths], 'scan_cap':limit,
            'decode_or_player_verification':False,
            'status':'CANDIDATE_LINKS_ONLY_NEEDS_SPR_RENDER_AND_PLAYER_IDENTITY'}


def main()->None:
    parser=argparse.ArgumentParser(description='Read JX1 character Kind/Part/Sect tables (no import)')
    parser.add_argument('--kind-file',type=Path,required=True)
    parser.add_argument('--character',required=True)
    parser.add_argument('--table-root',type=Path,required=True)
    parser.add_argument('--asset-root',type=Path)
    parser.add_argument('--out',type=Path,required=True)
    parser.add_argument('--pak',type=Path,action='append',default=[],help='optional selected JX1 PACK archives; at most six')
    args=parser.parse_args()
    data=player_table_catalog(args.kind_file,args.character,args.table_root,args.asset_root)
    if args.pak:data['pak_links']=link_catalog_to_pack(data,args.pak)
    args.out.parent.mkdir(parents=True,exist_ok=True)
    if args.out.exists():raise FileExistsError('report exists; no overwrite')
    args.out.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'result':str(args.out),'parts':data.get('active_part_count',0),'status':data['stage']},ensure_ascii=False))

if __name__=='__main__':main()