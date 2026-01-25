extends Area2D
@export var item_type = ""

func _on_body_entered(body: Node2D) -> void:
	if body and body.is_in_group("player"):
		Global.ItemNotification.shownotif("GROW", "Press <SPACE> to start growing and <ARROWS> to choose direction")
		if item_type == "grow":
			Global.Hasgrow = true
			
		queue_free()
