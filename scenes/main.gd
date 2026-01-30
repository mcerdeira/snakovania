extends Node2D

func _ready() -> void:
	var coordenas = Global.World[Global.CurrentLevel[0]][Global.CurrentLevel[1]]
	var room = "room_" + str(coordenas) + ".tscn"
	var lvl_scene = load("res://levels/" + room)
	var lvl = lvl_scene.instantiate()
	add_child(lvl)
	Global.player = Global.player_obj.instantiate()
	if Global.PlayerSpawnPoint == null:
		Global.player.global_position = Vector2(576, 304)
		Global.PlayerSpawnPoint = Vector2.ZERO
	else:
		Global.player.global_position = Global.PlayerSpawnPoint
		Global.player.set_fliph(Global.PlayerFlipH)
		Global.player.velocity.y = Global.PlayerVelocityY
	
	add_child(Global.player)
