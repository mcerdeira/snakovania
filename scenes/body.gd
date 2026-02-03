extends StaticBody2D
var position_prev = null
var rotation_prev = null

func _ready() -> void:
	position_prev = global_position
	rotation_prev = $sprite.rotation_degrees

func show_tail():
	$sprite.visible = true

func flip(flip_val):
	$sprite.flip_h = flip_val

func update_body(prev, rot):
	position_prev = global_position
	rotation_prev = $sprite.rotation_degrees
	
	global_position = prev
	$sprite.rotation_degrees = rot
