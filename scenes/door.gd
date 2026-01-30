extends Area2D
@export var x_axis = -1
@export var y_axis = -1
@export var direction = ""

func _on_body_entered(body: Node2D) -> void:
	if body and body.is_in_group("player"):
		var level = get_tree().get_nodes_in_group("level")
		for lvl in level:
			lvl.queue_free()
			
		if y_axis == -1:
			Global.PlayerSpawnPoint.x = x_axis
			Global.PlayerSpawnPoint.y = body.global_position.y
		else:
			Global.PlayerSpawnPoint.x = body.global_position.x
			Global.PlayerSpawnPoint.y = y_axis
			
		Global.PlayerVelocityY = Global.player.velocity.y
		Global.PlayerFlipH = Global.player.get_fliph()
		Global.calcRoom(direction)
			
		get_tree().reload_current_scene()
