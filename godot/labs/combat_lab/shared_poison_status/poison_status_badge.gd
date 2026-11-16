extends RefCounted
## Shared PRESENTATION ONLY. Exactly one readable badge for any poisoned target.
## Future PvE must feed this from an authoritative combat status snapshot.
## Does NOT calculate stacks, DoT, HP, expiry, or apply any debuff.
const ICON_PATH := "res://labs/combat_lab/shared_poison_status/assets/poisoned_badge_64.png"
const ICON: Texture2D = preload("res://labs/combat_lab/shared_poison_status/assets/poisoned_badge_64.png")
const ICON_SIZE := Vector2(29,29)

static func should_show(poison_stacks: int, remaining_seconds: float) -> bool:
    return poison_stacks > 0 and remaining_seconds > 0.0

static func draw_for(canvas: CanvasItem, head_anchor: Vector2, poison_stacks: int, remaining_seconds: float, t: float) -> void:
    if not should_show(poison_stacks,remaining_seconds):
        return
    # Small monochrome readable state, not an extra VFX overlay, flash or false hit.
    var lum := .94 + .06 * sin(t * 3.0)
    canvas.draw_texture_rect(ICON,Rect2(head_anchor-ICON_SIZE*.5,ICON_SIZE),false,Color(1,1,1,lum))