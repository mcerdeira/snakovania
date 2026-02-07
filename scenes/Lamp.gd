extends Node2D

func _ready():
	var val = randf_range(0.75, 1.5) 
	$LampDown/LampArea/Lamp/sprite.speed_scale *= val
	$AnimationPlayer.speed_scale *= val
