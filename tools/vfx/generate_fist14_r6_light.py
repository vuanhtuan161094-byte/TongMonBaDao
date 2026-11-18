"""FIST14 R6 original luminous-energy RGBA art study, reproducible.
LAB only; source art QA / owner approval must be independent of technical tests.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
import hashlib, json, math

ROOT = Path(__file__).resolve().parents[2]
BASE = ROOT / "godot/labs/combat_lab/fist14/r6_luminous"
SRC = BASE / "source"
ASSET = BASE / "assets"
SRC.mkdir(parents=True, exist_ok=True)
ASSET.mkdir(parents=True, exist_ok=True)
W, H = 512, 384

# First-party authored Bezier geometry. Each phase changes its actual energy
# contour and internal knuckle-pressure anatomy, not a transformed old PNG.
POSES = {
"charge": [
(91,120,156,64,226,104,289,181,5),(97,265,177,311,255,274,307,204,6),
(199,60,245,116,205,159,292,191,3),(167,315,260,240,208,222,296,193,4),
(288,144,315,169,315,191,286,213,5)],
"compress": [
(151,118,207,96,259,124,298,172,7),(153,248,217,277,266,242,309,204,7),
(254,157,284,122,346,141,360,159,5),(276,171,301,147,358,162,367,176,4),
(276,184,313,159,356,185,365,195,4),(274,203,309,178,346,201,360,214,4),
(350,217,315,243,296,236,280,217,5)],
"release": [
(44,230,158,203,230,158,352,166,10),(67,263,199,261,250,225,358,220,7),
(102,173,224,120,294,117,351,136,4),(291,156,332,112,382,119,399,142,6),
(320,171,357,132,395,146,413,160,5),(321,186,364,154,402,168,409,187,5),
(317,204,353,179,389,191,407,209,5),(393,221,370,249,336,230,315,213,7)],
"peak": [
(56,241,168,206,233,154,338,149,12),(72,284,183,267,256,243,341,230,8),
(92,167,219,111,277,114,358,128,6),(306,161,353,111,406,124,426,143,7),
(327,175,379,127,419,149,436,167,6),(335,194,383,150,424,172,439,193,6),
(333,210,374,177,424,197,429,218,6),(423,230,381,260,359,233,332,215,8),
(196,231,273,191,337,198,386,183,9)],
"impact": [
(225,196,258,154,286,113,298,47,9),(234,196,314,170,366,124,452,113,7),
(242,202,297,221,369,252,442,301,7),(227,211,221,266,194,309,161,355,7),
(216,196,164,153,116,149,50,138,6),(235,198,279,180,323,180,390,167,6),
(239,207,288,239,313,276,322,328,5),(215,204,173,232,139,253,82,253,5)],
"recoil": [
(84,157,143,146,168,170,209,163,4),(109,244,162,215,199,226,243,196,4),
(225,145,277,120,315,144,342,139,3),(237,214,289,202,311,213,343,200,3),
(291,238,326,253,351,250,377,276,2)],
"mark": [
(225,120,211,152,202,174,186,201,5),(266,114,254,149,235,183,223,217,6),
(311,136,290,159,279,196,257,236,5)]
}

def bezier(a,b,c,d,n=48):
    points=[]
    for j in range(n+1):
        t=j/n
        u=1-t
        points.append((round(u*u*u*a[0]+3*u*u*t*b[0]+3*u*t*t*c[0]+t*t*t*d[0]),
                       round(u*u*u*a[1]+3*u*u*t*b[1]+3*u*t*t*c[1]+t*t*t*d[1])))
    return points

def stroke(layer,seg,mult,color):
    coords=list(zip(seg[:8:2],seg[1:8:2]))
    points=bezier(*coords)
    d=ImageDraw.Draw(layer)
    for j in range(len(points)-1):
        t=j/(len(points)-1)
        width=max(1,round(seg[8]*mult*(0.25+0.83*math.sin(math.pi*(0.05+0.90*t))**0.8)))
        d.line([points[j],points[j+1]],fill=color,width=width,joint="curve")

def paint(name,curves):
    halo=Image.new("RGBA",(W,H))
    medium=Image.new("RGBA",(W,H))
    body=Image.new("RGBA",(W,H))
    core=Image.new("RGBA",(W,H))
    if name in ("release","peak"):
        # Translucent mass under sharply readable energy knuckle ridges.
        poly=(
        [(61,230),(145,202),(224,157),(293,143),(347,139),(377,135),
         (389,145),(387,154),(401,163),(399,178),(415,185),(413,199),
         (407,214),(381,237),(328,229),(243,230),(130,262),(63,251)]
         if name=="release" else
        [(57,233),(135,197),(237,148),(297,133),(344,128),(385,126),
         (402,137),(406,146),(399,155),(418,159),(428,170),(416,183),
         (435,190),(438,204),(426,216),(414,227),(382,246),(337,243),
         (253,241),(132,268),(71,267)])
        ImageDraw.Draw(body).polygon(poly,fill=(232,58,117,118))
        # A luminous closed four-knuckle pressure crest, not a solid glove.
        crest=Image.new("RGBA",(W,H))
        dc=ImageDraw.Draw(crest)
        cusp=[(305,176),(328,147),(355,134),(377,137),(392,146),
              (391,159),(405,157),(420,168),(417,183),(428,191),
              (421,205),(414,219),(392,231),(371,228),(350,216),(325,207)]
        dc.polygon(cusp,fill=(252,94,127,112))
        halo.alpha_composite(crest.filter(ImageFilter.GaussianBlur(13)))
        body.alpha_composite(crest)
        # Separate hot knuckle edges. Transparent crimson mass stays visible.
        dk=ImageDraw.Draw(core)
        for arc in [((362,133),(389,128),(403,140),(399,153)),
                    ((383,157),(402,149),(420,162),(413,179)),
                    ((387,184),(413,176),(426,191),(414,201)),
                    ((386,209),(409,205),(419,218),(396,227))]:
            dk.line(bezier(*arc),fill=(255,246,232,239),width=3)
        halo.alpha_composite(body.filter(ImageFilter.GaussianBlur(12)))
    for i,seg in enumerate(curves):
        color=((245,58,107),(222,36,92),(255,103,142))[i%3]
        stroke(halo,seg,5.0,(*color,67))
        stroke(medium,seg,2.1,(*color,120))
        stroke(body,seg,1.22,(250,78,127,175))
        if i%3!=2:
            stroke(core,seg,0.35,(255,231,221,221))
    if name in ("charge","compress"):
        d=ImageDraw.Draw(core)
        for radius,opacity in ((15,24),(8,66),(3,212)):
            d.ellipse((297-radius,192-radius,297+radius,192+radius),
                      fill=(255,244,225,opacity))
    if name=="impact":
        d=ImageDraw.Draw(core)
        for r,alpha in ((30,50),(18,115),(10,205),(5,255)):
            d.ellipse((231-r,200-r,231+r,200+r),fill=(255,249,237,alpha))
    out=Image.new("RGBA",(W,H))
    for layer in (halo.filter(ImageFilter.GaussianBlur(10)),
                  medium.filter(ImageFilter.GaussianBlur(3)),body,core):
        out.alpha_composite(layer)
    return out

manifest={"revision":"FIST14_R6_LIGHT_ENERGY_CANDIDATE",
          "authoring":"original first-party code-painted raster paths; ART_NOT_APPROVED",
          "sources":[]}
images={}
for name,curves in POSES.items():
    im=paint(name,curves)
    dest=SRC/("f14_r6_"+name+".png")
    im.save(dest,optimize=True)
    images[name]=im
    manifest["sources"].append({"path":str(dest.relative_to(ROOT)),
      "size":[W,H],"sha256":hashlib.sha256(dest.read_bytes()).hexdigest()})
for filename,names,cols in (
    ("f14_r6_attack_pose_atlas.png",["charge","compress","release","peak"],2),
    ("f14_r6_contact_recoil_atlas.png",["impact","recoil"],2),
    ("f14_r6_mark_atlas.png",["mark"],1)):
    rows=(len(names)+cols-1)//cols
    atlas=Image.new("RGBA",(W*cols,H*rows))
    for j,name in enumerate(names):
        atlas.alpha_composite(images[name],((j%cols)*W,(j//cols)*H))
    atlas.save(ASSET/filename,optimize=True)
(ASSET/"source_manifest.json").write_text(
    json.dumps(manifest,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
print("FIST14_R6_SOURCE_BAKE_COMPLETE pose_count=7 all_rgba=true owner_art=PENDING")
