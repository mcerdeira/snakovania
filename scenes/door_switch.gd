extends Area2D
@export var door : StaticBody2D

func _on_area_entered(area: Area2D) -> void:
	if area and area.is_in_group("player"):
		$sprite.frame = 1
		door.open_door()

func _on_area_exited(area: Area2D) -> void:
	if area and area.is_in_group("player"):
		$sprite.frame = 0
		door.close_door()
