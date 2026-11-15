extends SceneTree
## Reusable illustrative VFX-only scenario sampler for ALL schools.
## This measures CI/Xvfb wall-clock FRAME PACING, NOT a physical Android GPU.
## Example: --path godot --script res://tests/labs/combat_lab/vfx_shared_load_benchmark.gd
## To use other schools: pass -- --scene=res://labs/combat_lab/.../skill.tscn
const DEFAULT_SCENE := "res://labs/combat_lab/fist05/dia_mach_lien_chan.tscn"
const COUNTS := [1, 6, 12, 30]
var test_path := DEFAULT_SCENE
func _initialize() -> void:
    for arg in OS.get_cmdline_user_args():
        if arg.begins_with("--scene="):
            test_path=arg.trim_prefix("--scene=")
    call_deferred("_run")
func _run() -> void:
    var scene: PackedScene = load(test_path)
    if scene == null:
        push_error("VFX_LOAD_ERROR invalid scene "+test_path)
        quit(2)
        return
    print("VFX_LOAD_LAB_SCENE=",test_path)
    for amount in COUNTS:
        var nodes: Array[Node] = []
        for i in range(amount):
            var node: Control = scene.instantiate() as Control
            node.set("vfx_only_benchmark", true)
            node.position = Vector2(float(i%6)*184.0-65.0, float(i/6)*122.0-130.0)
            node.scale = Vector2(.34,.34)
            root.add_child(node)
            node.set("elapsed", 1.09 + float(i%6)*.028)
            nodes.append(node)
        # 15 warm-up frames and 90 actual VFX-only native frames.
        for i in range(15):
            await process_frame
        var start := Time.get_ticks_usec()
        var process_total := 0.0
        for i in range(90):
            await process_frame
            process_total += Performance.get_monitor(Performance.TIME_PROCESS)
        var delta_us := Time.get_ticks_usec()-start
        var mean_wall_ms := float(delta_us) / 90000.0
        var mean_script_ms := process_total/90.0*1000.0
        print("VFX_LOAD_SCENARIO count=",amount," wall_ms=",snappedf(mean_wall_ms,.001),
            " process_ms=",snappedf(mean_script_ms,.001),
            " approx_fps=",snappedf(1000.0/maxf(.0001,mean_wall_ms),.1),
            " environment=ubuntu_xvfb_not_android")
        for item in nodes:
            item.queue_free()
        await process_frame
    print("VFX_LOAD_BENCH_RESULT=PASS cases=1,6,12,30 source_render=true android_fps_unverified=true")
    quit(0)
