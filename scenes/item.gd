extends Area2D
@export var item_type = ""
var title = ""
var description = ""
var taken = false

func _ready() -> void:
	visible = false
	$sprite.animation = item_type
	if item_type == "grow":
		title = "GROW"
		description = "Press <SPACE> to start growing and <ARROWS> to choose direction."
		if Global.Hasgrow:
			queue_free()
		else:
			visible = true
	elif item_type == "map":
		title = "MAP"
		description = "Press <M> to see a map."
		if Global.HasMap:
			queue_free()
		else:
			visible = true
	elif item_type == "swim":
		title = "SWIM"
		description = "Dive into the cold waters."
		if Global.HasSwim:
			queue_free()
		else:
			visible = true
	elif item_type == "split":
		title = "SPLIT"
		description = "Divide yourself in two using <Z> and <TAB> to switch."
		if Global.HasSplit:
			queue_free()
		else:
			visible = true
	elif item_type == "hook":
		title = "HOOK"
		description = "Hang onto some ceilings."
		if Global.HasHook:
			queue_free()
		else:
			visible = true
			
func _bye():
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if !taken:
		if body and body.is_in_group("player"):
			taken = true
			Global.ItemNotification.shownotif(title, description)
			if item_type == "grow":
				Global.Hasgrow = true
			if item_type == "map":
				Global.HasMap = true
			if item_type == "swim":
				Global.HasSwim = true
			if item_type == "split":
				Global.HasSplit = true
			if item_type == "hook":
				Global.HasHook = true
				
			taken = true
			$AnimationPlayer.stop()
			$AnimationPlayer2.play("new_animation")
