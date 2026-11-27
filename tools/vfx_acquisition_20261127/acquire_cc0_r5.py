"""R5 CC0 source acquisition, validation and inventory; no third-party code execution."""
import hashlib,json,subprocess,urllib.request,zipfile
from pathlib import Path
from PIL import Image,ImageDraw
ROOT=Path("outputs/external_vfx_r5")
PACKS=[
("slash","Everything_0.zip","weapon-slash-effect","Cethiel"),
("rpg","rpg_vfx_pack.7z","rpg-vfx-pack","System G6"),
("aura12","auras-001-002.7z","auras","Kutejnikov"),
("aura34","auras-003-004.7z","auras","Kutejnikov")]
def digest(p):
    with p.open("rb") as f:return hashlib.file_digest(f,"sha256").hexdigest()
def main():
    ROOT.mkdir(parents=True,exist_ok=True);report=[];seen={};preview=[]
    for name,filename,page,author in PACKS:
        row={"id":name,"author":author,"license":"CC0 source declaration","page":"https://opengameart.org/content/"+page,"url":"https://opengameart.org/sites/default/files/"+filename}
        a=ROOT/filename
        try:
            with urllib.request.urlopen(urllib.request.Request(row["url"],headers={"User-Agent":"TMB VFX"}),timeout=90) as src,a.open("wb") as out:
                n=0
                while chunk:=src.read(1024*1024):
                    n+=len(chunk)
                    if n>110*1024*1024:raise ValueError("download cap")
                    out.write(chunk)
            d=ROOT/"decoded"/name;d.mkdir(parents=True,exist_ok=True)
            if filename.endswith(".zip"):
                with zipfile.ZipFile(a) as z:
                    for m in z.infolist():
                        if m.is_dir() or not m.filename.lower().endswith((".png",".webp",".gif",".jpg",".jpeg",".tga")):continue
                        p=d/m.filename
                        if not p.resolve().is_relative_to(d.resolve()) or m.file_size>32*1024*1024:raise ValueError("unsafe member")
                        p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(z.read(m))
            else:
                listing=subprocess.check_output(["7z","l","-slt",str(a)],text=True)
                for line in listing.splitlines():
                    if line.startswith("Path = "):
                        s=line[7:].replace("\\","/")
                        if s.startswith("/") or ".." in s.split("/") or ":" in s:raise ValueError("unsafe path")
                subprocess.run(["7z","x","-y","-o"+str(d),str(a),"*.png","*.webp","*.gif","*.jpg","*.jpeg","*.tga","-r"],check=True,stdout=subprocess.DEVNULL)
            images=[]; rejected=[]
            for p in sorted(d.rglob("*")):
                if not p.is_file() or p.is_symlink() or p.suffix.lower() not in (".png",".webp",".gif",".jpg",".jpeg",".tga"):continue
                try:
                    with Image.open(p) as im:
                        if im.width*im.height>16777216:raise ValueError("pixel cap")
                        im.load();rgba=im.convert("RGBA");lo,hi=rgba.getchannel("A").getextrema()
                        sha=digest(p);images.append({"path":str(p.relative_to(d)),"sha256":sha,"size":list(im.size),"alpha":lo<255,"nonempty":hi>0,"duplicate_of":seen.get(sha)})
                        seen.setdefault(sha,name+"/"+str(p.relative_to(d)))
                        if len(preview)<80 and (name=="slash" or len(images)%10==1):
                            rgba.thumbnail((140,100));preview.append((name,p.name,rgba.copy()))
                except Exception as e:rejected.append({"path":str(p.relative_to(d)),"error":str(e)})
            if not images:raise ValueError("no decoded images")
            row.update(status="ACQUIRED_WITH_REJECTIONS" if rejected else "ACQUIRED",bytes=a.stat().st_size,sha256=digest(a),images=len(images),entries=images,rejected=rejected)
        except Exception as e:row.update(status="HOLD",error=str(e))
        report.append(row);print(json.dumps({k:v for k,v in row.items() if k!="entries"}),flush=True)
    (ROOT/"cc0_inventory.json").write_text(json.dumps(report,indent=2))
    if preview:
        s=Image.new("RGB",(960,140*((len(preview)+5)//6)),(29,35,42));draw=ImageDraw.Draw(s)
        for i,(pack,n,im) in enumerate(preview):
            x=i%6*160;y=i//6*140;s.paste(im,(x+(160-im.width)//2,y+2),im);draw.text((x+4,y+104),pack,fill="white");draw.text((x+4,y+119),n[:23],fill="white")
        s.save(ROOT/"contact_sheet.jpg",quality=90)
    if not any(r["status"].startswith("ACQUIRED") for r in report):raise SystemExit(1)
if __name__=="__main__":main()
