extends StaticBody2D

func _ready() -> void:
	add_to_group("door")

func open_door():
	$AnimationPlayer.play("new_animation")
	
func close_door():
	$AnimationPlayer.play_backwards("new_animation")
