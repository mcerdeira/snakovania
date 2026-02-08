extends Area2D
@export var fixed = false
var first_ttl = 0.1

func _physics_process(delta: float) -> void:
	if first_ttl > 0:
		first_ttl -= 1 * delta

func _on_body_entered(body):
	if first_ttl <= 0:
		if body and (body.is_in_group("player") or body.is_in_group("enemy")):
			$AnimationPlayer.play("new_animation")
			$Timer.start() 
			#Global.play_sound(Global.pick_random([Global.PlantSFX, Global.Plant2SFX]))

func _on_timer_timeout():
	$AnimationPlayer.stop()

func _on_area_entered(area: Area2D) -> void:
	if first_ttl <= 0:
		if area and area.is_in_group("door"):
			$AnimationPlayer.play("new_animation")
			$Timer.start() 

func _on_area_exited(area: Area2D) -> void:
	if first_ttl <= 0:
		if area and area.is_in_group("door"):
			$AnimationPlayer.play("new_animation")
			$Timer.start() 
