extends Area2D
@export var safe_pos : Marker2D = null


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if !body.growing and !body.retracting and !body.rewinding:
			if !Global.HasSwim:
				body.reset_to_last(safe_pos.global_position)
