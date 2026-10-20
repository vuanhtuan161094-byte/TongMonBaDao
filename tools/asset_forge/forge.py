#!/usr/bin/env python3
"""TMB Asset Forge AF-C0/C1: read-only index, JXQY2 proof, MAP/skill probes, contact sheet.
Python 3.10+, Pillow for contact sheet; other commands use Python standard library.
Does not execute binaries, change source files, or integrate gameplay.
"""
import argparse
import configparser
import hashlib
import io
import json
import os
from pathlib import Path
import sqlite3
import struct
import sys
from collections import Counter

KNOWN = {".pak", ".spr", ".mpc", ".asf", ".map", ".mpi", ".png", ".webp", ".tpsheet", ".ini", ".txt", ".json", ".skel", ".atlas", ".wav", ".ogg"}


def write_json(path, obj):
    target = Path(path).resolve()
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(json.dumps(obj, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def digest(path):
    h = hashlib.sha256()
    size = 0
    with open(path, "rb") as handle:
        for part in iter(lambda: handle.read(1024 * 1024), b""):
            h.update(part)
            size += len(part)
    return h.hexdigest(), size


def load_ini(path):
    raw = Path(path).read_bytes()
    decoded = None
    for encoding in ("utf-8-sig", "gb18030", "cp1258", "latin-1"):
        try:
            decoded = raw.decode(encoding)
            break
        except UnicodeDecodeError:
            continue
    cp = configparser.ConfigParser(interpolation=None, strict=False)
    cp.optionxform = str.lower
    cp.read_string(decoded or "")
    return cp


def safe_file(root, rel):
    # No content may escape the explicit source root.
    base = Path(root).resolve()
    path = (base / rel).resolve()
    if not path.is_relative_to(base):
        raise ValueError("Invalid path outside source root: " + str(rel))
    return path


def cmd_inventory(a):
    db = Path(a.db).resolve()
    roots = []
    for item in a.source:
        if "=" not in item:
            raise ValueError("Use SOURCE_ID=path")
        source_id, raw_root = item.split("=", 1)
        root = Path(raw_root).resolve()
        if not source_id or not root.is_dir():
            raise ValueError("Invalid source: " + item)
        if db.is_relative_to(root):
            raise ValueError("DB must reside OUTSIDE immutable source root")
        roots.append((source_id, root))
    db.parent.mkdir(parents=True, exist_ok=True)
    con = sqlite3.connect(db)
    try:
        con.execute("PRAGMA journal_mode=WAL")
        con.execute("""CREATE TABLE IF NOT EXISTS source_files(
          source_id TEXT NOT NULL, path TEXT NOT NULL, format TEXT NOT NULL,
          size_bytes INTEGER NOT NULL, sha256 TEXT NOT NULL, kind TEXT NOT NULL,
          verification TEXT NOT NULL, PRIMARY KEY(source_id,path))""")
        con.execute("CREATE INDEX IF NOT EXISTS idx_kind ON source_files(kind)")
        report = []
        for source_id, root in roots:
            formats = Counter()
            processed = 0
            skipped = 0
            for folder, dirs, files in os.walk(root, followlinks=False):
                dirs[:] = sorted(d for d in dirs if not (Path(folder) / d).is_symlink())
                for name in sorted(files):
                    full = Path(folder) / name
                    if full.is_symlink() or not full.is_file():
                        skipped += 1
                        continue
                    rel = full.relative_to(root).as_posix()
                    suffix = full.suffix.lower()
                    try:
                        value, size = digest(full)
                    except (OSError, PermissionError):
                        skipped += 1
                        continue
                    # Intentional: paths never prove player, boss, or skill membership.
                    kind = "unclassified"
                    if suffix == ".map": kind = "map_candidate"
                    elif suffix in (".spr", ".mpc", ".asf"): kind = "sprite_candidate"
                    elif suffix in (".png", ".webp", ".tpsheet"): kind = "image_candidate"
                    elif suffix in (".pak",): kind = "container_candidate"
                    elif suffix in (".ini", ".txt"): kind = "metadata_candidate"
                    con.execute("INSERT INTO source_files VALUES(?,?,?,?,?,?,?) "
                                "ON CONFLICT(source_id,path) DO UPDATE SET format=excluded.format, "
                                "size_bytes=excluded.size_bytes,sha256=excluded.sha256,kind=excluded.kind, "
                                "verification=excluded.verification",
                                (source_id, rel, suffix, size, value, kind, "HASH_ONLY_CLASSIFICATION_UNVERIFIED"))
                    formats[suffix or "(none)"] += 1
                    processed += 1
            con.commit()
            report.append({"source": source_id, "root": str(root), "indexed_files": processed,
                           "skipped": skipped, "formats": dict(sorted(formats.items())),
                           "rights": "USE_EXISTING_RIGHTS_LEDGER", "playable_verified": 0})
        output = {"status": "INDEXED_HASH_ONLY_NOT_RENDER_QA", "db": str(db), "sources": report}
        if a.out: write_json(a.out, output)
        print(json.dumps(output, ensure_ascii=False, indent=2))
    finally:
        con.close()


def jxqy_player(root):
    player = safe_file(root, "save/rpg0/player.ini")
    if not player.is_file():
        raise FileNotFoundError("Missing save/rpg0/player.ini, cannot prove playable role")
    ini = load_ini(player)
    if not ini.has_section("init") or not ini.has_option("init", "npcini"):
        raise ValueError("Missing player-to-npcini reference")
    source_npc = ini.get("init", "npcini")
    npcres = safe_file(root, "ini/npcres/" + source_npc)
    if not npcres.is_file():
        raise FileNotFoundError(str(npcres))
    res = load_ini(npcres)
    assets = {}
    for section in res.sections():
        img = res.get(section, "image", fallback="").strip()
        if not img: continue
        path = safe_file(root, "mpc/character/" + img)
        assets[section] = {"image": img, "path": "mpc/character/" + img,
                           "exists": path.is_file(),
                           "sha256": digest(path)[0] if path.is_file() else None}
    return {"source_family": "jxqy2_offline", "role": "playable_source_evidenced",
            "role_evidence": ["save/rpg0/player.ini", "ini/npcres/" + source_npc],
            "source_name": ini.get("init", "name", fallback=""), "npcini": source_npc,
            "animations": assets, "equipment_visual_swap": "NOT_VERIFIED",
            "school": "NOT_VERIFIED", "verified_assets": sum(i["exists"] for i in assets.values()),
            "missing_assets": [v["path"] for v in assets.values() if not v["exists"]]}


def cmd_player(a):
    data = jxqy_player(a.root)
    if a.out: write_json(a.out, data)
    print(json.dumps(data, ensure_ascii=False, indent=2))


def cmd_skill(a):
    root = Path(a.root).resolve()
    src = safe_file(root, "ini/magic/player-magic-" + a.name + ".ini")
    if not src.is_file():
        raise FileNotFoundError(str(src))
    ini = load_ini(src)
    fields = {"icon": "icon", "display_image": "image", "projectile": "flyingimage",
              "impact": "vanishimage", "cast_action": "actionfile", "audio_projectile": "flyingsound",
              "audio_impact": "vanishsound"}
    targets = {}
    for kind, col in fields.items():
        name = ini.get("init", col, fallback="").strip()
        if not name:
            targets[kind] = {"reference": None, "status": "UNDECLARED"}
            continue
        folder = "mpc/magic" if kind in ("icon", "display_image") else "mpc/effect"
        if kind.startswith("audio_"): folder = "music"
        if kind == "cast_action": folder = "mpc/character"
        path = safe_file(root, folder + "/" + name)
        targets[kind] = {"reference": name, "candidate_path": folder + "/" + name,
                         "status": "FILE_EXISTS" if path.is_file() else "NOT_FOUND_AT_CANDIDATE_PATH"}
    out = {"source_family":"jxqy2_offline", "skill_name": a.name,
           "source_path":src.relative_to(root).as_posix(), "skill_source_sha256":digest(src)[0],
           "mapping_status":"ASSET_REFERENCES_ONLY_NOT_COMBAT_RULES", "visual":targets,
           "no_damage_import":True, "no_unverified_cast":True}
    if a.out: write_json(a.out, out)
    print(json.dumps(out, ensure_ascii=False, indent=2))


def map_probe(data):
    if len(data) < 16512 or data[:15] != b"MAP File Ver2.0":
        raise ValueError("Unsupported MAP format (this probe is JXQY2 MAP V2 only)")
    w, h, info, namesize = struct.unpack_from("<4i", data, 68)
    if not (1 <= w <= 1024 and 1 <= h <= 1024 and info == 64 and namesize == 32):
        raise ValueError("Invalid dimensions/record headers")
    start = 192 + 255 * info
    if len(data) != start + w * h * 10:
        raise ValueError("Unexpected MAP length")
    cells = data[start:]
    blocked = 0
    traps = 0
    layers = [0,0,0]
    for i in range(0,len(cells),10):
        for layer in range(3):
            if cells[i + layer*2 + 1]: layers[layer] += 1
        if cells[i+6] & 0xC0: blocked += 1
        if cells[i+7]: traps += 1
    return {"format":"JXQY2_MAP_V2_CONFIRMED_HEADER", "width":w, "height":h,
            "blocked_mask":"0xC0", "blocked_cells":blocked,"trap_cells":traps,
            "populated_cells_per_layer":layers,
            "collision_source":"map_binary_not_png_inference", "editing_enabled":False}


def cmd_map(a):
    path = Path(a.file).resolve()
    data = path.read_bytes()
    d = map_probe(data)
    d.update({"file":str(path),"sha256":hashlib.sha256(data).hexdigest()})
    if a.out: write_json(a.out,d)
    print(json.dumps(d,ensure_ascii=False,indent=2))


def mpc_metadata(raw):
    if len(raw)<48 or raw[:15] != b"IMG File Ver1.0":
        raise ValueError("Unsupported MPC/IMG signature")
    n,dirs,ms = struct.unpack_from("<iii",raw,16)
    if not(1<=n<=4096 and 0<=dirs<=32 and 0<=ms<=60000):
        raise ValueError("Bad MPC frame metadata")
    frames=[];offset=48
    for idx in range(n):
        if offset+16>len(raw):raise ValueError("Truncated MPC frame header")
        length, ax, ay, _ = struct.unpack_from("<iiii",raw,offset)
        offset+=16
        if length<=0 or offset+length>len(raw):raise ValueError("Truncated MPC frame data")
        payload=raw[offset:offset+length]
        if not payload.startswith(b"\x89PNG\r\n\x1a\n"):
            raise ValueError("Bad PNG frame")
        frames.append((payload,(ax,ay)))
        offset+=length
    if offset!=len(raw): raise ValueError("Unexpected MPC trailing bytes")
    dirs=max(1,dirs)
    if n<dirs:dirs=1
    if n%dirs: raise ValueError("Frame count not evenly divisible by directions")
    return {"directions":dirs,"frame_count":n,"frames_per_direction":n//dirs,
            "interval_ms":ms or 16,"frames":frames}


def cmd_sheet(a):
    try:
        from PIL import Image,ImageDraw,ImageFont
    except ImportError as e:
        raise RuntimeError("Pillow required for PNG sheets: pip install pillow") from e
    root=Path(a.root).resolve()
    person=jxqy_player(root)
    key=a.action
    if key not in person["animations"]:
        raise ValueError(f"Action {key!r} not in player.ini-linked npcres sections")
    asset=person["animations"][key]
    if not asset["exists"]:
        raise FileNotFoundError("Missing true playable source asset: " + asset["path"])
    raw=safe_file(root,asset["path"]).read_bytes()
    dec=mpc_metadata(raw)
    dirs=dec["directions"]
    thumb_w,thumb_h=155,178
    cols=min(4,dirs); rows=(dirs+cols-1)//cols
    image=Image.new("RGBA",(cols*thumb_w,rows*thumb_h+72),(32,35,41,255))
    draw=ImageDraw.Draw(image)
    draw.text((8,6),f"JXQY2 playable source: {person['source_name']} [{key}]",fill="white")
    draw.text((8,27),f"{dirs} directions | {dec['frame_count']} frames | {dec['interval_ms']}ms/frame",fill=(205,205,205))
    draw.text((8,48),"Proof: save/rpg0/player.ini -> ini/npcres",fill=(180,220,180))
    for d in range(dirs):
        frame,anchor=dec["frames"][d*dec["frames_per_direction"]]
        src=Image.open(io.BytesIO(frame)).convert("RGBA")
        if max(src.size)>130:
            src.thumbnail((130,140))
        x=(d%cols)*thumb_w; y=(d//cols)*thumb_h+72
        center=x+thumb_w//2
        foot=y+150
        image.alpha_composite(src,(center-min(src.width//2,center-x),foot-src.height))
        draw.text((x+6,y+155),f"dir={d} source frame={d*dec['frames_per_direction']}",fill="white")
    target=Path(a.out).resolve();target.parent.mkdir(parents=True,exist_ok=True)
    image.convert("RGB").save(target,"PNG")
    write_json(target.with_suffix(".json"),{"source":"jxqy2_offline", "source_asset":asset["path"],
               "source_sha256":asset["sha256"], "playable_proof":person["role_evidence"],
               "clip":key,"directions":dirs, "frames":dec["frame_count"],
               "equipment_visual_swap":"NOT_VERIFIED"})
    print("CREATED real-source contact sheet:",target)


def main():
    p=argparse.ArgumentParser(description="TMB AF-C0/C1 read-only proof toolkit")
    subs=p.add_subparsers(dest="command",required=True)
    i=subs.add_parser("inventory");i.add_argument("--source",action="append",required=True,
                                                    help="SOURCE_ID=EXISTING_RAW_PATH")
    i.add_argument("--db",required=True);i.add_argument("--out");i.set_defaults(fn=cmd_inventory)
    c=subs.add_parser("jxqy-player");c.add_argument("--root",required=True);c.add_argument("--out");c.set_defaults(fn=cmd_player)
    s=subs.add_parser("jxqy-skill");s.add_argument("--root",required=True);s.add_argument("--name",required=True);s.add_argument("--out");s.set_defaults(fn=cmd_skill)
    m=subs.add_parser("jxqy-map");m.add_argument("--file",required=True);m.add_argument("--out");m.set_defaults(fn=cmd_map)
    sh=subs.add_parser("jxqy-sheet");sh.add_argument("--root",required=True);sh.add_argument("--out",required=True)
    sh.add_argument("--action",default="astand");sh.set_defaults(fn=cmd_sheet)
    a=p.parse_args()
    try:a.fn(a)
    except (OSError,ValueError,RuntimeError,configparser.Error) as e:
        print("PENDING/ERROR:",str(e),file=sys.stderr)
        sys.exit(2)


if __name__=="__main__":main()