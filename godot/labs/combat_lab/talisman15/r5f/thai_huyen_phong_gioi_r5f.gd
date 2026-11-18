extends "res://labs/combat_lab/talisman15/r5/thai_huyen_phong_gioi_r5.gd"
## PAF05 R5F G3.5 candidate: charge-only revision; R5E remains untouched.
## New R5F-exclusive 12 true-RGBA poses: tools/vfx/paf05_r5f_charge_master.py; R5E unchanged.
## Only this virtual charge renderer is replaced; circle, marks, status, timing
## and moving-target contract stay inherited from R5E. No runtime receipt.
const CHARGE_TEX: Texture2D = preload("res://labs/combat_lab/talisman15/r5f/assets/paf05_r5f_charge.webp")
const CHARGE_POSES := 12
const CHARGE_CELL := 320
const REVISION := "PAF05_R5F_CHARGE_ONLY_G3_5_CANDIDATE"

static func charge_frame_at(t: float) -> int:
	return clampi(int(floor(clampf((t - .04) / .82, 0.0, 1.0) * float(CHARGE_POSES - 1))), 0, CHARGE_POSES - 1)

static func charge_alpha_at(t: float) -> float:
	return charge_envelope(t)

func _ready() -> void:
	super._ready()
	print("VFX_PAF05_R5F_READY charge_only=true first_party_rgba=true unchanged_circle_mark=true moving_target=true owner_art=pending")

func _draw_charge_r5(t: float) -> void:
	var a: float = charge_alpha_at(t)
	if a <= .004:
		return
	# Replace R5E's three rotating procedural line glyphs with real painted
	# moving wind strands and the one large readable 風 glyph of the 12-pose source.
	# Hand remains the painterly convergence anchor; source is not UV-warped.
	var phase: float = clampf((t - .04) / .82, 0.0, 1.0) * float(CHARGE_POSES - 1)
	var lo: int = int(floor(phase))
	var hi: int = mini(lo + 1, CHARGE_POSES - 1)
	var blend: float = phase - float(lo)
	var at: Rect2 = Rect2(HAND + Vector2(-61, -116), Vector2(216, 216))
	var uv_lo: Rect2 = Rect2(float(lo % 4) * CHARGE_CELL, float(int(lo / 4)) * CHARGE_CELL, CHARGE_CELL, CHARGE_CELL)
	var uv_hi: Rect2 = Rect2(float(hi % 4) * CHARGE_CELL, float(int(hi / 4)) * CHARGE_CELL, CHARGE_CELL, CHARGE_CELL)
	var body: float = .92 * a
	draw_texture_rect_region(CHARGE_TEX, at, uv_lo, Color(1, 1, 1, body * (1.0 - blend)))
	if hi != lo and blend > .006:
		draw_texture_rect_region(CHARGE_TEX, at, uv_hi, Color(1, 1, 1, body * blend))
	# The single full-size gold 風 is already in the charge atlas. Do not
	# superimpose R5E's smaller status-mark atlas during R5F charge.
	# Small physically local hot core; no orbiting neon bars or HUD ring.
	var compression: float = smoothstep(.18, .75, t)
	var hot: Vector2 = Vector2(31, 31).lerp(Vector2(16, 16), compression)
	draw_texture_rect(glow, Rect2(HAND - hot, hot * 2.0), false, Color(.90, 1, .87, (.16 + .27 * compression) * a))
