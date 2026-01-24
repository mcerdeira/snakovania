extends CharacterBody2D

@export var speed: float = 200.0
@export var gravity: float = 1200.0
@export var record_dist: float = 6.0
@export var rewind_speed_mult: float = 2.0

var first_move_grow = true
var grow_ttl = 0.0
var growing: bool = false
var rewinding: bool = false
var retracting: bool = false
var face_dir: int = 1
var body_obj = load("res://scenes/body.tscn")
var body_parts = []
var maxsize = 10
var size = 0

@onready var trail: Line2D = $trail
@onready var sprite: AnimatedSprite2D = $sprite

func _physics_process(delta: float) -> void:

	if Input.is_action_just_pressed("grow") and (growing or is_on_floor()):
		growing = !growing
		if growing:
			start_grow()
		else:
			end_grow()

	if rewinding:
		size = 0
		if grow_ttl >= 0:
			grow_ttl -= 1 * delta
			return
		rewind_step()
		return

	if retracting:
		size = 0
		if grow_ttl >= 0:
			grow_ttl -= 1 * delta
			return
		retract_step()
		return

	if growing:
		if grow_ttl >= 0:
			grow_ttl -= 1 * delta
			return
		if size < maxsize:
			move_grow()
		return

	move_normal(delta)
	move_and_slide()
	
func retract_step():
	$fake_tail.visible = false
	if body_parts.is_empty():
		retracting = false
		trail.clear_points()
		return

	var target = body_parts[0]

	body_parts[0].queue_free()
	trail.set_point_position(0, trail.to_local(body_parts[0].global_position))

	body_parts.pop_front()
	trail.remove_point(0)
	
func rewind_step():
	if body_parts.is_empty():
		rewinding = false
		trail.clear_points()
		$fake_tail.visible = false
		return

	var target = body_parts[-1]
	global_position = target.global_position
	target.queue_free()
	body_parts.pop_back()
	trail.remove_point(trail.get_point_count() - 1)

func move_normal(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	var dir_h: float = Input.get_axis("left", "right")
	if dir_h != 0:
		face_dir = int(dir_h)
		sprite.flip_h = face_dir == -1
		if !$animations.is_playing():
			$animations.play("walkanim")
	else:
		if $animations.is_playing():
			$animations.stop()

	velocity.x = dir_h * speed
	
func move_grow():
	if Input.is_action_pressed("right"):
		sprite.flip_h = false
		if not test_move(global_transform, Vector2.RIGHT):
			if first_move_grow:
				first_move_grow = false
				$fake_tail.rotation_degrees = 0
				
			size += 1
			var prev = global_position
			global_position.x += 32
			grow_ttl = 0.1
			trail.add_point(global_position)
			create_body(prev)
	elif Input.is_action_pressed("left"):
		sprite.flip_h = true
		if not test_move(global_transform, Vector2.LEFT):
			if first_move_grow:
				first_move_grow = false
				$fake_tail.rotation_degrees = 180
				
			size += 1
			var prev = global_position
			global_position.x -= 32
			grow_ttl = 0.1
			trail.add_point(global_position)
			create_body(prev)
	elif Input.is_action_pressed("up"):
		if not test_move(global_transform, Vector2.UP):
			if first_move_grow:
				first_move_grow = false
				$fake_tail.rotation_degrees = 270
				
			size += 1
			var prev = global_position
			global_position.y -= 32
			grow_ttl = 0.1
			trail.add_point(global_position)
			create_body(prev)
	elif Input.is_action_pressed("down"):
		if not test_move(global_transform, Vector2.DOWN):
			size += 1
			var prev = global_position
			global_position.y += 32
			grow_ttl = 0.1
			trail.add_point(global_position)
			create_body(prev)
			
func create_body(pos):
	var body = body_obj.instantiate()
	body.global_position = pos
	get_parent().add_child(body)
	body_parts.append(body)
	
func end_grow() -> void:
	var hit = ground_info_below()
	var tilemapbellow = false
	if hit:
		var collider = hit.collider
		if collider is TileMapLayer:
			tilemapbellow = true
	
	if hit and tilemapbellow and body_parts.size() > 1:
		retracting = true
		growing = false
	else:
		rewinding = true
		growing = false
		
func ground_info_below() -> Dictionary:
	var space = get_world_2d().direct_space_state

	var from = global_position
	var to = global_position + Vector2.DOWN * 32

	var query = PhysicsRayQueryParameters2D.create(from, to)
	query.exclude = [self]
	query.collide_with_areas = false
	query.collide_with_bodies = true

	return space.intersect_ray(query)

func start_grow():
	first_move_grow = true
	var grid := 32.0
	var half := grid * 0.5
	global_position = Vector2(
		round((global_position.x - half) / grid) * grid + half,
		round((global_position.y - half) / grid) * grid + half
	)
	$fake_tail.visible = true
	$fake_tail.global_position = global_position
	trail.add_point(global_position)
	body_parts = []
