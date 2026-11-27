extends Node2D
const FX = preload("res://src/presentation/p3/pve_factory_sprite_v1.gd")
const CURSOR = preload("res://src/presentation/p3/pve_jx_sword_vfx_adapter_v1.gd")
const ASCHAR = preload("res://src/presentation/p3/pve_aschar_frame_renderer_v1.gd")
const MONSTERS = preload("res://src/presentation/p3/combat_v5_source_a_atlas.gd")
var monsters = MONSTERS.new()
var ids: Array=[]
var entries: Dictionary={}
var index := -1
var elapsed := 0.0
var total := 0.0
var battle: MapBattleV2
var fx=FX.new()
var cursor=CURSOR.new()
var report: Array=[]
var released:=false
var accepted:=false
var cast_ok:=false
var actor_ok:=false
var done:=false
var skill:=""
var school:=""
var font: Font=ThemeDB.fallback_font
func _actor(id: String,side: String,position: Vector2) -> Dictionary:
    var resistances: Dictionary = {}
    for element in CombatStatsV2.ELEMENTS:
        resistances[element]=0.0
    return {"id":id,"side":side,"role":"healer","position":position,"hp":800.0,"max_hp":2000.0,"range":2.0,"move_speed":2.0,"tier":"normal","race_id":"yeu_thu","stats":{"attack":40.0,"defense":0.0,"damage_reduction":0.0,"crit_chance":0.0,"crit_damage":1.5,"crit_resistance":0.0,"defense_penetration":0.0,"lifesteal":0.0,"lifesteal_reduction":0.0},"resistances":resistances,"status_effects":{"slow":{"until":20.0,"movement_factor":0.7}},"context_sources":[],"v63_combat_enabled":true,"v63_palm_combat_enabled":true,"v63_skill_ready":{},"v63_skill_loadout":[],"v63_passive_ids":[],"v63_combat_clock":-1.0,"next_skill":0.0}

func _ready() -> void:
    ProjectSettings.set_setting(FX.EXTERNAL_PREVIEW_SETTING,true)
    var raw: Variant=JSON.parse_string(FileAccess.get_file_as_string(FX.EXTERNAL_INDEX))
    if not raw is Dictionary:
        get_tree().quit(1)
        return
    entries=raw.get("bindings",{})
    ids=entries.keys()
    ids.sort()
    _next()
func _next() -> void:
    if index>=0 and index<ids.size():
        report.append({"skill_id":skill,"real_cast":cast_ok,"real_visual_receipt":accepted,"actor_draw_ok":actor_ok,"synthetic_events":0})
    index+=1
    if index>=ids.size():
        done=true
        var args:=OS.get_cmdline_user_args()
        if not args.is_empty():
            var file:=FileAccess.open(args[0],FileAccess.WRITE)
            if file!=null:file.store_string(JSON.stringify(report,"  "))
        print("EXTERNAL_COMBAT_CAPTURE ",JSON.stringify(report))
        get_tree().quit()
        return
    elapsed=0.0;released=false;accepted=false;actor_ok=false
    skill=str(ids[index]);school=str(entries[skill]["school"])
    var definition:=V63HumanSkillCombatSystem.skill_definition(skill)
    battle=MapBattleV2.new(761+index)
    battle.encounter_id="external_movie_"+str(index)
    battle.active=true
    battle.outcome="fighting"
    var caster:=_actor("caster","disciple",Vector2(2,2))
    var enemy:=_actor("enemy","monster",Vector2(5,2))
    var ally:=_actor("ally","disciple",Vector2(3,2))
    caster["party_id"]="test";ally["party_id"]="test"
    caster["v63_"+school+"_combat_enabled"]=true
    caster["v63_combat_branch_id"]=str(definition.get("branch",""))
    caster["v63_skill_loadout"]=[skill]
    caster["v63_combat_lineage"]="base"
    battle.actors["caster"]=caster;battle.actors["ally"]=ally;battle.actors["enemy"]=enemy
    fx=FX.new();cursor=CURSOR.new()
    fx.observe(cursor.observe_snapshot(battle),battle)
    cast_ok=V63HumanSkillCombatSystem.try_cast(battle,caster,enemy,false)
    fx.observe(cursor.observe_snapshot(battle),battle)
func _process(delta: float) -> void:
    if done or battle==null:return
    elapsed+=delta;total+=delta
    var enemy: Dictionary=battle.actors["enemy"]
    enemy["position"]=Vector2(5.0+0.4*sin(elapsed*2.0),2.0+0.2*sin(elapsed))
    if not released and elapsed>=0.7:
        released=true
        if cast_ok:
            var caster: Dictionary=battle.actors["caster"]
            battle.now=float(caster.get("v63_pending_cast",{}).get("ready",0.0))
            battle._release_casts()
            var snapshot:=battle.events.duplicate(true)
            fx.observe(cursor.observe_snapshot(battle),battle)
            accepted=not fx._cues.is_empty() and battle.events==snapshot
    fx.advance(delta)
    queue_redraw()
    if elapsed>=2.4:_next()
func _project(p: Vector2) -> Vector2:
    return Vector2(220+p.x*112,382+p.y*42)
func _draw() -> void:
    draw_rect(Rect2(0,0,1280,720),Color("#1b2829"))
    draw_rect(Rect2(24,108,1232,500),Color("#44554b") if index%2==0 else Color("#85958a"))
    if battle==null or done:return
    var positions: Dictionary={}
    for id in ["caster","ally","enemy"]:
        var a: Dictionary=battle.actors[id]
        var world: Vector2=a["position"]
        positions[id]=world
        var foot:=_project(world)
        if id=="enemy":
            monsters.draw_actor(self,"monster_1113031_1","walk",foot,Vector2.LEFT,elapsed,1.0)
        else:
            var action: String="cast" if id=="caster" and not released else "idle"
            var ok: bool=ASCHAR.draw_actor(self,school,"male",action,foot,Vector2.RIGHT,elapsed,ASCHAR.game_view_scale(1.0),0.7,{})
            actor_ok=actor_ok or ok
        var health:=clampf(float(a["hp"])/float(a["max_hp"]),0,1)
        draw_rect(Rect2(foot+Vector2(-27,-104),Vector2(54,4)),Color("#24302e"))
        draw_rect(Rect2(foot+Vector2(-27,-104),Vector2(54*health,4)),Color("#91da81"))
    fx.draw_on(self,positions,_project)
    draw_string(font,Vector2(32,38),"TMB / VFX AUXILIARY COMBAT REVIEW",HORIZONTAL_ALIGNMENT_LEFT,-1,26,Color.WHITE)
    draw_string(font,Vector2(32,72),skill,HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("#c2d2c8"))
    draw_string(font,Vector2(32,656),"REAL MAPBATTLE FIXTURE | %d/%d | cast %s | receipt %s | owner pending" % [index+1,ids.size(),str(cast_ok),str(accepted)],HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color.WHITE)
    draw_string(font,Vector2(32,684),"Source: FLARE contributors / CC BY-SA 3.0; no simulated receipts; preview only",HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("#c2d2c8"))
