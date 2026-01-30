extends Area2D
@export var fixed = false

func _on_body_entered(body):
	if body and (body.is_in_group("player") or body.is_in_group("enemy")):
		$AnimationPlayer.play("new_animation")
		$Timer.start() 
		#Global.play_sound(Global.pick_random([Global.PlantSFX, Global.Plant2SFX]))

func _on_timer_timeout():
	$AnimationPlayer.stop()
