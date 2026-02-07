extends Area2D

var speed := 1800.0
var direction := Vector2.ZERO

func _physics_process(delta):
	global_position += direction * speed * delta
	if abs(global_position.distance_to(Global.player.global_position)) <= 15:
		queue_free()
