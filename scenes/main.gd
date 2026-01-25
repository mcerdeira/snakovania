extends Node2D

func _ready() -> void:
	var lvl_scene = load("res://levels/" + Global.CurrentLevel +".tscn")
	var lvl = lvl_scene.instantiate()
	add_child(lvl)
	Global.player = Global.player_obj.instantiate()
	if Global.PlayerSpawnPoint == null:
		Global.player.global_position = Vector2(576, 304)
		Global.PlayerSpawnPoint = Vector2.ZERO
	else:
		Global.player.global_position = Global.PlayerSpawnPoint
	
	add_child(Global.player)
