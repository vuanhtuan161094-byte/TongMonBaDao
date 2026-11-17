extends SceneTree
const CELL := Vector2i(400,440)
const TARGET := Vector2i(360,420)
const BASELINE := 430
func _initialize() -> void:
    var atlas_img := Image.create(CELL.x*4,CELL.y,false,Image.FORMAT_RGBA8)
    var files := ["AS49_walk_front_f00_left_contact.png","AS49_walk_front_f01_passing.png","AS49_walk_front_f02_right_contact.png","AS49_walk_front_f03_passing.png"]
    var frames_meta := []
    var unique := {}
    for i in range(files.size()):
        var rel: String = "res://assets/frames/AS49/walk_front/"+str(files[i])
        var abs := ProjectSettings.globalize_path(rel)
        var src := Image.load_from_file(abs)
        if src == null: push_error("SOURCE_LOAD_FAIL="+rel); quit(2); return
        var bounds := src.get_used_rect()
        if bounds.size.x == 0 or bounds.size.y == 0: push_error("EMPTY_ALPHA="+rel); quit(3); return
        var crop := src.get_region(bounds)
        var scale_factor: float = minf(float(TARGET.x)/crop.get_width(),float(TARGET.y)/crop.get_height())
        var size := Vector2i(maxi(1,int(round(crop.get_width()*scale_factor))),maxi(1,int(round(crop.get_height()*scale_factor))))
        crop.resize(size.x,size.y,Image.INTERPOLATE_LANCZOS)
        var cel := Image.create(CELL.x,CELL.y,false,Image.FORMAT_RGBA8)
        cel.blit_rect(crop,Rect2i(Vector2i.ZERO,size),Vector2i((CELL.x-size.x)/2,BASELINE-size.y))
        var out_rel := "res://assets/frames/AS49/walk_front_registered/walk_front_%02d.png" % i
        var out_abs := ProjectSettings.globalize_path(out_rel)
        var save_err := cel.save_png(out_abs)
        if save_err != OK: push_error("FRAME_SAVE_FAIL="+str(save_err)); quit(4); return
        atlas_img.blit_rect(cel,Rect2i(Vector2i.ZERO,CELL),Vector2i(i*CELL.x,0))
        var unique_hash := sha256(cel.get_data()); unique[unique_hash]=true
        frames_meta.append({"source":rel.replace("res://",""),"source_sha256":sha256(FileAccess.get_file_as_bytes(abs)),"alpha_bounds":{ "x":bounds.position.x,"y":bounds.position.y,"w":bounds.size.x,"h":bounds.size.y },"registered":out_rel.replace("res://",""),"registered_sha256":unique_hash,"pivot_y":BASELINE,"estimated_not_pose_locked":true})
    if unique.size()!=4: push_error("DUPLICATE_FRAME"); quit(5); return
    var atlas_rel="res://assets/atlases/AS49_walk_front_atlas.png"
    var atlas_abs=ProjectSettings.globalize_path(atlas_rel)
    var err=atlas_img.save_png(atlas_abs)
    if err!=OK: push_error("ATLAS_SAVE_FAIL="+str(err));quit(6);return
    var mf={"schema":"tmb.aschar.v9.batch1.candidate.v1","identity":"AS-CHAR-49 Kiếm Tu Nữ","candidate_status":"OWNER_ART_APPROVAL_PENDING","body_mode":"whole-body PNG cels; no rig/skeleton/body split","clip":"Walk_Front","fps":8.0,"loop":true,"frame_count":4,"canvas":CELL,"foot_baseline_y":BASELINE,"weapon_overlay":"not embedded; separate asset and grip calibration pending","atlas":atlas_rel.replace("res://",""),"atlas_sha256":sha256(atlas_img.get_data()),"frames":frames_meta,"prompt_provenance":"AS49_V9_WALK_PROMPTS.md"}
    var f=FileAccess.open("res://meta/AS49_V9_WALK_MANIFEST.json",FileAccess.WRITE)
    f.store_string(JSON.stringify(mf,"  ")+"\n");f.close()
    print("AS49_WALK_ATLAS=PASS frames=4 unique=4 baseline=430 owner_art_pending")
    quit(0)
func sha256(bytes:PackedByteArray)->String:
    var h=HashingContext.new();h.start(HashingContext.HASH_SHA256);h.update(bytes);return h.finish().hex_encode()

