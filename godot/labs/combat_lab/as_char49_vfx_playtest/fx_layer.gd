extends Node2D
# Draw helper for a separate canvas z-plane. Does not own combat state.
var stage: Node2D
var front := false
func _draw() -> void:
    if stage != null and stage.has_method("draw_fx_layer"):
        stage.draw_fx_layer(self, front)