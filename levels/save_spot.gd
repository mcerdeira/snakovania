extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body and body.is_in_group("player"):
		if body.is_on_floor():
			$AnimationPlayer.play("new_animation")
			$sprite.stop()

func save_game():
	Global.InitialPosition = Global.player.global_position
	Global.save_game()
	Global.ItemNotification.shownotif("", "SAVING YOUR GAME...")

func _on_body_exited(body: Node2D) -> void:
	if body and body.is_in_group("player"):
		$sprite.play("default")
		$AnimationPlayer.stop()
