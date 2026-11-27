"""Build transient Godot source library LAB; preserve original pixel/rect geometry."""
import json, shutil
from pathlib import Path
from PIL import Image
SRC=Path("outputs/external_vfx_acquisition")
LAB=Path("godot/labs/combat_lab/external_vfx_library_20261127")
OUT=LAB/"generated"
def main():
    OUT.mkdir(parents=True,exist_ok=True)
    inventory=json.loads((SRC/"inventory.json").read_text())
    entries=[]
    for r in inventory["records"]:
        if r["source"]!="flare":continue
        source=SRC/"flare"/r["image"]
        # Original packed atlas, no resizing or altered pixels.
        dest=OUT/(r["id"]+".png")
        shutil.copyfile(source,dest)
        selected=next((a for a in r["animations"] if a["frames"] and a.get("source_animation","").endswith("/"+r["id"]+".txt")),None)
        if selected is None: selected=next((a for a in r["animations"] if a["frames"]),None)
        if selected is None:continue
        direction=min(f["direction"] for f in selected["frames"])
        frames=sorted((f for f in selected["frames"] if f["direction"]==direction),key=lambda f:f["index"])
        if not frames:continue
        duration=selected.get("declared_duration","400ms")
        try:
            seconds=float(duration.removesuffix("ms"))/1000 if duration.endswith("ms") else float(duration)
        except ValueError:seconds=0.4
        fps=max(1,min(40,len(frames)/max(seconds,0.05)))
        # Native library preview only: packed rects and original offset retained;
        # source offsets are not silently translated into a TMB gameplay pivot.
        entries.append({"id":r["id"],"texture":"res://labs/combat_lab/external_vfx_library_20261127/generated/"+dest.name,"frames":frames,"fps":fps,"direction":direction,"source_animation":selected["source_animation"]})
    (OUT/"review.json").write_text(json.dumps(entries,indent=2))
    assert len(entries)>=30, len(entries)
    print("NATIVE_LIBRARY_READY",len(entries),"source clips")
if __name__=="__main__":main()
