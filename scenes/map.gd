extends Node2D
var map_cells = []

func _physics_process(delta: float) -> void:
	if Global.HasMap:
		if %CameraMap.enabled:
			if Input.is_action_just_pressed("zoomin"):
				%CameraMap.zoom += Vector2(0.5, 0.5)
			if Input.is_action_just_pressed("zoomout"):
				%CameraMap.zoom -= Vector2(0.5, 0.5)
			if Input.is_action_pressed("right"):
				%CameraMap.global_position.x += 50 * delta
			if Input.is_action_pressed("left"):
				%CameraMap.global_position.x -= 50 * delta
			if Input.is_action_pressed("up"):
				%CameraMap.global_position.y -= 50 * delta
			if Input.is_action_pressed("down"):
				%CameraMap.global_position.y += 50 * delta
		
		if Input.is_action_just_pressed("map"):
			%CameraMap.enabled = !%CameraMap.enabled
			%Camera.enabled = !%Camera.enabled
			if %CameraMap.enabled:
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

	const CELL_W = VIEW_W / GRID_COLS
	const CELL_H = VIEW_H / GRID_ROWS

	const SCALE_X = CELL_W / ROOM_W
	const SCALE_Y = CELL_H / ROOM_H

	for y in range(Global.World.size()):
		for x in range(Global.World[y].size()):
			var cell = Global.World[y][x]
			if cell == "-1":
				continue

			var room_name = "room_" + str(cell) + ".tscn"
			var lvl_scene = load("res://levels/" + room_name)
			if lvl_scene == null:
				continue

			var lvl = lvl_scene.instantiate()
			add_child(lvl)
			map_cells.append(lvl)

			# Escala
			lvl.scale = Vector2(SCALE_X, SCALE_Y)

			# Posición en grilla
			lvl.position = Vector2(
				x * CELL_W,
				y * CELL_H
			)
