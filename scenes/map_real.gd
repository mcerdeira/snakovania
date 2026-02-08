extends Node2D
var map_cells = []
var original_pos = Vector2(1728.0, 321.0)
var enabled = false

func _physics_process(delta: float) -> void:
	if Global.HasMap:
		if Input.is_action_just_pressed("map"):
			enabled = !enabled
			visible = enabled
			if enabled:
				get_tree().paused = true
				map_cells = []
				draw_map()
			else:
				get_tree().paused = false
				destroy_map()
			
func destroy_map():
	for m in map_cells:
		m.queue_free()
		
func draw_map():
	const GRID_COLS = 16
	const GRID_ROWS = 16

	const VIEW_W = 1152.0
	const VIEW_H = 640.0

	const ROOM_W = 1152.0
	const ROOM_H = 640.0

	const CELL_W = 32
	const CELL_H = 32
	
	const start_x = 11
	const start_y = 2

	for y in range(Global.World.size()):
		for x in range(Global.World[y].size()):
			var cell = Global.World[y][x]
			var visited = Global.VisitedCells[y][x]
			if cell == "-1" or visited == "0":
				continue

			var lvl_scene = load("res://levels/MapRoom.tscn")
			var lvl = lvl_scene.instantiate()
			if Global.CurrentLevel[0] == y and Global.CurrentLevel[1] == x:
				lvl.set_player()
			if visited == "2":
				lvl.set_save_room()
			
			add_child(lvl)
			map_cells.append(lvl)

			lvl.position = Vector2(
				(x + start_x) * CELL_W,
				(y + start_y) * CELL_H
			)
