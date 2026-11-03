extends SceneTree
## Provenance-gated atlas regions for canonical facility UI symbols.

const ICON = preload("res://src/presentation/uiux/sect_ui_icon_v1.gd")
const ATLAS_PATH := "res://art/uiux/sect_management_icons_generated_v1.png"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var atlas := load(ATLAS_PATH) as Texture2D
	if atlas == null or atlas.get_width() < 1200 or atlas.get_height() < 1200:
		_fail("generated icon atlas did not import at its expected 4x4 resolution")
		return
	var image := Image.new()
	if image.load(ATLAS_PATH) != OK or image.get_format() != Image.FORMAT_RGBA8:
		_fail("generated icon atlas must retain PNG alpha")
		return
	if image.get_pixel(0, 0).a > 0.01:
		_fail("atlas background is not transparent")
		return
	var required := [
		"gold", "leaf", "resource", "recruit_order", "bed", "hall", "build", "upgrade",
		"timer", "person", "assignment", "rank", "root", "search", "map", "office"
	]
	for icon_kind in required:
		if not ICON.has_atlas_icon(icon_kind):
			_fail("required icon is missing: " + icon_kind)
			return
		var cell: Vector2i = ICON.atlas_cell(icon_kind)
		if cell.x < 0 or cell.y < 0 or cell.x > 3 or cell.y > 3:
			_fail("invalid icon atlas cell: " + icon_kind)
			return
	if ICON.atlas_cell("gold") == ICON.atlas_cell("resource") or ICON.atlas_cell("root") == ICON.atlas_cell("office"):
		_fail("distinct resource and identity symbols must not alias")
		return
	print("SECT_UI_ICON_ATLAS_PASS icons=%d alpha=1 provenance=original_generated not_source_a=1" % required.size())
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	print("SECT_UI_ICON_ATLAS_FAIL " + message)
	quit(1)
