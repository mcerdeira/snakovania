extends GPUParticles2D
var clear_ttl = 1
var size = 1

func _ready():
	add_to_group("particles2")
	if size != 1:
		scale = Vector2(size, size)
		
func _physics_process(delta):
	if !emitting:
		clear_ttl -= 1 * delta
		if clear_ttl <= 0:
			queue_free()

func _on_timer_timeout():
	emitting = false
