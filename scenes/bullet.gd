extends Area2D

var speed := 800.0
var direction := Vector2.ZERO

func _physics_process(delta):
	global_position += direction * speed * delta
