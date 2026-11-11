extends SceneTree
## AS-BUILD-01: imported original-code-art alchemy building, no fake Source A intake.
const ART := "res://art/reimagined_source_a_v1/alchemy_hall_3q_v1.svg"
func _init() -> void:
    call_deferred("_run")
func _run() -> void:
    var world := SectIsometricWorldV1.new()
    var atlas := world.MAP_D2_CANDIDATE_SITES
    assert(not atlas.has("alchemy_hall"),"Rejected asset cannot be loaded in the live game")
    assert(world.REIMAGINED_REVIEW_ONLY_SITES.get("alchemy_hall","") == ART,"Candidate must remain traceable")
    assert(not world.HOUSE_TEXTURES.has("alchemy_hall"),"Recreation must not masquerade as verified Source A")
    var texture := load(ART) as Texture2D
    assert(texture != null,"Godot failed to import original generated vector")
    assert(texture.get_width() == 320 and texture.get_height() == 240,"Imported authored building dimensions unexpected")
    var source := SectMap25SourceArt.new()
    assert(source.texture_for("pv01_assets/main_hall/510052.png") != texture,"Source A original must remain distinct")
    world.free()
    print("AS_BUILD01 STAGED_ONLY_IMPORT PASS; map placement VISUAL_REJECTED; original Source A directions=ONE")
    quit(0)
