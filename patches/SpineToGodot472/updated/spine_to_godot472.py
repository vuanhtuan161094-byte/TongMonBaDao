#!/usr/bin/env python3
"""Spine 3.8 -> frame capture (Godot 4.5 Spine runtime) -> Godot 4.7.2.

No source skeleton parsing and no rendering masquerading as conversion.
"""
from __future__ import annotations
import argparse
import hashlib
import json
import os
import re
import shutil
import struct
import subprocess
import sys
import tempfile
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent
CAPTURE_SCRIPT = ROOT / 'native' / 'capture_spine.gd'
MAGIC = b'\x89PNG\r\n\x1a\n'
ALLOWED_ANIM = re.compile(r'^[A-Za-z_][A-Za-z0-9_-]{0,63}$')
MAX_FRAMES = 3000

class ConversionError(Exception):
    pass


def sha256(path):
    h = hashlib.sha256()
    with Path(path).open('rb') as f:
        for b in iter(lambda: f.read(1024*1024), b''):
            h.update(b)
    return h.hexdigest()


def converter_bundle_sha256():
    files = [Path(__file__).resolve(), CAPTURE_SCRIPT,
             ROOT / 'native' / 'inspect_spine.gd', ROOT / 'asset_bundle.py']
    h = hashlib.sha256()
    for path in sorted((p for p in files if p.is_file()), key=lambda p: p.name.casefold()):
        h.update(path.name.encode('utf-8'))
        h.update(bytes.fromhex(sha256(path)))
    return h.hexdigest()


def png_info(path):
    p = Path(path)
    with p.open('rb') as f:
        header = f.read(24)
    if len(header) != 24 or not header.startswith(MAGIC) or header[12:16] != b'IHDR':
        raise ConversionError('Invalid PNG: ' + str(path))
    width, height = struct.unpack('>II', header[16:24])
    if not (0 < width <= 16384 and 0 < height <= 16384):
        raise ConversionError('Invalid PNG dimensions: ' + str(path))
    return width, height


def atlas_pages(atlas):
    # Spine atlas pages are blocks separated by blank lines. Region blocks contain
    # "rotate", "xy", etc. Page headers start with size/filter/format/repeat/pma.
    data = Path(atlas).read_text('utf-8-sig')
    pages = []
    lines = data.replace('\r\n','\n').split('\n')
    for i, line in enumerate(lines):
        label = line.strip()
        if not label or label.startswith('#') or ':' in label or not label.lower().endswith('.png'):
            continue
        if i + 1 >= len(lines):
            continue
        lookahead = '\n'.join(s.strip() for s in lines[i+1:i+5])
        if re.search(r'(?m)^(size|format|filter|repeat|pma):', lookahead):
            if '/' in label or '\\' in label or label.startswith('.'):
                raise ConversionError('Atlas page path must be a simple filename: '+label)
            if label not in pages: pages.append(label)
    if not pages:
        raise ConversionError('Could not identify texture page(s) in .atlas. No import attempted.')
    return pages


SOURCE_SKEL = re.compile(r'^(.+)\.skel_TextAsset_-?\d+\.bin$', re.IGNORECASE)


def skeleton_candidates(folder):
    """Only recognize native .skel or Unity-exported Spine TextAsset names."""
    p = Path(folder)
    return sorted((x for x in p.iterdir() if x.is_file() and
                   (x.suffix.lower() == '.skel' or SOURCE_SKEL.fullmatch(x.name))),
                  key=lambda x: x.name.lower())


def skeleton_base(skel):
    match = SOURCE_SKEL.fullmatch(skel.name)
    return match.group(1) if match else skel.stem


def verify_skeleton(skel):
    # A binary Spine header carries a hash string followed by a version string.
    # The runtime remains the final compatibility check.
    if skel.stat().st_size < 8:
        raise ConversionError('Skeleton quá ngắn hoặc rỗng: ' + str(skel))
    if not SOURCE_SKEL.fullmatch(skel.name):
        return
    with skel.open('rb') as stream:
        head = stream.read(256)
    if head[:1] in (b'{', b'['):
        raise ConversionError('File này là JSON, không phải Spine binary .skel: ' + str(skel))
    if not re.search(rb'3\.8\.\d+', head):
        raise ConversionError('Không xác minh được header Spine 3.8 trong file: ' + str(skel))


def normalize_input(args):
    path = Path(args.input).expanduser().resolve()
    if path.is_dir():
        skels = skeleton_candidates(path)
        if not skels:
            raise ConversionError('Không tìm thấy .skel hoặc *.skel_TextAsset_*.bin trong thư mục: '+str(path))
        if len(skels) > 1:
            raise ConversionError('Có nhiều skeleton; hãy chọn đúng một file trong danh sách: '\
                                  + ', '.join(x.name for x in skels))
        skel = skels[0]
    elif path.suffix.lower() == '.skel' or SOURCE_SKEL.fullmatch(path.name):
        skel = path
    else:
        raise ConversionError('Hãy chọn thư mục Spine, .skel hoặc *.skel_TextAsset_*.bin: '+str(path))
    if not skel.is_file():
        raise ConversionError('Không tìm thấy skeleton: ' + str(skel))
    verify_skeleton(skel)
    base = skeleton_base(skel)
    if args.atlas:
        atlas = Path(args.atlas).expanduser().resolve()
    else:
        candidates = sorted((p for p in skel.parent.iterdir() if p.is_file() and
                             (p.name.lower() == (base+'.atlas').lower() or
                              re.fullmatch(re.escape(base)+r'\.atlas_TextAsset_-?\d+\.bin', p.name, re.IGNORECASE))),
                            key=lambda p: p.name.lower())
        if not candidates:
            candidates = sorted((p for p in skel.parent.iterdir() if p.is_file() and
                                 (p.suffix.lower() == '.atlas' or re.search(r'\.atlas_TextAsset_-?\d+\.bin$',p.name,re.IGNORECASE))),
                                key=lambda p: p.name.lower())
        if len(candidates) > 1:
            raise ConversionError('Có nhiều atlas; hãy chọn atlas phù hợp: '+', '.join(p.name for p in candidates))
        atlas = candidates[0] if candidates else skel.parent/(base+'.atlas')
    if not atlas.is_file():
        raise ConversionError('Thiếu atlas cho '+skel.name+'; cần '+base+'.atlas hoặc '+base+'.atlas_TextAsset_*.bin trong '+str(skel.parent))
    pages = atlas_pages(atlas)
    texdir = Path(args.textures).expanduser().resolve() if args.textures else atlas.parent
    texture_files=[]
    for page in pages:
        t = texdir/page
        if not t.is_file():
            # Unity exports texture objects under Texture2D IDs. Match only a
            # unique page stem and verify its pixel dimensions against atlas.
            stem = Path(page).stem
            variants = sorted(p for p in texdir.glob(stem+'_Texture2D_*.png') if p.is_file())
            if len(variants) == 1:
                t = variants[0]
            elif len(variants) > 1:
                raise ConversionError('Nhiều PNG có thể là trang '+page+'; cần chọn/đối chiếu thủ công: '+', '.join(p.name for p in variants))
            else:
                raise ConversionError('Thiếu texture PNG cho trang atlas '+page+' trong '+str(texdir)+'. Cần '+page+' hoặc '+stem+'_Texture2D_*.png')
        size = png_info(t)
        atlas_text = atlas.read_text('utf-8-sig')
        block = re.search(r'(?m)^'+re.escape(page)+r'\s*\n\s*size:\s*(\d+)\s*,\s*(\d+)', atlas_text)
        if block and size != (int(block.group(1)),int(block.group(2))):
            raise ConversionError(f'Kích thước texture {t.name} là {size}, atlas {page} yêu cầu {(int(block.group(1)),int(block.group(2)))}')
        texture_files.append(t)
    return skel, atlas, texture_files


def parse_clips(text):
    clips=[]
    for fragment in text.split(','):
        bits = fragment.strip().split(':')
        if len(bits) != 2 or not ALLOWED_ANIM.fullmatch(bits[0]):
            raise ConversionError('Clips format: stand:1.0,walk:0.8 (seconds; no paths)')
        try:
            sec = float(bits[1])
        except ValueError:
            raise ConversionError('Invalid duration: ' + bits[1])
        if not 0 < sec <= 60 or not sec == sec:
            raise ConversionError('Clip duration must be 0 < seconds <= 60')
        if bits[0] in (v[0] for v in clips):
            raise ConversionError('Duplicate animation: '+bits[0])
        clips.append((bits[0], sec))
    if not clips:
        raise ConversionError('No animation clips specified')
    return clips


def ident(s):
    return re.sub(r'[^a-zA-Z0-9_-]', '_', s)[:64] or 'spine_actor'


def safe_copy(src, dst):
    dst = Path(dst)
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, dst)


def copy_spine_project(source, destination):
    if not (source/'project.godot').is_file():
        raise ConversionError('Godot 4.5 Spine project must contain project.godot')
    if source.resolve() == destination.resolve():
        raise ConversionError('Cannot write to Spine trial project')
    def ignore(path, names):
        return {n for n in names if n in ('.godot', '.git', '.svn') or n.endswith('.log') or n.endswith('.tmp')}
    shutil.copytree(source, destination, ignore=ignore)


def native_env(scratch):
    env = os.environ.copy()
    for key, folder in [('APPDATA','AppData'),('LOCALAPPDATA','LocalAppData'),('TEMP','Temp'),('TMP','Temp')]:
        target = scratch / folder
        target.mkdir(parents=True, exist_ok=True)
        env[key] = str(target)
    return env


def prepare_native_staging(project, staging, skel, atlas, textures, metadata_output):
    copy_spine_project(project, staging)
    inputdir = staging / '__s2g_source'
    inputdir.mkdir()
    safe_copy(skel, inputdir / 'actor.skel')
    safe_copy(atlas, inputdir / 'actor.atlas')
    for page, tex in zip(atlas_pages(atlas), textures):
        safe_copy(tex, inputdir / page)
    safe_copy(ROOT / 'native' / 'capture_spine.gd', staging / '__s2g_capture.gd')
    safe_copy(ROOT / 'native' / 'inspect_spine.gd', staging / '__s2g_inspect_spine.gd')
    job = {'skel':'res://__s2g_source/actor.skel',
           'atlas':'res://__s2g_source/actor.atlas',
           'metadata_output':str(metadata_output)}
    (staging / '__s2g_job.json').write_text(json.dumps(job, ensure_ascii=False, indent=2),'utf-8')
    return job


def inspect_runtime(eng, project, skel, atlas, textures, scratch, staging=None, timeout=180):
    if staging is None:
        staging = scratch / 'native_project'
        metadata_output = scratch / 'clip_metadata.json'
        prepare_native_staging(project, staging, skel, atlas, textures, metadata_output)
    else:
        metadata_output = scratch / 'clip_metadata.json'
    import_cmd=[str(eng),'--headless','--path',str(staging),'--editor','--import','--quit']
    import_logs=[]
    for attempt in range(2):
        imported=subprocess.run(import_cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,
                                encoding='utf-8',errors='replace',timeout=timeout,env=native_env(scratch))
        import_logs.append(f'IMPORT_PASS_{attempt+1}\n'+(imported.stdout or ''))
        if imported.returncode != 0:
            break
    (scratch/'native_project_import.log').write_text('\n'.join(import_logs),encoding='utf-8')
    if imported.returncode != 0 or 'ERROR:' in (imported.stdout or ''):
        raise ConversionError('CLIP_METADATA_BLOCKED: native import failed on second pass: '+(imported.stdout or '')[-2500:])
    cmd = [str(eng),'--headless','--path',str(staging),'--script','res://__s2g_inspect_spine.gd']
    proc = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                          encoding='utf-8', errors='replace', timeout=timeout, env=native_env(scratch))
    log = proc.stdout or ''
    if proc.returncode != 0 or 'ERROR:' in log or 'S2G_METADATA_PASS' not in log or not metadata_output.is_file():
        raise ConversionError('CLIP_METADATA_BLOCKED: runtime inspection failed: ' + log[-2500:])
    data = json.loads(metadata_output.read_text(encoding='utf-8'))
    if data.get('status') != 'RUNTIME_METADATA_VERIFIED' or not data.get('animations'):
        raise ConversionError('CLIP_METADATA_BLOCKED: invalid runtime metadata')
    return data, log


def native_clips(names_text, metadata):
    by_name = {item['name']: float(item['duration_seconds']) for item in metadata['animations']}
    names = [s.strip() for s in names_text.split(',')] if names_text else list(by_name)
    if not names or len(names) != len(set(names)):
        raise ConversionError('Select at least one distinct runtime-verified clip')
    result = []
    for name in names:
        if not ALLOWED_ANIM.fullmatch(name) or name not in by_name:
            raise ConversionError('Clip not verified by native runtime: ' + name)
        duration = by_name[name]
        if not 0 <= duration <= 60:
            raise ConversionError('Invalid runtime clip duration: ' + name)
        result.append((name, max(duration, 0.001)))
    return result


def godot_resource_escape(s):
    return json.dumps(str(s), ensure_ascii=False)


def write_spriteframes(out_dir, id_name, clips, fps, foot_x, foot_y):
    texture_refs=[]
    anim_strings=[]
    ext_id=0
    for name, duration in clips:
        nframes=max(1,round(duration * fps))
        if nframes < 1 or nframes>MAX_FRAMES: raise ConversionError('Bad frame count')
        refs=[]
        for i in range(nframes):
            path=out_dir/'frames'/name/f'{i:04d}.png'
            png_info(path)
            ext_id += 1
            rid=f't{ext_id}'
            resource_path=f'res://frames/{name}/{i:04d}.png'
            texture_refs.append(f'[ext_resource type="Texture2D" path={godot_resource_escape(resource_path)} id="{rid}"]')
            refs.append('{"duration": 1.0, "texture": ExtResource("'+rid+'")}')
        frames=',\n'.join(refs)
        anim_strings.append('{\n"frames": [\n'+frames+'\n],\n"loop": true,\n"name": &'+godot_resource_escape(name)+',\n"speed": '+str(fps)+'.0\n}')
    data = (f'[gd_resource type="SpriteFrames" load_steps={ext_id+1} format=3]\n\n'
        + '\n'.join(texture_refs) + '\n\n[resource]\n'
        + 'animations = [\n' + ',\n'.join(anim_strings) + '\n]\n')
    (out_dir/'sprite_frames.tres').write_text(data,'utf-8')
    initial=clips[0][0]
    scene = ('[gd_scene load_steps=2 format=3]\n\n'
             '[ext_resource type="SpriteFrames" path="res://sprite_frames.tres" id="1"]\n\n'
             f'[node name="{id_name}" type="AnimatedSprite2D"]\n'
             'sprite_frames = ExtResource("1")\n'
             f'animation = &{godot_resource_escape(initial)}\n'
             f'autoplay = {godot_resource_escape(initial)}\n'
             'centered = false\n'
             f'offset = Vector2({-foot_x}, {-foot_y})\n')
    (out_dir/'actor.tscn').write_text(scene,'utf-8')


def validate_captured(out, clips, fps, size):
    for name,duration in clips:
        n=max(1,round(duration*fps))
        folder=out/'frames'/name
        if not folder.is_dir(): raise ConversionError('Missing output animation folder: '+str(folder))
        found=list(folder.glob('*.png'))
        if len(found)!=n: raise ConversionError(f'{name}: expected {n} PNGs, found {len(found)}')
        sizes=set()
        for i in range(n):
            p=folder/f'{i:04d}.png'
            if not p.is_file(): raise ConversionError('Missing frame: '+str(p))
            sizes.add(png_info(p))
        if sizes != {tuple(size)}:
            raise ConversionError(f'{name}: inconsistent canvas sizes {sizes} expected {size}')


def run_asset_export(args):
    """Default export: one clean, relocatable actor directory, QA kept in the tool."""
    from asset_bundle import ATLAS_LIMIT, loop_default, make_zip, pack_frames

    skel, atlas, textures = normalize_input(args)
    actor_id = ident(args.actor_id or skeleton_base(skel))
    if not re.fullmatch(r'[A-Za-z0-9_-]{1,64}', actor_id):
        raise ConversionError('ID nhân vật không hợp lệ')
    if not args.output:
        raise ConversionError('Cần đường dẫn thư mục asset ổn định --output')
    output = Path(args.output).expanduser().resolve()
    if output.name != actor_id:
        raise ConversionError('Tên thư mục asset phải là ID nhân vật '+actor_id)
    if not 1 <= args.fps <= 60:
        raise ConversionError('FPS phải trong khoảng 1–60')
    if not (128 <= args.width <= 2048 and 128 <= args.height <= 2048):
        raise ConversionError('Canvas phải trong khoảng 128–2048 px')
    if not (0 <= args.foot_x < args.width and 0 <= args.foot_y < args.height):
        raise ConversionError('Foot anchor nằm ngoài canvas')
    eng = Path(args.godot45).expanduser().resolve() if args.godot45 else None
    project = Path(args.spine_project).expanduser().resolve() if args.spine_project else None
    eng472 = Path(args.godot472).expanduser().resolve() if args.godot472 else None
    if not eng or not eng.is_file() or not project or not (project/'project.godot').is_file():
        raise ConversionError('Thiếu Godot 4.5 có Spine 3.8 hoặc project runtime hiện có')
    if not eng472 or not eng472.is_file():
        raise ConversionError('Cần Godot 4.7.2 để kiểm tra asset trước khi xuất')
    if skel.parent in output.parents or project in output.parents:
        raise ConversionError('Không được xuất vào thư mục asset nguồn hoặc project runtime')
    digests = [{'name':p.name,'sha256':sha256(p),'bytes':p.stat().st_size}
               for p in [skel,atlas,*textures]]
    skins = args.skins or []
    config = {'tool_schema':7,'id':actor_id,'source':digests,'fps':args.fps,
              'canvas':[args.width,args.height], 'foot':[args.foot_x,args.foot_y],
              'clips_requested':args.clips or 'ALL_RUNTIME_VERIFIED',
              'skin_selection':skins or 'AUTO_DEFAULT',
              'atlas_limit':ATLAS_LIMIT}
    fingerprint = hashlib.sha256(json.dumps(config,sort_keys=True,ensure_ascii=False).encode('utf-8')).hexdigest()
    replace_existing = output.exists()
    if replace_existing:
        manifest_path = output/'asset.json'
        if manifest_path.is_file():
            old = json.loads(manifest_path.read_text(encoding='utf-8'))
            expected = {'actor.tscn','animations.tres','asset.json'}
            expected.update(page['file'] for page in old.get('atlas_pages',[]))
            found = {p.name for p in output.iterdir()}
            qa_dir = ROOT/'QA_RESULTS'/('asset_'+actor_id)
            verified_path = qa_dir/'verification.json'
            try:
                prior_qa = json.loads(verified_path.read_text(encoding='utf-8'))
            except (OSError, ValueError):
                prior_qa = {}
            checksums = old.get('file_sha256',{})
            files_intact = bool(checksums) and all(
                (output/name).is_file() and sha256(output/name)==digest
                for name,digest in checksums.items())
            if (old.get('fingerprint') == fingerprint and found == expected
                    and files_intact and prior_qa.get('fingerprint') == fingerprint
                    and prior_qa.get('status') == 'PASS'):
                if args.zip: make_zip(output,actor_id)
                print('UNCHANGED_SKIPPED:',output)
                return
        if not output.is_dir() or output.is_symlink():
            raise ConversionError('Đích cùng ID không phải thư mục asset thường: '+str(output))
        old_files = {p.name for p in output.iterdir()}
        if not {'actor.tscn','asset.json','animations.tres'}.issubset(old_files):
            raise ConversionError('Đích cùng ID chứa dữ liệu khác; không ghi đè: '+str(output))

    qa_dir = ROOT/'QA_RESULTS'/('asset_'+actor_id)
    qa_dir.mkdir(parents=True,exist_ok=True)
    qa_log = qa_dir/'latest_status.txt'
    qa_log.write_text('START '+str(skel)+'\n',encoding='utf-8')
    try:
        with tempfile.TemporaryDirectory(prefix='work_',dir=qa_dir,ignore_cleanup_errors=True) as temporary:
            scratch=Path(temporary)
            staging=scratch/'native_project'
            job=prepare_native_staging(project,staging,skel,atlas,textures,scratch/'clip_metadata.json')
            metadata,metadata_log=inspect_runtime(eng,project,skel,atlas,textures,scratch,staging,timeout=args.timeout)
            safe_copy(scratch/'native_project_import.log',qa_dir/'native_import.log')
            (qa_dir/'native_metadata.log').write_text(metadata_log,encoding='utf-8')
            clips=native_clips(args.clips,metadata)
            total=sum(max(1,round(d*args.fps)) for _,d in clips)
            if total>MAX_FRAMES:
                raise ConversionError(f'{total} frame vượt giới hạn {MAX_FRAMES}; hãy chọn clip hoặc giảm FPS')
            job.update({'clips':[{'name':n,'duration':d,'frames':max(1,round(d*args.fps))} for n,d in clips],
                        'fps':args.fps,'canvas_width':args.width,'canvas_height':args.height,
                        'foot_x':args.foot_x,'foot_y':args.foot_y,
                        'skins':skins,
                        'output':str(scratch/'frames'), 'template_scene':args.template_scene or ''})
            (staging/'__s2g_job.json').write_text(json.dumps(job,ensure_ascii=False,indent=2),encoding='utf-8')
            command=[str(eng),'--path',str(staging),'--rendering-method','gl_compatibility',
                     '--fixed-fps',str(args.fps*4),'--script','res://__s2g_capture.gd']
            proc=subprocess.run(command,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,
                                encoding='utf-8',errors='replace',timeout=args.timeout,env=native_env(scratch))
            (qa_dir/'native_capture.log').write_text(proc.stdout or '',encoding='utf-8')
            if proc.returncode!=0 or 'S2G_CAPTURE_PASS' not in (proc.stdout or ''):
                raise ConversionError('Runtime Spine không chụp đủ clip; xem '+str(qa_dir/'native_capture.log'))
            validate_captured(scratch,clips,args.fps,(args.width,args.height))
            captured = {m.group(1) for m in re.finditer(r'S2G_CLIP_CAPTURED\s+(\S+)',proc.stdout or '')}
            missing = [name for name,_ in clips if name not in captured]
            if missing:
                raise ConversionError('Clip không được runtime xác nhận chụp: '+', '.join(missing))
            asset = scratch/'bundle'
            metrics=pack_frames(scratch/'frames',clips,args.fps,(args.width,args.height),
                                (args.foot_x,args.foot_y),actor_id,asset)
            qa_samples=[]
            for name,_duration in clips:
                for label,(source_index,stored_index) in metrics['sample_map'][name].items():
                    safe_copy(scratch/'frames'/name/(f'{source_index:04d}.png'),
                              qa_dir/(name+'_'+label+'_native45.png'))
                    qa_samples.append({'name':name,'label':label,
                                       'source_index':source_index,'stored_index':stored_index})
            skin_lines = [line.partition('S2G_SKIN_SELECTED ')[2].strip()
                          for line in (proc.stdout or '').splitlines() if 'S2G_SKIN_SELECTED ' in line]
            try:
                selected_skins = json.loads(skin_lines[-1]) if skin_lines else (skins or [])
            except (ValueError, IndexError):
                selected_skins = skins or []
            manifest={'id':actor_id,'fingerprint':fingerprint,
                      'converter_version':7,'converter_sha256':converter_bundle_sha256(),
                      'source':digests,
                      'skin_selection_requested':skins,
                      'skin_selection_runtime':selected_skins,
                      'fps':args.fps,'canvas':[args.width,args.height],
                      'foot_anchor':[args.foot_x,args.foot_y], 'crop':metrics['crop'],
                      'offset':metrics['offset'],'atlas_pages':metrics['atlas_pages'],
                      'stored_frames':metrics['stored_frames'],'unique_textures':metrics['unique_textures'],
                      'loop_policy':'name_based_default; source Spine clip has no intrinsic loop flag',
                      'file_sha256':{item.name:sha256(item) for item in asset.iterdir() if item.is_file()},
                      'clips':[{'name':n,'duration_seconds':d,'frames':max(1,round(d*args.fps)),
                                'stored_frames':metrics['stored_by_clip'][n],
                                'loop':loop_default(n)} for n,d in clips]}
            (asset/'asset.json').write_text(json.dumps(manifest,ensure_ascii=False,separators=(',',':')),
                                               encoding='utf-8')
            (qa_dir/'metrics.json').write_text(json.dumps(metrics,ensure_ascii=False,indent=2),encoding='utf-8')

            qa_project=scratch/'godot_qa'
            test_asset=qa_project/'assets'/'actors'/actor_id
            test_asset.parent.mkdir(parents=True)
            shutil.copytree(asset,test_asset)
            (qa_project/'project.godot').write_text('config_version=5\n\n[rendering]\nrenderer/rendering_method="gl_compatibility"\nrenderer/rendering_method.mobile="gl_compatibility"\n',encoding='utf-8')
            for name in ('verify_actor_bundle.gd','capture_actor_bundle.gd'):
                safe_copy(ROOT/'native'/name,qa_project/name)
            visual_clips=[n for n in ('stand','walk','attack1') if n in {x for x,_ in clips}]
            if not visual_clips: visual_clips=[clips[0][0]]
            qa_job={'id':actor_id,'clips':manifest['clips'],'frames':metrics['stored_frames'],'fps':args.fps,
                    'canvas':[args.width,args.height],'foot':[args.foot_x,args.foot_y],
                    'visual_clips':visual_clips,'qa_samples':qa_samples,'capture_dir':str(qa_dir)}
            (qa_project/'__bundle_job.json').write_text(json.dumps(qa_job,ensure_ascii=False),encoding='utf-8')
            env=native_env(scratch)
            import_cmd=[str(eng472),'--headless','--path',str(qa_project),'--editor','--import','--quit']
            import_logs=[]
            for attempt in range(2):
                imported=subprocess.run(import_cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,
                                        encoding='utf-8',errors='replace',timeout=args.timeout,env=env)
                import_logs.append(imported.stdout or '')
                if imported.returncode!=0: break
            (qa_dir/'godot472_import.log').write_text('\n--- PASS ---\n'.join(import_logs),encoding='utf-8')
            if imported.returncode!=0 or 'ERROR:' in (imported.stdout or ''):
                raise ConversionError('Godot 4.7.2 import lỗi; xem '+str(qa_dir/'godot472_import.log'))
            verified=subprocess.run([str(eng472),'--headless','--path',str(qa_project),
                                     '--script','res://verify_actor_bundle.gd'],
                                    stdout=subprocess.PIPE,stderr=subprocess.STDOUT,encoding='utf-8',
                                    errors='replace',timeout=args.timeout,env=env)
            (qa_dir/'godot472_resource.log').write_text(verified.stdout or '',encoding='utf-8')
            if verified.returncode!=0 or 'BUNDLE_VERIFY_PASS' not in (verified.stdout or ''):
                raise ConversionError('Godot 4.7.2 không đọc đủ animation; xem '+str(qa_dir/'godot472_resource.log'))
            visual=subprocess.run([str(eng472),'--path',str(qa_project),'--rendering-method','gl_compatibility',
                                   '--script','res://capture_actor_bundle.gd'],
                                  stdout=subprocess.PIPE,stderr=subprocess.STDOUT,encoding='utf-8',
                                  errors='replace',timeout=args.timeout,env=env)
            (qa_dir/'godot472_visual.log').write_text(visual.stdout or '',encoding='utf-8')
            if visual.returncode!=0 or 'BUNDLE_VISUAL_PASS' not in (visual.stdout or ''):
                raise ConversionError('Godot 4.7.2 chưa chụp hình được; xem '+str(qa_dir/'godot472_visual.log'))
            from PIL import Image, ImageChops
            comparisons={}
            for sample in qa_samples:
                name,label=sample['name'],sample['label']
                native=qa_dir/(name+'_'+label+'_native45.png')
                rendered=qa_dir/(name+'_'+label+'_godot472.png')
                if not native.is_file() or not rendered.is_file():
                    raise ConversionError('Thiếu ảnh đối chiếu '+name+'/'+label)
                with Image.open(native) as source, Image.open(rendered) as target:
                    a=source.convert('RGBA'); b=target.convert('RGBA')
                    alpha_a=a.getchannel('A').getbbox()
                    alpha_b=b.getchannel('A').getbbox()
                    same_alpha=ImageChops.difference(a.getchannel('A'),b.getchannel('A')).getbbox() is None
                    comparisons[name+'/'+label]={'native_alpha_bbox':alpha_a,'godot_alpha_bbox':alpha_b,
                                       'same_alpha':same_alpha,
                                       'same_rgba':ImageChops.difference(a,b).getbbox() is None}
            (qa_dir/'frame_samples_compare.json').write_text(json.dumps(comparisons,ensure_ascii=False,indent=2),encoding='utf-8')
            shifted=[name for name,record in comparisons.items()
                     if record['native_alpha_bbox'] != record['godot_alpha_bbox'] or not record['same_rgba']]
            if shifted:
                raise ConversionError('Khung hình khác Spine native: '+', '.join(shifted)+'; xem frame_samples_compare.json')
            output.parent.mkdir(parents=True,exist_ok=True)
            # Copy out of Python's private TemporaryDirectory. Renaming it
            # would retain its owner-only Windows ACL and hide the asset from
            # the normal Explorer/Godot user.
            if not replace_existing:
                shutil.copytree(asset, output)
            else:
                incoming=output.parent/('.incoming_'+actor_id)
                backup=output.parent/('.previous_'+actor_id)
                if incoming.exists() or backup.exists():
                    raise ConversionError('Còn bản cập nhật dở; giữ nguyên asset cũ và kiểm tra '+str(output.parent))
                shutil.copytree(asset,incoming)
                for item in asset.iterdir():
                    if sha256(item) != sha256(incoming/item.name):
                        raise ConversionError('Bản chép mới sai hash; giữ nguyên asset cũ')
                output.rename(backup)
                try:
                    incoming.rename(output)
                except Exception:
                    backup.rename(output)
                    raise
                # Only remove the verified same-ID backup after the new QA-pass
                # bundle has been copied and checked on the same volume.
                if backup.resolve().parent != output.parent.resolve() or backup.name != '.previous_'+actor_id:
                    raise ConversionError('Không xác minh được thư mục backup; giữ lại để khôi phục')
                shutil.rmtree(backup)
            (qa_dir/'verification.json').write_text(json.dumps(
                {'status':'PASS','fingerprint':fingerprint,'godot_472':'IMPORT_PLAYBACK_PASS',
                 'sample_frames':len(comparisons),'sample_rgba_exact':all(v['same_rgba'] for v in comparisons.values()),
                 'output':str(output)},ensure_ascii=False,indent=2),encoding='utf-8')
        temporary_path = Path(temporary)
        if temporary_path.exists() and temporary_path.parent.resolve() == qa_dir.resolve() and temporary_path.name.startswith('work_'):
            for _ in range(12):
                shutil.rmtree(temporary_path,ignore_errors=True)
                if not temporary_path.exists(): break
                time.sleep(1.0)
            if temporary_path.exists():
                (qa_dir/'cleanup_warning.txt').write_text(
                    'Thư mục QA tạm còn bị khóa: '+str(temporary_path),encoding='utf-8')
                print('QA_TEMP_REVIEW:',temporary_path)
        qa_log.write_text(f'PASS {actor_id}: {len(clips)} clips, {total} frames, {len(metrics["atlas_pages"])} atlas pages\n',encoding='utf-8')
        if args.zip: make_zip(output,actor_id)
        print('ASSET_PASS:',output)
        print('CLIPS:',len(clips),'FRAMES:',total,'ATLAS_PAGES:',len(metrics['atlas_pages']))
        print('QA:',qa_dir)
    except Exception as exc:
        qa_log.write_text('BLOCKED '+str(exc)+'\n',encoding='utf-8')
        raise


def run_conversion(args):
    skel,atlas,textures=normalize_input(args)
    clips=parse_clips(args.clips) if args.pack_existing_frames else []
    fps=args.fps
    if not 1<=fps<=60:
        raise ConversionError('FPS must be 1-60')
    total=sum(max(1,round(t*fps)) for _,t in clips)
    if total>MAX_FRAMES: raise ConversionError('Too many frames (>3000)')
    if args.width<128 or args.height<128 or args.width>2048 or args.height>2048:
        raise ConversionError('Canvas must be 128..2048 px')
    if not (0<=args.foot_x<args.width and 0<=args.foot_y<args.height):
        raise ConversionError('Foot anchor must be inside canvas')
    project=Path(args.spine_project).expanduser().resolve() if args.spine_project else None
    eng=Path(args.godot45).expanduser().resolve() if args.godot45 else None
    eng472=Path(args.godot472).expanduser().resolve() if args.godot472 else None
    if not args.pack_existing_frames:
        if not eng or not eng.is_file():
            raise ConversionError('Godot 4.5 Spine runtime executable required (--godot45)')
        if not project or not project.is_dir() or not (project/'project.godot').is_file():
            raise ConversionError('Working Godot 4.5 Spine project required (--spine-project)')
    if args.inspect_only:
        if not eng or not eng.is_file() or not project or not (project/'project.godot').is_file():
            raise ConversionError('CLIP_METADATA_BLOCKED: Godot 4.5 runtime and project required')
        with tempfile.TemporaryDirectory(prefix='s2g_inspect_',ignore_cleanup_errors=True) as temp:
            data, log = inspect_runtime(eng,project,skel,atlas,textures,Path(temp),timeout=args.timeout)
            print(json.dumps(data,ensure_ascii=False,indent=2))
        return
    if not args.output:
        raise ConversionError('New output path required')
    output=Path(args.output).expanduser().resolve()
    # Never overwrite established outputs or sources.
    if output.exists():
        raise ConversionError('Output already exists; use a new output directory: '+str(output))
    if project and (output==project or project in output.parents):
        raise ConversionError('Output must be outside source Spine trial project')
    if output==skel.parent or skel.parent in output.parents:
        raise ConversionError('Output must be outside source asset directory')
    if args.pack_existing_frames:
        srcframes=Path(args.pack_existing_frames).expanduser().resolve()
        if not srcframes.is_dir(): raise ConversionError('Existing frames directory not found')
    sources=[skel,atlas,*textures]
    digests=[{'path':str(p),'sha256':sha256(p),'bytes':p.stat().st_size} for p in sources]
    if args.validate_only:
        print(json.dumps({'status':'INPUT_VALID','files':digests,'atlas_pages':len(textures),'clips':clips,'frames':total},ensure_ascii=False,indent=2))
        return
    output.mkdir(parents=True,exist_ok=False)
    try:
        if args.pack_existing_frames:
            # Frame packaging can be independently tested without the native Spine runtime.
            for name,duration in clips:
                n=max(1,round(duration*fps))
                for i in range(n):
                    source=srcframes/name/f'{i:04d}.png'
                    if not source.is_file():raise ConversionError('Missing source frame: '+str(source))
                    safe_copy(source,output/'frames'/name/f'{i:04d}.png')
            capture_status='EXISTING_FRAMES_PACKAGED; NATIVE_SPINE_NOT_RUN'
        else:
            with tempfile.TemporaryDirectory(prefix='spine472_tmp_',ignore_cleanup_errors=True) as td:
                scratch=Path(td)
                staging=scratch/'native_project'
                job=prepare_native_staging(project,staging,skel,atlas,textures,scratch/'clip_metadata.json')
                metadata, metadata_log = inspect_runtime(eng,project,skel,atlas,textures,scratch,staging,timeout=args.timeout)
                safe_copy(scratch/'native_project_import.log',output/'native_project_import.log')
                (output/'native_metadata.log').write_text(metadata_log,'utf-8')
                (output/'clip_metadata.json').write_text(json.dumps(metadata,ensure_ascii=False,indent=2),'utf-8')
                clips=native_clips(args.clips,metadata)
                total=sum(max(1,round(d*fps)) for _,d in clips)
                if total>MAX_FRAMES: raise ConversionError('Too many frames (>3000)')
                job.update({'clips':[{'name':n,'duration':d,'frames':max(1,round(d*fps))} for n,d in clips],
                            'fps':fps,'canvas_width':args.width,'canvas_height':args.height,
                            'foot_x':args.foot_x,'foot_y':args.foot_y,
                            'output':str(output/'frames'),
                            'template_scene':args.template_scene or ''})
                (staging/'__s2g_job.json').write_text(json.dumps(job,ensure_ascii=False,indent=2),'utf-8')
                command=[str(eng),'--path',str(staging),'--rendering-method','gl_compatibility',
                         '--fixed-fps',str(fps*4),'--script','res://__s2g_capture.gd']
                cmd_display=' '.join('"'+c+'"' if ' ' in c else c for c in command)
                (output/'native_command.txt').write_text(cmd_display,'utf-8')
                try:
                    p=subprocess.run(command,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,
                                     encoding='utf-8',errors='replace',timeout=args.timeout,env=native_env(scratch))
                except subprocess.TimeoutExpired as e:
                    raise ConversionError('Godot 4.5 native capture TIMEOUT; no fake PASS') from e
                (output/'native_capture.log').write_text(p.stdout,'utf-8')
                if p.returncode != 0 or 'S2G_CAPTURE_PASS' not in p.stdout:
                    raise ConversionError('Godot 4.5 Spine frame capture failed. Read native_capture.log (exit '+str(p.returncode)+')')
                capture_status='CAPTURED_GODOT_45_SPINE_NATIVE'
        validate_captured(output,clips,fps,(args.width,args.height))
        if not args.pack_existing_frames:
            try:
                from PIL import Image
            except ImportError as e:
                raise ConversionError('Pillow required for native alpha verification') from e
            for clip_name, clip_duration in clips:
                for i in range(max(1,round(clip_duration*fps))):
                    path=output/'frames'/clip_name/f'{i:04d}.png'
                    with Image.open(path) as img:
                        if img.mode != 'RGBA':
                            raise ConversionError('Native frame is not RGBA: '+str(path))
                        if img.getchannel('A').getbbox() is None:
                            raise ConversionError('Transparent-only frame: '+str(path))
            for clip_name, clip_duration in clips:
                count = max(1,round(clip_duration*fps))
                if count > 1 and clip_name.lower() in ('walk','run','attack','attack1'):
                    hashes = {sha256(output/'frames'/clip_name/f'{i:04d}.png') for i in range(count)}
                    if len(hashes) < 2:
                        raise ConversionError('Animation '+clip_name+' has no distinct frames; native capture may be static')
        actor_id=ident(args.actor_id or skel.stem)
        write_spriteframes(output,actor_id,clips,fps,args.foot_x,args.foot_y)
        manifest={'tool':'SpineToGodot472Tool V1.2 portable','input_files':digests,
                  'source_dependencies_exist':True,'skeleton_runtime_compatibility':('NATIVE_CAPTURED' if not args.pack_existing_frames else 'NOT_CHECKED'),
                  'native_capture':capture_status,
                  'animated_sprite_path':'res://actor.tscn', 'spriteframes_path':'res://sprite_frames.tres',
                'frames':total,'fps':fps,'clips':[{'name':a,'duration_seconds':t,'frames':max(1,round(t*fps))} for a,t in clips],
                  'canvas':[args.width,args.height], 'foot_anchor':[args.foot_x,args.foot_y],
                  'godot_472_import_status':'NOT_TESTED'}
        (output/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),'utf-8')
        safe_copy(ROOT/'native'/'verify_godot472.gd',output/'verify_godot472.gd')
        safe_copy(ROOT/'native'/'capture_godot472.gd',output/'capture_godot472.gd')
        (output/'project.godot').write_text('config_version=5\n\n[application]\nconfig/name="Spine to Godot 4.7.2 Export Test"\n\n[rendering]\nrenderer/rendering_method="gl_compatibility"\nrenderer/rendering_method.mobile="gl_compatibility"\n', 'utf-8')
        if eng472 and eng472.is_file():
            try:
                verify=subprocess.run([str(eng472),'--headless','--path',str(output),'--import','--quit'],
                                      stdout=subprocess.PIPE,stderr=subprocess.STDOUT,
                                      encoding='utf-8',errors='replace',timeout=args.timeout)
                (output/'godot472_import.log').write_text(verify.stdout,'utf-8')
                if verify.returncode != 0:
                    raise ConversionError('Godot 4.7.2 import returned '+str(verify.returncode))
                inspect=subprocess.run([str(eng472),'--headless','--path',str(output),
                                        '--script','res://verify_godot472.gd'],
                                       stdout=subprocess.PIPE,stderr=subprocess.STDOUT,
                                       encoding='utf-8',errors='replace',timeout=args.timeout)
                (output/'godot472_resource_test.log').write_text(inspect.stdout,'utf-8')
                if inspect.returncode != 0 or 'S2G_GODOT472_RESOURCE_PASS' not in inspect.stdout:
                    raise ConversionError('Godot 4.7.2 resource test failed; read godot472_resource_test.log')
                manifest['godot_472_import_status']='IMPORT_AND_RESOURCE_SMOKE_PASS; VISUAL_NOT_VERIFIED'
                (output/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),'utf-8')
                if not args.pack_existing_frames:
                    command=[str(eng472),'--path',str(output),'--rendering-method','gl_compatibility',
                             '--fixed-fps','30','--script','res://capture_godot472.gd']
                    capture=subprocess.run(command,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,
                                           encoding='utf-8',errors='replace',timeout=args.timeout,
                                           env=native_env(output/'QA_RESULTS'/'RuntimeEnv'))
                    (output/'godot472_visual_capture.log').write_text(capture.stdout or '',encoding='utf-8')
                    if capture.returncode != 0 or 'S2G_WINDOWS_CAPTURE_PASS' not in (capture.stdout or ''):
                        raise ConversionError('Godot 4.7.2 visual capture failed; see godot472_visual_capture.log')
                    manifest['godot_472_windows_capture_status']='CAPTURED; HUMAN_VISUAL_REVIEW_PENDING'
                    (output/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),'utf-8')
            except subprocess.TimeoutExpired as e:
                raise ConversionError('Godot 4.7.2 import timeout') from e
        print('EXPORT_GENERATED:',output)
        print('CAPTURE:',capture_status)
        print('GODOT_472:',manifest['godot_472_import_status'])
        print('FRAMES:',total)
    except Exception as exc:
        (output/'FAILED.txt').write_text(str(exc)+'\nDo not use as a verified asset; inspect logs.\n','utf-8')
        raise


def main():
    p=argparse.ArgumentParser(description=__doc__,formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    p.add_argument('--input',required=True,help='Spine .skel file or folder containing one .skel')
    p.add_argument('--atlas',help='Explicit .atlas path (default: alongside .skel)')
    p.add_argument('--textures',help='Atlas PNG page directory (default: alongside .atlas)')
    p.add_argument('--output',help='Stable actor asset directory named by actor ID')
    p.add_argument('--clips',default='',help='Native: comma-separated clip names, durations read from runtime. Pack-existing: name:duration pairs.')
    p.add_argument('--skin',dest='skins',action='append',default=[],
                   help='Select one source skin; repeat to combine a validated on-demand skin set')
    p.add_argument('--fps',type=int,default=30)
    p.add_argument('--width',type=int,default=768)
    p.add_argument('--height',type=int,default=768)
    p.add_argument('--foot-x',type=int,default=384)
    p.add_argument('--foot-y',type=int,default=540)
    p.add_argument('--actor-id')
    p.add_argument('--godot45',help='EXISTING Godot 4.5 binary WITH working Spine 3.8 runtime')
    p.add_argument('--spine-project',help='EXISTING working Godot 4.5 Spine runtime project; temporary copy only')
    p.add_argument('--template-scene',help='Optional res:// template .tscn with existing working SpineSprite (fallback)')
    p.add_argument('--godot472',help='Official Godot 4.7.2 executable; performs import smoke')
    p.add_argument('--pack-existing-frames',help='Skip capture; package existing PNG frames named clip/0000.png...')
    p.add_argument('--validate-only',action='store_true',help='Read-only validation of source/dependency and clip plan')
    p.add_argument('--inspect-only',action='store_true',help='Read verified clip metadata from existing Godot 4.5 Spine runtime')
    p.add_argument('--zip',action='store_true',help='Create one compact ZIP beside the actor directory')
    p.add_argument('--timeout',type=int,default=600)
    args=p.parse_args()
    try:
        if args.pack_existing_frames or args.inspect_only or args.validate_only:
            run_conversion(args)
        else:
            run_asset_export(args)
    except ConversionError as e:
        print('BLOCKED:',str(e),file=sys.stderr);sys.exit(2)
    except Exception as e:
        print('FAILED:',str(e),file=sys.stderr);sys.exit(1)

if __name__=='__main__':main()

