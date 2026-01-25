extends Node2D

func _ready() -> void:
	Global.ItemNotification = self

func shownotif(lblname, description):
	$lbl_name.text = lblname
	$lbl_description.text = description
	visible = true
	get_tree().paused = true
	await get_tree().create_timer(5).timeout
	get_tree().paused = false
	visible = false
