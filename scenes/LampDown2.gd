extends Node2D

func deactivate_lamp():
	$LampArea/Lamp.queue_free()
	$LampArea/collider.set_deferred("disabled", true)
	$PointLight2D.queue_free()
