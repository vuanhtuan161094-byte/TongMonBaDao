#!/usr/bin/env python3
"""Publish existing native Godot captures on the same One Game Pages site.
No generated motion, promotion of candidate art, or new Godot project.
"""
import argparse
import html
import json
import math
import shutil
from pathlib import Path

SCHOOLS = {
    "sword":"Kiếm Tu", "blade":"Đao Tu", "dual_blade":"Song Đao",
    "spear":"Thương Tu", "bow":"Cung Tu", "fist":"Quyền Tu",
    "palm":"Chưởng Tu", "poison":"Độc Tu", "talisman":"Phù Tu",
    "curse":"Chú Tu", "formation":"Trận Tu", "summon":"Triệu Hoán",
}

def esc(value):
    return html.escape(str(value), quote=True)

def source(root, value, suffix):
    if not isinstance(value, str) or not value.startswith("res://"):
        return None
    path = (root / value.removeprefix("res://")).resolve()
    if root not in path.parents or path.suffix.lower() != suffix:
        raise ValueError(f"Invalid review media path: {value}")
    return path if path.is_file() else None

def build(root, dest, sha):
    root, dest = root.resolve(), dest.resolve()
    if root == dest or root in dest.parents:
        raise ValueError("Review output must be outside canonical source")
    registry = json.loads((root / "labs/combat_lab/vfx_factory/registry.json").read_text(encoding="utf-8"))
    batches = registry["native_batches"]
    dest.mkdir(parents=True, exist_ok=True)
    sections, videos, buttons = [], 0, 0
    for school, name in SCHOOLS.items():
        batch = batches.get(school, {})
        video = source(root, batch.get("video"), ".mp4")
        index = source(root, batch.get("last_capture_index"), ".json")
        # Some batches store exact native media on the per-skill rows.
        if not video:
            for row in registry.get("entries", []):
                if row.get("school") != school:
                    continue
                candidate = source(root, row.get("native_video"), ".mp4")
                if candidate:
                    video = candidate
                    index = source(root, row.get("native_index"), ".json")
                    break
        label = "Chờ duyệt mỹ thuật · PvE HOLD"
        if not video:
            sections.append(f"<section><h2>{esc(name)}</h2><p>Chưa có đường dẫn MP4 trong registry hiện tại.</p></section>")
            continue
        with video.open("rb") as stream:
            if stream.read(32)[4:8] != b"ftyp":
                raise ValueError(f"Not an MP4 container: {video}")
        out = dest / f"{school}.mp4"
        shutil.copyfile(video, out)
        videos += 1
        storyboard = "STORYBOARD" in str(batch.get("receipt_status", ""))
        caption = "Storyboard, không có receipt gameplay" if storyboard else "Godot Lab — không phải PvE chính thức"
        section = [f'<section><h2>{esc(name)}</h2><p>{esc(caption)} · {esc(label)}</p>',
                   f'<video id="v-{school}" controls playsinline preload="none" src="{school}.mp4"></video>',
                   f'<p><a href="{school}.mp4">Mở MP4 trực tiếp</a></p>']
        if index:
            skills = json.loads(index.read_text(encoding="utf-8")).get("skills", [])
            section.append('<div class="skills">')
            for item in skills:
                if not isinstance(item, dict):
                    continue
                start, duration = item.get("video_start_seconds"), item.get("video_duration_seconds")
                if not isinstance(start, (int,float)) or not isinstance(duration,(int,float)):
                    continue
                if not math.isfinite(start) or not math.isfinite(duration) or start < 0 or duration <= 0:
                    continue
                title = item.get("name_vi") or item.get("skill_id") or "Kỹ năng"
                section.append(f'<button type="button" data-video="v-{school}" data-start="{start}" data-end="{start+duration}">{esc(title)}</button>')
                buttons += 1
            section.append("</div>")
        section.append("</section>")
        sections.append("".join(section))
    page = """<!doctype html><html lang="vi"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Tông Môn Bá Đạo — Xem kỹ năng</title>
<style>body{font:16px system-ui,sans-serif;background:#12151a;color:#f4f4f4;max-width:920px;margin:auto;padding:16px}a{color:#a8d7ff}section{border:1px solid #363b44;border-radius:12px;padding:14px;margin:16px 0}h1{font-size:24px}h2{font-size:20px;margin:0}p{line-height:1.4}video{width:100%;max-height:70vh;background:#08090a}.skills{display:flex;flex-wrap:wrap;gap:8px}button{font:inherit;color:inherit;background:#303743;border:1px solid #596270;border-radius:8px;padding:10px;text-align:left}</style>
<h1>Xem kỹ năng — Godot native</h1><p>Chọn môn phái, bấm video hoặc tên kỹ năng để xem đúng đoạn. Không cần tải ZIP hoặc mở trang code. Các video là bản ứng viên, chưa duyệt mỹ thuật.</p><p><a href="../">VFX tương tác</a> · <a href="../../play/">Game chính</a></p>"""
    page += f'<p>Source: <code>{esc(sha)}</code></p>' + "".join(sections)
    page += """<script>
document.querySelectorAll('button[data-video]').forEach(b=>b.addEventListener('click',()=>{
 const v=document.getElementById(b.dataset.video), start=Number(b.dataset.start), end=Number(b.dataset.end);
 document.querySelectorAll('video').forEach(o=>{if(o!==v)o.pause()});
 v.ontimeupdate=()=>{if(v.currentTime>=end){v.pause();v.ontimeupdate=null}};
 const play=()=>{v.currentTime=start;v.play().catch(()=>{});v.scrollIntoView({block:'nearest'})};
 if(v.readyState>=1)play();else{v.addEventListener('loadedmetadata',play,{once:true});v.load();}
}));
</script></html>"""
    (dest / "index.html").write_text(page, encoding="utf-8")
    print(f"NATIVE_VIDEO_REVIEW_BUILD videos={videos} skill_seek_buttons={buttons} owner=PENDING pve=HOLD")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, default=Path("godot"))
    parser.add_argument("--destination", type=Path, required=True)
    parser.add_argument("--sha", required=True)
    args = parser.parse_args()
    build(args.source, args.destination, args.sha)
