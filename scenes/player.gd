extends CharacterBody2D

@export var speed: float = 200.0
@export var gravity: float = 1200.0
@export var record_dist: float = 6.0
@export var rewind_speed_mult: float = 2.0

var growing: bool = false
var rewinding: bool = false
var retracting: bool = false
var face_dir: int = 1
var faketail_obj = load("res://scenes/faketail.tscn")
var faketail = null
var path: Array[Vector2] = [] as Array[Vector2]

@onready var trail: Line2D = $trail
@onready var sprite: AnimatedSprite2D = $sprite

func _physics_process(delta: float) -> void:

	if Input.is_action_just_pressed("grow") and (growing or is_on_floor()):
		growing = !growing
		if growing:
			faketail = faketail_obj.instantiate()
			faketail.global_position = global_position
			get_parent().add_child(faketail)
			start_grow()
		else:
			end_grow()

	if rewinding:
		rewind_step(delta)
		return

	if retracting:
		clear_fake_tail()
			
		retract_step(delta)
		return

	if growing:
		move_grow()
		record_path()
		move_and_slide()
		return

	move_normal(delta)
	move_and_slide()


# -------------------------
# MOVEMENT
# -------------------------

func move_normal(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	var dir_h: float = Input.get_axis("left", "right")
	if dir_h != 0:
		face_dir = int(dir_h)

	velocity.x = dir_h * speed
	sprite.flip_h = face_dir == -1


func move_grow() -> void:
	var dir_h: float = Input.get_axis("left", "right")
	var dir_v: float = Input.get_axis("up", "down")

	if dir_h != 0:
		face_dir = int(dir_h)

	velocity.x = dir_h * speed
	velocity.y = dir_v * speed
	sprite.flip_h = face_dir == -1


# -------------------------
# PATH / GROW
# -------------------------

func start_grow() -> void:
	path.clear()
	trail.clear_points()

	path.append(global_position)
	trail.add_point(trail.to_local(global_position))


func end_grow() -> void:
	if not is_on_floor() and path.size() > 1:
		rewinding = true
		growing = false
	else:
		retracting = true
		growing = false


func record_path() -> void:
	if global_position.distance_to(path[-1]) < record_dist:
		return

	path.append(global_position)
	trail.add_point(trail.to_local(global_position))


# -------------------------
# REWIND
# -------------------------

func clear_fake_tail():
	if faketail:
		faketail.queue_free()
		faketail = null

func rewind_step(delta: float) -> void:
	if path.is_empty():
		rewinding = false
		clear_fake_tail()
		clear_path()
		return

	var rewind_speed: float = (speed * 5) * rewind_speed_mult
	var target: Vector2 = path[-1]

	var dist: float = global_position.distance_to(target)
	var factor: float = clamp(dist / 40.0, 0.25, 1.0)

	global_position = global_position.move_toward(
		target,
		rewind_speed * factor * delta
	)

	if global_position == target:
		path.pop_back()
		trail.remove_point(trail.get_point_count() - 1)


# -------------------------
# RETRACT (SIN REWIND)
# -------------------------

func retract_step(delta: float) -> void:
	if path.size() <= 1:
		retracting = false
		clear_path()
		return

	var target: Vector2 = path[1]
	var speed_retract := speed * 5

	path[0] = path[0].move_toward(target, speed_retract * delta)
	trail.set_point_position(0, trail.to_local(path[0]))

	if path[0].distance_to(target) < 1.0:
		path.pop_front()
		trail.remove_point(0)

func clear_path() -> void:
	path.clear()
	trail.clear_points()
