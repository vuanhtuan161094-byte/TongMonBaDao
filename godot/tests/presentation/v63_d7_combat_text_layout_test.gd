extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error("V63_D7_COMBAT_TEXT_LAYOUT_FAIL: "+message)
    quit(1)

func _run() -> void:
    var presenter := B3CareCombatV5Presenter.new()
    presenter.stage_rect = Rect2(Vector2.ZERO,Vector2(1280.0,720.0))
    var hud: Array[Dictionary] = []
    for index in range(12):
        hud.append({
            "kind":"hp",
            "rect":Rect2(Vector2(610.0,340.0),Vector2(56.0,7.0)),
            "ratio":0.75
        })
    hud.append({
        "kind":"name",
        "rect":Rect2(Vector2(565.0,316.0),Vector2(150.0,20.0)),
        "text":"Selected disciple",
        "selected":true
    })
    hud.append({
        "kind":"status",
        "rect":Rect2(Vector2(586.0,380.0),Vector2(48.0,19.0)),
        "text":"Choáng"
    })
    var positioned_hud := presenter.layout_hp_overlays(hud)
    if positioned_hud.size() != hud.size():
        _fail("HUD collision layout changed overlay count")
        return
    for index in range(positioned_hud.size()):
        var entry: Dictionary = positioned_hud[index]
        if str(entry.get("kind","")) == "hp" and not bool(entry.get("visible",false)):
            _fail("essential HP bar was hidden under a clustered 6v5-style fixture")
            return
        if not bool(entry.get("visible",false)):
            continue
        var rect: Rect2 = entry["rect"]
        if not Rect2(Vector2.ZERO,Vector2(1280.0,720.0)).encloses(rect):
            _fail("HUD overlay escaped the 1280x720 viewport bounds")
            return
        for previous_index in range(index):
            var previous: Dictionary = positioned_hud[previous_index]
            if not bool(previous.get("visible",false)):
                continue
            if rect.grow(3.0).intersects((previous["rect"] as Rect2).grow(3.0)):
                _fail("HP/name/status collision pass left two visible HUD boxes overlapping")
                return

    var popups: Array[Dictionary] = []
    for index in range(14):
        popups.append({
            "event_id":100+index,
            "actor_id":"actor_%02d" % (index%6),
            "category":"damage",
            "text":"1234",
            "rect":Rect2(Vector2(600.0,330.0),Vector2(64.0,22.0))
        })
    var positioned_text := presenter.layout_combat_text_popups(popups,positioned_hud)
    if positioned_text.size() != popups.size():
        _fail("combat text layout changed the receipt display count")
        return
    for index in range(positioned_text.size()):
        var item: Dictionary = positioned_text[index]
        if not bool(item.get("visible",false)):
            _fail("transient combat text was hidden despite available viewport lanes")
            return
        if str(item.get("text","")) != "1234" or int(item.get("event_id",-1)) != 100+index:
            _fail("combat text layout changed its exact event identity or displayed value")
            return
        var rect: Rect2 = item["rect"]
        if not Rect2(Vector2.ZERO,Vector2(1280.0,720.0)).encloses(rect):
            _fail("combat text escaped the 1280x720 viewport bounds")
            return
        for overlay in positioned_hud:
            if not bool(overlay.get("visible",false)):
                continue
            if rect.grow(3.0).intersects((overlay["rect"] as Rect2).grow(3.0)):
                _fail("combat text overlaps an HP/name/status box")
                return
        for previous_index in range(index):
            var previous: Dictionary = positioned_text[previous_index]
            if rect.grow(3.0).intersects((previous["rect"] as Rect2).grow(3.0)):
                _fail("simultaneous damage labels overlap")
                return

    var reversed_popups: Array[Dictionary] = []
    for index in range(popups.size()-1,-1,-1):
        reversed_popups.append(popups[index].duplicate())
    var reordered := presenter.layout_combat_text_popups(reversed_popups,positioned_hud)
    var by_event: Dictionary = {}
    for item in positioned_text:
        by_event[int(item["event_id"])] = item["rect"]
    for item in reordered:
        if not by_event.has(int(item["event_id"])) or by_event[int(item["event_id"])] != item["rect"]:
            _fail("combat text placement depends on input container order")
            return

    presenter.free()
    print("V63_D7_COMBAT_TEXT_LAYOUT_PASS: bounded deterministic 6v5 HUD and damage text; values/events preserved")
    quit(0)
