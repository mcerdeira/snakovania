extends Area2D
@export var item_type = ""

func _ready() -> void:
	visible = false
	$sprite.animation = item_type
	if item_type == "grow" and Global.Hasgrow:
		queue_free()
	elif item_type == "map" and Global.HasMap:
		queue_free()
	elif item_type == "swim" and Global.HasSwim:
		queue_free()
	else:
		visible = true

func _on_body_entered(body: Node2D) -> void:
	if body and body.is_in_group("player"):
		Global.ItemNotification.shownotif("GROW", "Press <SPACE> to start growing and <ARROWS> to choose direction")
		if item_type == "grow":
			Global.Hasgrow = true
			
		queue_free()
