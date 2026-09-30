extends Control

var scheduler: SimulationScheduler
var selected_id: StringName = &"lam_thanh_vu"

var summary_label: Label
var inspector_label: Label
var disciple_buttons: Dictionary = {}
var tick_accumulator := 0.0

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    scheduler = SimulationScheduler.new(P0Factory.create_state(1337))
    _build_debug_ui()
    _refresh_ui()

func _process(delta: float) -> void:
    tick_accumulator += delta
    if tick_accumulator >= 0.18:
        tick_accumulator = 0.0
        scheduler.step()
        _refresh_ui()

func _build_debug_ui() -> void:
    var background := ColorRect.new()
    background.color = Color(0.055, 0.07, 0.065, 1.0)
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(background)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 14)
    margin.add_theme_constant_override("margin_right", 14)
    margin.add_theme_constant_override("margin_top", 18)
    margin.add_theme_constant_override("margin_bottom", 18)
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(margin)

    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 8)
    margin.add_child(column)

    var title := Label.new()
    title.text = "TÔNG MÔN TYCOON — P0"
    title.add_theme_font_size_override("font_size", 22)
    column.add_child(title)

    summary_label = Label.new()
    summary_label.add_theme_font_size_override("font_size", 13)
    column.add_child(summary_label)

    var divider := HSeparator.new()
    column.add_child(divider)

    for disciple in scheduler.state.disciples.values():
        var button := Button.new()
        button.text = disciple.display_name
        button.alignment = HORIZONTAL_ALIGNMENT_LEFT
        button.custom_minimum_size = Vector2(0, 44)
        button.pressed.connect(_select_disciple.bind(disciple.id))
        disciple_buttons[disciple.id] = button
        column.add_child(button)

    var inspector_title := Label.new()
    inspector_title.text = "INSPECTOR"
    inspector_title.add_theme_font_size_override("font_size", 17)
    column.add_child(inspector_title)

    inspector_label = Label.new()
    inspector_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    inspector_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
    inspector_label.add_theme_font_size_override("font_size", 13)
    column.add_child(inspector_label)

func _select_disciple(id: StringName) -> void:
    selected_id = id
    _refresh_ui()

func _refresh_ui() -> void:
    var state := scheduler.state
    summary_label.text = "Tick %d  |  Tông khố %d  |  Tổng tiền %d" % [
        state.tick,
        state.sect.treasury,
        state.total_money()
    ]

    for disciple in state.disciples.values():
        var button: Button = disciple_buttons.get(disciple.id)
        if button:
            button.text = "%s  |  %-11s  HP %3d  ST %3d  💰 %d" % [
                disciple.display_name,
                str(disciple.current_action),
                int(round(disciple.hp)),
                int(round(disciple.stamina)),
                disciple.wallet
            ]

    var selected: DiscipleState = state.disciples.get(selected_id)
    if selected == null:
        inspector_label.text = "No disciple selected."
        return

    var decision: Dictionary = selected.last_decision
    var scores: Dictionary = decision.get("scores", {})
    var region_name := "Tông Môn"
    if selected.region_id != &"sect" and state.regions.has(selected.region_id):
        region_name = state.regions[selected.region_id].display_name

    inspector_label.text = (
        "%s\n"
        + "Action: %s\n"
        + "Region: %s\n"
        + "HP: %.0f/%.0f  |  Stamina: %.0f\n"
        + "Wallet: %d  |  Inventory: %d\n"
        + "Risk %.2f  |  Retreat <= %.0f%% HP\n\n"
        + "Scores\n"
        + "Hunt %.1f  Heal %.1f  Rest %.1f\n"
        + "Sell %.1f  Buy %.1f\n\n"
        + "Reason\n%s\n\n"
        + "Metrics\nCombats %d  Wins %d  Retreats %d\n"
        + "Danger visits %d  Safe visits %d"
    ) % [
        selected.display_name,
        str(selected.current_action),
        region_name,
        selected.hp,
        selected.max_hp,
        selected.stamina,
        selected.wallet,
        selected.inventory_count(),
        selected.risk_bias,
        selected.retreat_hp_ratio() * 100.0,
        float(scores.get("HUNT", 0.0)),
        float(scores.get("HEAL", 0.0)),
        float(scores.get("REST", 0.0)),
        float(scores.get("SELL", 0.0)),
        float(scores.get("BUY", 0.0)),
        str(decision.get("reason", "Waiting for first evaluation.")),
        int(selected.metrics.get("combats", 0)),
        int(selected.metrics.get("wins", 0)),
        int(selected.metrics.get("retreats", 0)),
        int(selected.metrics.get("danger_visits", 0)),
        int(selected.metrics.get("safe_visits", 0))
    ]
