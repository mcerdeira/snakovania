extends Node2D

func _ready() -> void:
	Global.Main = self
	setRoom()
	
func setRoom():
	var coordenas = Global.World[Global.CurrentLevel[0]][Global.CurrentLevel[1]]
	var room = "room_" + str(coordenas) + ".tscn"
	var lvl_scene = load("res://levels/" + room)
	var lvl = lvl_scene.instantiate()
	Global.current_room = lvl
	lvl.global_position = Global.CurrentWorldPos
	Global.Camera.global_position = Global.CurrentWorldPos
		
	add_child(lvl)
	if Global.player == null:
		Global.player = Global.player_obj.instantiate()
		Global.player.global_position = Vector2(576, 304)
		add_child(Global.player)
