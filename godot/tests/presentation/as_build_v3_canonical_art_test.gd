extends SceneTree
## AS-BUILD-V3: no hidden active state; test exact 12 paths + canonical work flags.
const V3 = preload("res://src/presentation/uiux/sect_building_art_variant_v3.gd")

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var paths := V3.all_paths()
    assert(paths.size() == 12,"Three facilities x two views x two states = 12")
    var known: Dictionary = {}
    for p in paths:
        assert(not known.has(p),"Duplicate canonical art path: "+p)
        assert(str(p).begins_with("res://art/reimagined_source_a_v3/"),"Unexpected art root")
        known[p] = true
    var bs := BuildingSystem.new()
    var forest := bs.create_building(BuildingSystem.TYPE_LINH_FOREST)
    var field := bs.create_building(BuildingSystem.TYPE_SPIRIT_FIELD)
    var alchemy := bs.create_building(BuildingSystem.TYPE_ALCHEMY_HALL)
    assert(forest != null and field != null and alchemy != null,"Missing canonical producer roles")
    assert(not V3.is_canonical_working(forest,4),"No forest timer cannot glow")
    assert(not V3.is_canonical_working(field,4),"Empty plot cannot glow")
    assert(not V3.is_canonical_working(alchemy,4),"No alchemy job cannot glow")
    forest.production_state = {"economy_a_jobs":[{"started_tick":2,"finish_tick":8}]}
    field.production_state = {"plots":[{"status":"growing","started_tick":2,"finish_tick":8}]}
    alchemy.production_state = {"jobs":[{"started_tick":2,"finish_tick":8}]}
    for site in [forest,field,alchemy]:
        assert(V3.is_canonical_working(site,4),"Real in-flight work must activate art")
        assert(not V3.is_canonical_working(site,9),"Finished job must not appear working")
    assert(V3.sprite_path(BuildingSystem.TYPE_LINH_FOREST,&"B",true) == "res://art/reimagined_source_a_v3/linh_lam_B_active.png")
    assert(V3.sprite_path(BuildingSystem.TYPE_ALCHEMY_HALL,&"A",false) == "res://art/reimagined_source_a_v3/luyen_dan_A_idle.png")
    assert(V3.sprite_path(&"residence",&"A",false).is_empty(),"Never overwrite verified Source A house")
    var imported := 0
    var absent: Array[String] = []
    for p in paths:
        if not ResourceLoader.exists(p,"Texture2D"):
            absent.append(p)
            continue
        var texture := ResourceLoader.load(p) as Texture2D
        assert(texture != null and texture.get_width() >= 100 and texture.get_height() >= 100,
            "Invalid sprite import: "+p)
        imported += 1
    print("AS_BUILD_V3_CODE_AND_CANONICAL_JOB_LOGIC PASS total_variants=12 imported=%d missing=%d" % [imported,absent.size()])
    assert(absent.is_empty(),"AS-BUILD-V3 missing %d canonical sprite PNG(s): %s" % [absent.size(),str(absent)])
    assert(imported == 12,"AS-BUILD-V3 must import all 12 PNGs")
    print("AS_BUILD_V3_BINARY_IMPORT PASS 12/12; native GUI/physical visual signoff pending")
    quit(0)
