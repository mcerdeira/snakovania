extends Area2D
@export var x_axis = -1
@export var goto : String = ""

func _on_body_entered(body: Node2D) -> void:
	if body and body.is_in_group("player"):
		var level = get_tree().get_nodes_in_group("level")
		for lvl in level:
			lvl.queue_free()
			
		Global.PlayerSpawnPoint.x = x_axis
		Global.PlayerSpawnPoint.y = body.global_position.y
		Global.CurrentLevel = goto
		get_tree().reload_current_scene()
