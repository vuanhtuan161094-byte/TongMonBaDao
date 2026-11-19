extends Node
## PERF-WEB-01: optional on-device telemetry, never gameplay or Save authority.
## Press F8 while playing the canonical Web/Windows Godot game to toggle.
## The panel is normally hidden and does not run a frame sampler until enabled.

const SAMPLE_LIMIT := 180
const SAMPLE_REFRESH_SECONDS := 0.5
var _enabled := false
var _hud: Panel
var _readout: Label
var _samples_ms: Array[float] = []
var _refresh_elapsed := 0.0

func _ready() -> void:
    _hud = Panel.new()
    _hud.name = "RuntimePerfNumbers"
    _hud.position = Vector2(989,86)
    _hud.size = Vector2(273,100)
    _hud.z_index = 180
    _hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var frame := StyleBoxFlat.new()
    frame.bg_color = Color(0.014,0.073,0.085,0.94)
    frame.border_color = Color(0.94,0.77,0.42,0.90)
    frame.set_border_width_all(1)
    frame.set_corner_radius_all(9)
    _hud.add_theme_stylebox_override("panel",frame)
    var label := Label.new()
    label.name = "RuntimePerfReadout"
    label.position = Vector2(12,6)
    label.size = Vector2(252,88)
    label.add_theme_font_size_override("font_size",13)
    label.add_theme_color_override("font_color",Color(0.97,0.94,0.84))
    label.text = "FPS: đo khi có khung hình\nP95: —    1% low: —\nNhấn F8 để đóng"
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _hud.add_child(label)
    _readout = label
    var host := get_parent() as Control
    if host != null:
        host.add_child(_hud)
    else:
        add_child(_hud)
    _hud.visible = false
    set_process(false)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey:
        var key := event as InputEventKey
        if key.pressed and not key.echo and key.keycode == KEY_F8:
            toggle()
            get_viewport().set_input_as_handled()

func toggle() -> void:
    _enabled = not _enabled
    _hud.visible = _enabled
    _samples_ms.clear()
    _refresh_elapsed = 0.0
    set_process(_enabled)
    if _enabled:
        _readout.text = "FPS: đang đo...\nP95: —    1% low: —\nF8: đóng"

func _process(delta: float) -> void:
    if not _enabled:
        return
    var elapsed_ms := maxf(0.01,delta * 1000.0)
    _samples_ms.append(elapsed_ms)
    if _samples_ms.size() > SAMPLE_LIMIT:
        _samples_ms.remove_at(0)
    _refresh_elapsed += delta
    if _refresh_elapsed < SAMPLE_REFRESH_SECONDS or _samples_ms.size() < 8:
        return
    _refresh_elapsed = 0.0
    var sorted := _samples_ms.duplicate()
    sorted.sort()
    var total_ms := 0.0
    for value in _samples_ms:
        total_ms += value
    var mean_ms := total_ms/maxf(1.0,float(_samples_ms.size()))
    var p95_index := clampi(ceili(float(sorted.size()) * 0.95) - 1,0,sorted.size()-1)
    var slow_count := maxi(1,ceili(float(sorted.size()) * 0.01))
    var slow_total := 0.0
    for index in range(sorted.size()-slow_count,sorted.size()):
        slow_total += sorted[index]
    var low_fps := 1000.0/maxf(0.01,slow_total/float(slow_count))
    _readout.text = ("FPS %.0f  |  1%% low %.0f\n"
        + "P95 %.1f ms  |  Frame %.1f ms\n"
        + "CPU %.1f ms  |  F8: đóng") % [
            1000.0/maxf(0.01,mean_ms),low_fps,
            sorted[p95_index],sorted[sorted.size()-1],
            Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0]
