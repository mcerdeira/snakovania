extends CharacterBody2D

@export var speed: float = 200.0
@export var gravity: float = 1200.0
@export var record_dist: float = 6.0
@onready var trail: Line2D = $trail
@onready var sprite: AnimatedSprite2D = $sprite

@onready var ghost : AnimatedSprite2D = $ghost
@onready var shoot_line: Line2D = $shoot_line
@export var max_angle := 60.0
@export var aim_speed := 40.0
@export var shoot_distance := 1152.0
var splited = false
var is_clone = false
var aim_angle := 0.0
var preview_hit_position : Vector2

var shooting = false
var is_on_air = false
var first_on_air = true
var first_move_grow = true
var grow_ttl = 0.0
var growing: bool = false
var rewinding: bool = false
var retracting: bool = false
var face_dir: int = 1
var body_obj = load("res://scenes/body.tscn")
var bullet_obj = load("res://scenes/player.tscn")
var recall_obj = load("res://scenes/bullet.tscn")
var body_parts = []
var maxsize = 10
var size = 0
var blowed = 0.0
var is_in_water = false
var walk_smoke_ttl = 0.0

var ttl_total = 0.2
var ttl = ttl_total
var ttl_add_parts = 1.0
var direction = Vector2.DOWN
var body = []
var dir_changed = true
var position_prev = null
var rotation_prev = null

func _ready() -> void:
	add_to_group("player")
	
func get_fliph():
	return $sprite.flip_h

func set_fliph(flip):
	$sprite.flip_h = flip
	
func set_in_water():
	global_position = Global.calculate_snap(global_position, 32.0, Global.current_room.global_position)
	ttl_add_parts = 1.0
	size = 0
	is_in_water = true
	position_prev = global_position
	rotation_prev = $sprite.rotation_degrees
	velocity = Vector2.ZERO
	$animations.stop()
	
func add_parts():
	var g = body_obj.instantiate()
	g.show_tail()
	g.global_position = Vector2(global_position.x - (32 * (body.size() + 1)), global_position.y)
	get_parent().add_child(g)
	body.append(g)

func _physics_process(delta: float) -> void:
	if global_position.x < Global.Camera.global_position.x:
		if is_clone:
			Global.player.re_call()
		else:
			Global.calcRoom("L")
			Global.Main.setRoom()
	elif global_position.x > Global.Camera.global_position.x + 1152:
		if is_clone:
			Global.player.re_call()
		else:
			Global.calcRoom("R")
			Global.Main.setRoom()
	elif global_position.y > Global.Camera.global_position.y + 648:
		if is_clone:
			Global.player.re_call()
		else:
			Global.calcRoom("D")
			Global.Main.setRoom()
	elif global_position.y < Global.Camera.global_position.y:
		if is_clone:
			Global.player.re_call()
		else:
			Global.calcRoom("U")
			Global.Main.setRoom()
		
	if is_in_water:
		if dir_changed:
			if direction != Vector2.RIGHT and Input.is_action_just_pressed("left"):
				dir_changed = false
				direction = Vector2.LEFT
				$sprite.flip_h = true
			elif direction != Vector2.LEFT and Input.is_action_just_pressed("right"):
				dir_changed = false
				direction = Vector2.RIGHT
				$sprite.flip_h = false
			elif direction != Vector2.DOWN and Input.is_action_just_pressed("up"):
				dir_changed = false
				direction = Vector2.UP
			elif direction != Vector2.UP and Input.is_action_just_pressed("down"):
				dir_changed = false
				direction = Vector2.DOWN

		ttl -= 1 * delta
		if ttl_add_parts > 0:
			ttl_add_parts -= 1 * delta
			
		if ttl <= 0:
			if !Global.GAMEOVER:
				if size < maxsize:
					if ttl_add_parts <= 0:
						size += 2
						add_parts()
				position += direction.normalized() * 32
				update_body()
				position_prev = global_position
				rotation_prev = $sprite.rotation_degrees
				ttl = ttl_total
				dir_changed = true
	else:
		if blowed > 0:
			blowed -= 1 * delta
		
		if blowed <= 0 and Global.Hasgrow and Input.is_action_just_pressed("grow") and (growing or is_on_floor()):
			growing = !growing
			$animations.stop()
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
			
		if Global.HasSplit and !is_clone:
			if Input.is_action_just_pressed("shoot"):
				if splited:
					re_call()
				else:
					if !shooting:
						ghost.visible = true
						aim_angle = 0
						shooting = true
			elif Input.is_action_just_released("shoot"):
				if shooting:
					ghost.visible = false
					shooting = false
					shoot_line.clear_points() 
					splited = true
					maxsize = 5
					shoot()
		
		if !shooting:
			move_normal(delta)
			move_and_slide()
		else:
			var input_y = 0
			var mult = -1 if sprite.flip_h else 1
			if Input.is_action_pressed("up"):
				input_y -= 1 * mult
			if Input.is_action_pressed("down"):
				input_y += 1 * mult

			aim_angle += input_y * aim_speed * delta
			aim_angle = clamp(aim_angle, -max_angle, max_angle)

			update_preview()
			
func kill_tail():
	for b in body:
		b.queue_free()
			
func re_call():
	var clone_pos = Vector2.ZERO
	splited = false
	maxsize = 10
	var players = get_tree().get_nodes_in_group("clones")
	if players.size() > 0:
		for p in players:
			clone_pos = p.global_position
			if p.is_in_water:
				p.kill_tail()
				
			p.queue_free()
			
	var recall = recall_obj.instantiate()
	recall.global_position = clone_pos
	recall.direction = (global_position - clone_pos).normalized()
	get_parent().add_child(recall)
			
func update_preview():
	var mult = -1 if sprite.flip_h else 1
	var dir = Vector2(mult, 0).rotated(deg_to_rad(aim_angle)).normalized()

	var from = global_position
	var to = from + dir * shoot_distance

	var space_state = get_world_2d().direct_space_state

	var query = PhysicsRayQueryParameters2D.create(from, to)
	query.exclude = [self]
	query.collide_with_areas = false
	query.collide_with_bodies = true

	var result = space_state.intersect_ray(query)

	if result:
		var normal = result.normal
		preview_hit_position = result.position + normal * 16
	else:
		preview_hit_position = to
	
	ghost.global_position = preview_hit_position
	
	update_line(from, preview_hit_position)
	
func update_line(from: Vector2, to: Vector2):
	shoot_line.clear_points()
	shoot_line.add_point(from)
	shoot_line.add_point(to)
	
func set_clone():
	is_clone = true
	maxsize = 5
	add_to_group("clones")
	$sprite.animation = "clone"

func shoot():
	var clone = bullet_obj.instantiate()
	clone.global_position = preview_hit_position
	clone.set_clone()
	get_parent().add_child(clone)
		
func update_body():
	var prev = position_prev
	var rot = rotation_prev
	for b in body:
		if b:
			b.update_body(prev, rot)
			prev = b.position_prev
			rot = b.rotation_prev
	
func retract_step():
	$fake_tail.visible = false
	if body_parts.is_empty():
		retracting = false
		trail.clear_points()
		return

	grow_ttl = 0.04
	var target = body_parts[0]
	body_parts[0].queue_free()
	trail.set_point_position(0, trail.to_local(body_parts[0].global_position))
	body_parts.pop_front()
	trail.remove_point(0)
	
func reset_to_last(pos):
	#Global.play_sound(Global.PlayerHurtSFX)
	$animations.stop()
	global_position = pos
	blowed = 1.1
	velocity = Vector2.ZERO
	$animations.play("reset_position")
	
func rewind_step():
	if body_parts.is_empty():
		rewinding = false
		trail.clear_points()
		$fake_tail.visible = false
		return
	
	grow_ttl = 0.04
	var target = body_parts[-1]
	global_position = target.global_position
	target.queue_free()
	body_parts.pop_back()
	trail.remove_point(trail.get_point_count() - 1)

func move_normal(delta: float) -> void:
	walk_smoke_ttl -= 1 * delta
	if not is_on_floor():
		is_on_air = true
		velocity.y += gravity * delta
	else:
		if is_on_air:
			if !first_on_air:
				Global.emit(Vector2(global_position.x, global_position.y + 16), 5)
			else:
				first_on_air = false
				
		is_on_air = false
		velocity.y = 0

	if blowed <= 0:
		var dir_h: float = Input.get_axis("left", "right")
		if dir_h != 0:
			face_dir = int(dir_h)
			sprite.flip_h = face_dir == -1
			if walk_smoke_ttl <= 0:
				walk_smoke_ttl = 0.4
				Global.emit(Vector2(global_position.x, global_position.y + 16), 1)
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
	global_position = Global.calculate_snap(global_position, 32.0, Global.current_room.global_position)
	$fake_tail.visible = true
	$fake_tail.global_position = global_position
	trail.add_point(global_position)
	body_parts = []
