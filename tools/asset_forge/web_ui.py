"""localhost-only Asset Forge browser UI. No internet/external command execution."""
from __future__ import annotations
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import argparse
import hashlib
import json
import sqlite3
from urllib.parse import urlsplit, parse_qs
from studio import init_vault,stage_files,safe_file,probe_map,map_patch,skill_graph,skill_preview,skill_visual_recipe,map_preview,curated_jxqy_pilot,vault_paths,jxqy_player
from forge import cmd_inventory,cmd_sheet
from jx1_adapter import validate_playable, playable_sheet, pak_index, read_raw_pak_entry, Spr
from jx1_tables_v2 import player_table_catalog, link_catalog_to_pack
from jx1_player_pipeline_v4 import catalog_equipment_variants, catalog_selected_player, render_player_sheet

PAGE = r'''<!doctype html><html lang="vi"><head><meta charset="utf-8"><title>TMB Asset Forge Studio V2</title>
<meta name="viewport" content="width=device-width,initial-scale=1"><style>
:root{color-scheme:dark;font-family:Segoe UI,Arial,sans-serif;background:#111721;color:#edf2fc}*{box-sizing:border-box}
body{margin:0}header{padding:14px 22px;background:#1e2938;border-bottom:1px solid #334457}header b{font-size:21px}
small,.note{color:#b9c6d9}nav{display:flex;gap:8px;padding:12px 18px;background:#171e29;flex-wrap:wrap}
button{cursor:pointer;background:#294865;color:#fff;border:1px solid #467399;border-radius:6px;padding:8px 12px;font-weight:600}
button:hover{background:#37658c}button.secondary{background:#252f40}button.active{background:#367499}
main{padding:16px 22px;max-width:1350px;margin:auto}.panel{border:1px solid #344559;border-radius:9px;padding:15px;margin:12px 0;background:#1b2633}
.flex{display:flex;flex-wrap:wrap;gap:12px;align-items:center}label{display:block;color:#cbd8eb;margin:6px 0}input,select,textarea{width:100%;max-width:520px;padding:9px;margin:3px 0 10px;background:#121923;color:#fff;border:1px solid #4c6078;border-radius:5px}
textarea{height:95px}h2{margin:4px 0 10px;font-size:21px}h3{margin:12px 0 5px;font-size:17px}
.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(250px,1fr));gap:16px}
pre{white-space:pre-wrap;word-break:break-word;background:#111923;padding:12px;border-radius:5px;border:1px solid #2c3b4b;max-height:420px;overflow:auto}
.hidden{display:none}#mapcanvas{max-width:100%;background:#202936;border:1px solid #405568;image-rendering:pixelated;cursor:crosshair}
img.preview{max-width:100%;max-height:750px;border:1px solid #556;object-fit:contain}
.notice{margin-top:9px;padding:10px;background:#16283a;border-left:3px solid #4b8fb8}
</style></head><body><header><b>TÔNG MÔN BÁ ĐẠO — ASSET FORGE STUDIO</b><div class="note">V2 • Offline 127.0.0.1 • Giữ nguyên raw • Không sửa combat/save</div></header>
<nav><button data-tab="assets" class="active">Thư viện & nhập asset</button><button data-tab="map">Tool Map</button><button data-tab="skill">Tool Skill / VFX</button><button data-tab="player">Playable & Animation</button></nav>
<main><section id="assets"><h2>Asset Vault</h2><div class="panel"><p>Chỉ copy các file được chọn, kiểm SHA-256; file gốc và file đã stage không bị ghi đè.</p>
<div class="grid"><label>Nguồn / source ID<select id="srcid"><option>SOURCE_A</option><option>JX1_OWNER</option><option>JXQY2_OFFLINE</option><option>JX1M_UNITY</option></select></label><label>Thư mục nguồn trên máy<input id="fromroot" placeholder="E:\codex\work\jxqy2_slice\source"></label></div>
<label>Đường dẫn file cần nhập, mỗi dòng một file (tương đối với thư mục nguồn)<textarea id="paths" placeholder="save/rpg0/player.ini&#10;ini/npcres/z-南宫飞云.ini"></textarea></label>
<button onclick="stage()">Đưa file đã chọn vào 01_raw</button> <button class="secondary" onclick="pilot()">Nhập pilot nhân vật/skill JXQY2</button>
<button class="secondary" onclick="inventory()">Quét catalog SQLite</button><div class="note">Pilot chỉ copy asset có nguồn thật, không import hàng loạt vào Godot.</div></div>
<div class="panel"><h3>Danh mục</h3><div class="flex"><input id="search" placeholder="Tìm ID/tên file" oninput="listAssets()"><button onclick="listAssets()">Làm mới</button></div><pre id="assetlist">Chưa quét</pre></div></section>
<section id="map" class="hidden"><h2>Tool Map — MAP V2 có chứng cứ</h2><div class="panel"><label>Chọn MAP đã nhập<select id="mapfile"></select></label>
<div class="flex"><button onclick="loadMap()">Đọc map + collision</button><button class="secondary" onclick="renderMap()">Xuất preview bằng tile MPC thật</button></div>
<label>Thư mục tile MPC (tương đối với root nguồn), ví dụ: mpc/map/稻香村<input id="tiledir" value="mpc/map/矿山"></label>
<p class="note">Bấm ô để chọn. Toggle obstacle chỉ lưu một bản MAP mới trong 03_derived/maps — không sửa map nguồn.</p>
<canvas id="mapcanvas" width="750" height="520"></canvas><div id="cellinfo" class="notice">Chưa chọn ô.</div><button onclick="toggleObstacle()">Đổi obstacle ô đã chọn & lưu bản mới</button>
<pre id="mapmeta">Chưa đọc</pre><img id="mapimg" class="preview hidden" alt="Ảnh map dùng tile thật"></div></section>
<section id="skill" class="hidden"><h2>Tool Skill / VFX — nguồn thực</h2><div class="panel"><label>Skill JXQY2 có bảng INI<select id="skillname"></select></label>
<button onclick="loadSkill()">Đọc chuỗi kỹ năng</button> <button onclick="showSkill()">Xuất contact sheet cast / projectile / hit</button>
<div class="note">Không sửa sát thương, cooldown, RNG hoặc điều kiện học kỹ năng. Cast chung của player lấy từ NPC resource.</div>
<h3>Chỉnh VFX hiển thị — projectile</h3>
<div class="grid"><label>Lệch X<input id="fx_x" type="number" value="0" min="-512" max="512"></label><label>Lệch Y<input id="fx_y" type="number" value="0" min="-512" max="512"></label><label>Tỷ lệ hình<input id="fx_scale" type="number" value="1" min="0.1" max="4" step="0.1"></label><label>Tốc độ trình chiếu<input id="fx_speed" type="number" value="1" min="0.1" max="4" step="0.1"></label></div>
<button class="secondary" onclick="saveSkillRecipe()">Lưu cấu hình VFX (derived JSON)</button>
<pre id="skillmeta">Chưa đọc</pre><img id="skillimg" class="preview hidden" alt="Contact sheet kỹ năng"></div></section>
<section id="player" class="hidden"><h2>Playable character & trang phục</h2><div class="panel"><p>JXQY2: liên kết <code>save/rpg0/player.ini → ini/npcres</code>; JX1: cần bảng part + SPR gốc để kiểm trang phục thật.</p>
<label>Action của playable JXQY2<input id="playeraction" value="astand"></label>
<button onclick="inspectPlayer()">Kiểm playable</button> <button onclick="showPlayer()">Xuất contact sheet nhân vật</button>
<pre id="playermeta">Chưa đọc</pre><img id="playerimg" class="preview hidden" alt="Contact sheet playable">
<hr><h3>JX1 PAK → SPR (một asset mỗi lượt)</h3>
<p class="note">Nhập riêng PAK cần dùng vào <code>01_raw/JX1_OWNER</code>. Chỉ đọc index, hoặc trích đúng một resource ID ra <code>03_derived/jx1_spr</code>. Nhận diện PACK chuẩn; UCL và frame-split SPR có kiểm kích thước.</p>
<label>PAK đã stage, đường dẫn trong 01_raw/JX1_OWNER<input id="jxpak" placeholder="data/sprite.pak"></label>
<label>Resource ID trong index, dạng số hoặc 0x...<input id="jxpakid" placeholder="0x12345678"></label>
<button onclick="inspectJxPak()">Kiểm PAK và ID</button> <button onclick="extractJxSpr()">Giải nén một SPR vào 03_derived</button>
<pre id="jxpakmeta">Chưa đọc PAK</pre>
<hr><h3>JX1 bảng Kind → Part → Sect (nhân vật/trang bị)</h3>
<p class="note">Quét bảng nguồn đã nhập; chỉ tạo catalog bằng chứng. Special NPC là ứng viên ghép sprite, KHÔNG tự kết luận đó là nhân vật người chơi.</p>
<label>Tên nhân vật đúng trong Kind table<input id="jxchar" placeholder="Đúng ID/tên dòng trong 人物类型.txt"></label>
<label>Đường dẫn bảng Kind trong 01_raw/JX1_OWNER<input id="jxkind" value="settings/npcres/人物类型.txt"></label>
<button onclick="scanJxTables()">Quét bảng và đối chiếu PAK (nếu có)</button>
<pre id="jxtablemeta">Chưa quét</pre>
<hr><h3>JX1 playable — ghép áo / mũ / vũ khí</h3>
<p class="note">Chỉ đọc nguồn đã stage ở 01_raw/JX1_OWNER. Tệp khai báo có bằng chứng ở 02_catalog/jx1_playable_spec.json. Không tự coi NPC/quái là người chơi.</p>
<label>Loadout JSON (theo variant thật trong bảng part)<input id="jxloadout" value='{"body":"default","armor":"default","helm":"default","weapon":"default"}'></label>
<button onclick="checkJx1()">Kiểm SPR và chứng cứ playable</button>
<button onclick="sheetJx1()">Xuất contact sheet JX1 (PNG)</button>
<pre id="jx1meta">Chưa kiểm</pre><img id="jx1img" class="preview hidden" alt="JX1 playable compositing preview">
<hr><h3>AF-04: tự dò trang phục &amp; contact sheet 8 hướng trực tiếp từ source JX1</h3>
<p class="note">Không cần stage PAK khổng lồ. Dùng đúng thư mục nguồn JX1 có settings/npcres/人物类型.txt; chọn tối đa 6 PAK thật. Chỉ hai nhân vật chính được xác nhận: 男主角 / 女主角. Không import asset vào Godot.</p>
<label>Thư mục JX1 gốc trên máy<input id="af4root" value="E:\JX1" placeholder="E:\JX1"></label>
<div class="grid"><label>Nhân vật chính<select id="af4char"><option value="男主角">Nam chính — 男主角</option><option value="女主角">Nữ chính — 女主角</option></select></label>
<label>Action gốc (đúng tên cột)<input id="af4action" value="空手站立1"></label></div>
<label>Chỉ đường dẫn tới PAK cần thử (mỗi dòng một file, có thể để trống cho SPR rời)<textarea id="af4packs" placeholder="E:\JX1\data\sprite.pak"></textarea></label>
<label>Chọn biến thể trang bị theo tên bộ phận trong bảng (0-based)<input id="af4choices" value='{"躯体":0,"右手武器":0}'></label>
<div class="flex"><button onclick="af4Catalog()">Tự lập catalog trang phục</button><button onclick="af4Sheet()">Tự xuất 8 hướng thật</button></div>
<pre id="af4result">Chưa quét nguồn</pre><img id="af4preview" class="preview hidden" alt="AF-04 JX1 provenance-gated contact sheet">
</div></section>
<div class="panel"><h3>Thông báo</h3><pre id="status">Studio chạy nội bộ. Nhập pilot hoặc chọn nguồn để bắt đầu.</pre></div></main>
<script>
let activeMap=null, grid=[], cell=null, rawroot='', allMaps=[], mapCols=0, mapRows=0;
const $=id=>document.getElementById(id);
for(const b of document.querySelectorAll('nav button')) b.onclick=()=>{for(const t of ['assets','map','skill','player'])$(t).classList.toggle('hidden',t!==b.dataset.tab);for(const n of document.querySelectorAll('nav button'))n.classList.toggle('active',n===b);refresh();};
async function api(url,data){try{let opts=data===undefined?{}:{method:'POST',headers:{'Content-Type':'application/json','X-TMB-Local':'1'},body:JSON.stringify(data)};let r=await fetch(url,opts),j=await r.json();if(!r.ok)throw Error(j.error||r.status);return j}catch(e){$('status').textContent='ERROR: '+e.message;throw e}}
function status(v){$('status').textContent=JSON.stringify(v,null,2)};
async function refresh(){let v=await api('/api/list');allMaps=v.maps;$('mapfile').replaceChildren(...v.maps.map(x=>new Option(x,x)));$('skillname').replaceChildren(...v.skills.map(x=>new Option(x,x)));await listAssets()}
async function listAssets(){let q=encodeURIComponent($('search').value||'');let o=await api('/api/assets?q='+q);$('assetlist').textContent=JSON.stringify(o,null,2)}
async function stage(){status(await api('/api/stage',{source_id:$('srcid').value,root:$('fromroot').value,paths:$('paths').value.split('\n').map(x=>x.trim()).filter(Boolean)}));await refresh()}
async function pilot(){status(await api('/api/pilot',{root:$('fromroot').value}));await refresh()}
async function inventory(){status(await api('/api/inventory',{}));await refresh()}
async function loadMap(){let x=$('mapfile').value;if(!x)return;let r=await api('/api/map?file='+encodeURIComponent(x));activeMap=x;grid=r.cells;mapCols=r.info.width;mapRows=r.info.height;$('mapmeta').textContent=JSON.stringify(r.info,null,2);drawGrid();status({map:x,size:[mapCols,mapRows],blocked:r.info.blocked_cells})}
function drawGrid(){const c=$('mapcanvas'),g=c.getContext('2d');g.clearRect(0,0,c.width,c.height);let cw=c.width/mapCols,ch=c.height/mapRows;for(let y=0;y<mapRows;y++)for(let x=0;x<mapCols;x++){let item=grid[y*mapCols+x];g.fillStyle=(item.obstacle&192)?'#9d4d47':item.id?'#416b63':'#28333b';g.fillRect(x*cw,y*ch,cw+.5,ch+.5)}if(cell){g.strokeStyle='#fff';g.lineWidth=2;g.strokeRect(cell.x*cw,cell.y*ch,cw,ch)}}
$('mapcanvas').onclick=e=>{if(!mapCols)return;let rect=e.target.getBoundingClientRect(),x=Math.min(mapCols-1,Math.floor((e.clientX-rect.left)/rect.width*mapCols)),y=Math.min(mapRows-1,Math.floor((e.clientY-rect.top)/rect.height*mapRows));cell={x,y};let item=grid[y*mapCols+x];$('cellinfo').textContent=`Ô (${x},${y}) • obstacle=${item.obstacle} • trap=${item.trap} • tile layer0=${item.id}`;drawGrid()}
async function toggleObstacle(){if(!activeMap||!cell)return;let item=grid[cell.y*mapCols+cell.x],value=(item.obstacle&192)?(item.obstacle&63):(item.obstacle|192);let r=await api('/api/map-edit',{file:activeMap,edits:[{...cell,field:'obstacle',value}]});status(r);await refresh();$('mapfile').value=r.next_file;await loadMap()}
async function renderMap(){if(!activeMap)return;let r=await api('/api/map-preview',{file:activeMap,tile_dir:$('tiledir').value});status(r);$('mapimg').src=r.url+'?r='+Date.now();$('mapimg').classList.remove('hidden')}
async function loadSkill(){let r=await api('/api/skill?name='+encodeURIComponent($('skillname').value));$('skillmeta').textContent=JSON.stringify(r,null,2);status({skill:r.skill_name})}
async function showSkill(){let r=await api('/api/skill-preview',{name:$('skillname').value});status(r);$('skillimg').src=r.url+'?r='+Date.now();$('skillimg').classList.remove('hidden')}
async function saveSkillRecipe(){let r=await api('/api/skill-edit',{name:$('skillname').value,adjustments:{projectile:{offset_x:Number($('fx_x').value),offset_y:Number($('fx_y').value),scale:Number($('fx_scale').value),speed:Number($('fx_speed').value)}}});status(r)}
async function inspectPlayer(){let r=await api('/api/player');$('playermeta').textContent=JSON.stringify(r,null,2);status({playable:r.source_name,verified_assets:r.verified_assets})}
async function showPlayer(){let r=await api('/api/player-preview',{action:$('playeraction').value});status(r);$('playerimg').src=r.url+'?r='+Date.now();$('playerimg').classList.remove('hidden')}
async function inspectJxPak(){let r=await api('/api/jx1-pak-info',{pak:$('jxpak').value,id:$('jxpakid').value});$('jxpakmeta').textContent=JSON.stringify(r,null,2);status(r)}
async function extractJxSpr(){let r=await api('/api/jx1-pak-extract',{pak:$('jxpak').value,id:$('jxpakid').value});$('jxpakmeta').textContent=JSON.stringify(r,null,2);status(r)}
async function scanJxTables(){let r=await api('/api/jx1-tables',{character:$('jxchar').value,kind:$('jxkind').value,pak:$('jxpak').value});$('jxtablemeta').textContent=JSON.stringify(r,null,2);status(r)}
async function checkJx1(){let r=await api('/api/jx1-check');$('jx1meta').textContent=JSON.stringify(r,null,2);status(r)}
async function sheetJx1(){let loadout=JSON.parse($('jxloadout').value),r=await api('/api/jx1-sheet',{loadout});$('jx1meta').textContent=JSON.stringify(r,null,2);$('jx1img').src=r.url+'?r='+Date.now();$('jx1img').classList.remove('hidden');status(r)}
function af4Payload(){return {source_root:$('af4root').value,character:$('af4char').value,action:$('af4action').value,choices:JSON.parse($('af4choices').value),paks:$('af4packs').value.split('\n').map(x=>x.trim()).filter(Boolean)}}
async function af4Catalog(){let r=await api('/api/jx1-af04-catalog',af4Payload());$('af4result').textContent=JSON.stringify(r,null,2);status(r)}
async function af4Sheet(){let r=await api('/api/jx1-af04-sheet',af4Payload());$('af4result').textContent=JSON.stringify(r,null,2);$('af4preview').src=r.url+'?r='+Date.now();$('af4preview').classList.remove('hidden');status(r)}
refresh().catch(()=>{});
</script></body></html>'''


def serve(vault:Path,port:int=8791):
    base=Path(vault).resolve()
    init_vault(base)
    source_root=base/'01_raw'/'JXQY2_OFFLINE'
    def resolve_file(name:str) ->Path:
        candidate=(base/name).resolve()
        if not candidate.is_relative_to(base/'01_raw') and not candidate.is_relative_to(base/'03_derived'):
            raise ValueError('file is outside staged/derived roots')
        if not candidate.is_file():raise FileNotFoundError(str(candidate))
        return candidate
    def rooted_rel(file:Path)->str:return file.relative_to(base).as_posix()
    class Handler(BaseHTTPRequestHandler):
        def log_message(self,*args):pass
        def reply(self,obj,status=200):
            data=json.dumps(obj,ensure_ascii=False).encode('utf-8')
            self.send_response(status);self.send_header('Content-Type','application/json; charset=utf-8');self.send_header('Cache-Control','no-store');self.send_header('Content-Length',str(len(data)));self.end_headers();self.wfile.write(data)
        def handle_error(self,exc):self.reply({'error':str(exc)},400)
        def do_GET(self):
            u=urlsplit(self.path);q=parse_qs(u.query)
            try:
                if u.path=='/':
                    content=PAGE.encode('utf-8');self.send_response(200);self.send_header('Content-Type','text/html; charset=utf-8');self.send_header('Content-Length',str(len(content)));self.end_headers();self.wfile.write(content);return
                if u.path.startswith('/preview/'):
                    rel=u.path[len('/preview/'):]
                    file=safe_file(base/'04_previews',rel)
                    if not file.is_file() or file.suffix.lower()!='.png':raise ValueError('invalid preview')
                    content=file.read_bytes();self.send_response(200);self.send_header('Content-Type','image/png');self.send_header('Content-Length',str(len(content)));self.end_headers();self.wfile.write(content);return
                if u.path=='/api/list':
                    maps=[rooted_rel(f) for folder in [base/'01_raw',base/'03_derived'/'maps'] for f in folder.rglob('*.map') if f.is_file() and not f.is_symlink()]
                    skroot=source_root/'ini/magic'
                    skills=[x.name[len('player-magic-'):-4] for x in skroot.glob('player-magic-*.ini')] if skroot.is_dir() else []
                    return self.reply({'maps':sorted(maps)[:300],'skills':sorted(skills)[:300]})
                if u.path=='/api/assets':
                    term=q.get('q',[''])[0];db=base/'02_catalog/forge.sqlite3';rows=[]
                    if db.is_file():
                        with sqlite3.connect(db) as con:
                            rows=[dict(zip(['source_id','path','format','size','sha256','kind'],r)) for r in con.execute('SELECT source_id,path,format,size_bytes,sha256,kind FROM source_files WHERE path LIKE ? ORDER BY path LIMIT 160',('%'+term+'%',))]
                    return self.reply({'count':len(rows),'items':rows,'hint':'Use Quét catalog SQLite after staging' if not db.is_file() else None})
                if u.path=='/api/map':
                    f=resolve_file(q.get('file',[''])[0]);info=probe_map(f);raw=f.read_bytes();off=info['grid_offset'];w,h=info['width'],info['height']
                    cells=[{'id':raw[off+i*10+1], 'obstacle':raw[off+i*10+6],'trap':raw[off+i*10+7]} for i in range(w*h)]
                    return self.reply({'info':info,'cells':cells})
                if u.path=='/api/skill':return self.reply(skill_graph(source_root,q.get('name',[''])[0]))
                if u.path=='/api/player':return self.reply(jxqy_player(source_root))
                if u.path=='/api/jx1-check':
                    specfile=base/'02_catalog/jx1_playable_spec.json'
                    spec=json.loads(specfile.read_text(encoding='utf-8'))
                    return self.reply(validate_playable(spec,base/'01_raw/JX1_OWNER'))
                raise ValueError('route not found')
            except (OSError,ValueError,KeyError,sqlite3.Error) as e:self.handle_error(e)
        def do_POST(self):
            try:
                if self.headers.get('Content-Type','').split(';')[0]!='application/json' or self.headers.get('X-TMB-Local')!='1':raise ValueError('local JSON request header required')
                n=int(self.headers.get('Content-Length','0'))
                if n<2 or n>65536:raise ValueError('invalid request size')
                body=json.loads(self.rfile.read(n))
                route=urlsplit(self.path).path
                if route=='/api/stage':result=stage_files(base,str(body['source_id']),Path(str(body['root'])),list(body['paths']))
                elif route=='/api/pilot':result=stage_files(base,'JXQY2_OFFLINE',Path(body['root']),curated_jxqy_pilot(Path(body['root'])))
                elif route=='/api/inventory':
                    from contextlib import redirect_stdout
                    import io
                    dst=base/'02_catalog/forge.sqlite3'
                    roots=[f'{p.name}={p}' for p in (base/'01_raw').iterdir() if p.is_dir()]
                    with redirect_stdout(io.StringIO()):cmd_inventory(argparse.Namespace(source=roots,db=str(dst),out=str(base/'06_reports'/'inventory.json')))
                    result=json.loads((base/'06_reports'/'inventory.json').read_text(encoding='utf-8'))
                elif route in ('/api/jx1-pak-info','/api/jx1-pak-extract'):
                    # The selected source file must have been explicitly staged.
                    rel=str(body.get('pak',''))
                    src=safe_file(base/'01_raw/JX1_OWNER',rel)
                    if not src.is_file() or src.suffix.lower()!='.pak':raise ValueError('stage a specific .pak before scanning')
                    ident=str(body.get('id','')).strip()
                    if len(ident)>14 or not ident or not (ident.isdecimal() or (ident.startswith('0x') and all(x in '0123456789abcdefABCDEF' for x in ident[2:]))):
                        raise ValueError('valid PAK ID (decimal or 0x hex) required')
                    uid=int(ident,0) if ident.startswith('0x') else int(ident,10)
                    if not 0<=uid<=0xffffffff:raise ValueError('PAK ID out of range')
                    meta=pak_index(src)
                    entries=[row for row in meta['entries'] if row['id']==uid]
                    if route=='/api/jx1-pak-info':
                        result={'archive_sha256':hash_stream(src),
                                'count':meta['count'],'signature':meta['signature'],
                                'matching_records':entries, 'status':'INDEX_ONLY_NOT_BULK_IMPORT'}
                    else:
                        if len(entries)!=1:raise ValueError('PAK asset ID missing or ambiguous')
                        blob=read_raw_pak_entry(src,uid)
                        info=Spr(blob).header
                        packsha=hash_stream(src)
                        dest=base/'03_derived/jx1_spr'/f'{packsha[:12]}-{uid:08x}.spr'
                        dest.parent.mkdir(parents=True,exist_ok=True)
                        if dest.exists():
                            if dest.read_bytes()!=blob:raise FileExistsError('existing derived SPR differs; not overwritten')
                            stage='ALREADY_VERIFIED'
                        else:
                            with dest.open('xb') as o:o.write(blob)
                            stage='NEW_SINGLE_ASSET'
                        report={'source_pak':str(src),'source_pak_sha256':packsha,'id':uid,
                                'derived_sha256':hashlib.sha256(blob).hexdigest(),'derived':str(dest),
                                'spr':info,'status':stage,'gameplay_edit':False}
                        manifest=dest.with_suffix('.json')
                        if manifest.exists():
                            saved=json.loads(manifest.read_text(encoding='utf-8'))
                            if saved.get('derived_sha256')!=report['derived_sha256']:
                                raise ValueError('derived provenance conflict')
                        else:
                            with manifest.open('x',encoding='utf-8') as o:json.dump(report,o,ensure_ascii=False,indent=2)
                        result=report
                elif route=='/api/jx1-tables':
                    origin=base/'01_raw/JX1_OWNER'
                    rel=str(body.get('kind',''))
                    kind=safe_file(origin,rel)
                    if not kind.is_file() or kind.suffix.lower()!='.txt':raise ValueError('JX1 Kind table must be an existing staged .txt')
                    character=str(body.get('character','')).strip()
                    if not 1<=len(character)<=100:raise ValueError('character name required')
                    result=player_table_catalog(kind,character,origin/'settings/npcres',origin,max_rows=12)
                    selected_pak=str(body.get('pak','')).strip()
                    if selected_pak:
                        candidate=safe_file(origin,selected_pak)
                        if not candidate.is_file() or candidate.suffix.lower()!='.pak':raise ValueError('selected PAK is not staged')
                        result['pak_links']=link_catalog_to_pack(result,[candidate],limit=160)
                    result['status']='KIND_PART_SECT_SOURCE_ONLY_PLAYER_IDENTITY_PENDING'
                    dest=base/'02_catalog'/('jx1_tables_'+hashlib.sha256((character+str(kind)).encode()).hexdigest()[:14]+'.json')
                    if not dest.exists():
                        with dest.open('x',encoding='utf-8') as o:json.dump(result,o,ensure_ascii=False,indent=2)
                    result['catalog_report']=str(dest)
                elif route in ('/api/jx1-af04-catalog','/api/jx1-af04-sheet'):
                    rawroot=str(body.get('source_root','')).strip()
                    character=str(body.get('character','')).strip()
                    action=str(body.get('action','')).strip()
                    choices=body.get('choices',{})
                    pp=body.get('paks',[])
                    if not 1<=len(rawroot)<=800 or not isinstance(pp,list) or len(pp)>6 or any(not isinstance(v,str) or len(v)>800 for v in pp):
                        raise ValueError('source root / PAK selections invalid')
                    if not isinstance(choices,dict):raise ValueError('equipment choices JSON object required')
                    root=Path(rawroot).resolve(strict=True)
                    packs=[Path(v).resolve(strict=True) for v in pp]
                    if route=='/api/jx1-af04-catalog':
                        report=catalog_equipment_variants(root,character,action,packs)
                        key=hashlib.sha256(json.dumps({'root':str(root),'character':character,'action':action,
                          'packs':list(map(str,packs))},ensure_ascii=False,sort_keys=True).encode()).hexdigest()[:16]
                        out=base/'02_catalog'/('af04-player-variants-'+key+'.json')
                        if out.exists():
                            old=json.loads(out.read_text(encoding='utf-8'))
                            if old['kind_table_sha256']!=report['kind_table_sha256'] or old['variants_found']!=report['variants_found']:
                                raise FileExistsError('catalog key already occupied by different input: preserve old revision')
                        else:
                            with out.open('x',encoding='utf-8') as f:json.dump(report,f,ensure_ascii=False,indent=2)
                        result={'catalog_file':str(out),'variants_found':report['variants_found'],'groups':report['groups'],
                                'status':report['status']}
                    else:
                        report=catalog_selected_player(root,character,action,choices,packs)
                        bits=[report['playable_source_proof']['kind_table_sha256'],report['source_sort_sha256'],
                              action,json.dumps(choices,ensure_ascii=False,sort_keys=True)]
                        bits.extend(s['source']['sha256'] for s in report['selected'])
                        signature=hashlib.sha256('\n'.join(bits).encode('utf-8')).hexdigest()[:20]
                        dest=base/'04_previews/players'/('af04-'+signature+'.png')
                        if dest.is_file() and dest.with_suffix('.json').is_file():
                            result=json.loads(dest.with_suffix('.json').read_text(encoding='utf-8'))
                            if result.get('png_sha256')!=hash_stream(dest):raise ValueError('preview/provenance conflict')
                            result['status']='EXISTING_VERIFIED_CONTACT_SHEET__OWNER_VISUAL_PENDING'
                        else:result=render_player_sheet(report,dest,frame=0,render_dirs=8)
                        result['url']='/preview/players/'+dest.name
                elif route=='/api/jx1-sheet':
                    specfile=base/'02_catalog/jx1_playable_spec.json'
                    spec=json.loads(specfile.read_text(encoding='utf-8'))
                    loadout=body.get('loadout',{})
                    if not isinstance(loadout,dict) or len(loadout)>12 or not all(isinstance(k,str) and isinstance(v,str) and len(v)<=64 for k,v in loadout.items()):
                        raise ValueError('invalid JX1 loadout')
                    signature=hashlib.sha256(specfile.read_bytes()+json.dumps(loadout,sort_keys=True).encode()).hexdigest()[:16]
                    dest=base/'04_previews/players'/('jx1-'+signature+'.png')
                    result=playable_sheet(spec,base/'01_raw/JX1_OWNER',dest,loadout)
                    result['url']='/preview/players/'+dest.name
                elif route=='/api/map-edit':
                    f=resolve_file(str(body['file']))
                    name=f.stem+'-'+hashlib.sha256(json.dumps(body['edits'],sort_keys=True).encode()).hexdigest()[:10]+'.map'
                    derived=base/'03_derived/maps'/name
                    recipe=base/'03_derived/maps'/(name+'.recipe.json')
                    recipe_obj={'source_sha256':hashlib.sha256(f.read_bytes()).hexdigest(),'edits':body['edits']}
                    if derived.exists():raise ValueError('derived map exists; adjust recipe to create a new revision')
                    recipe.parent.mkdir(parents=True,exist_ok=True)
                    write_json_local(recipe,recipe_obj)
                    result=map_patch(f,recipe,derived)
                    result['next_file']=rooted_rel(derived)
                elif route=='/api/skill-edit':
                    name=str(body['name'])
                    sequence=hashlib.sha256(json.dumps(body['adjustments'],sort_keys=True).encode('utf-8')).hexdigest()[:12]
                    dest=base/'03_derived/skills'/(hashlib.sha256(name.encode('utf-8')).hexdigest()[:12]+'-'+sequence+'.json')
                    result=skill_visual_recipe(source_root,name,body['adjustments'],dest)
                elif route=='/api/skill-preview':
                    name=str(body['name']);dest=base/'04_previews/skills'/(hashlib.sha256(name.encode()).hexdigest()[:12]+'.png')
                    result=skill_preview(source_root,name,dest)
                    result['url']='/preview/skills/'+dest.name
                elif route=='/api/map-preview':
                    f=resolve_file(str(body['file']))
                    tile_dir=str(body['tile_dir']);name=hashlib.sha256((str(f)+tile_dir).encode()).hexdigest()[:12]+'.png'
                    dest=base/'04_previews/maps'/name
                    result=map_preview(f,source_root,tile_dir,dest,tuple(body['crop']) if body.get('crop') else None)
                    result['url']='/preview/maps/'+name
                elif route=='/api/player-preview':
                    action=str(body.get('action','astand'))
                    if not action.isascii() or not action.isalnum():raise ValueError('invalid action')
                    dest=base/'04_previews/players'/('jxqy_'+action+'.png')
                    from contextlib import redirect_stdout
                    import io
                    with redirect_stdout(io.StringIO()):cmd_sheet(argparse.Namespace(root=str(source_root),action=action,out=str(dest)))
                    result={'preview':str(dest),'url':'/preview/players/'+dest.name,'role':'verified_source_playable','equipment_change':'NOT_VERIFIED'}
                else:raise ValueError('unknown POST route')
                self.reply(result)
            except (OSError,ValueError,KeyError,TypeError,sqlite3.Error,json.JSONDecodeError) as e:self.handle_error(e)
    def hash_stream(path):
        digest=hashlib.sha256()
        with Path(path).open('rb') as handle:
            for chunk in iter(lambda:handle.read(1024*1024),b''):
                digest.update(chunk)
        return digest.hexdigest()
    def write_json_local(target,obj):target.write_text(json.dumps(obj,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    if not 1024<=port<=65535:raise ValueError('invalid port')
    server=ThreadingHTTPServer(('127.0.0.1',port),Handler)
    print(f'TMB Asset Forge Studio V2: http://127.0.0.1:{port}')
    print('Close terminal or Ctrl+C to stop; only localhost connections accepted.')
    try:server.serve_forever()
    finally:server.server_close()