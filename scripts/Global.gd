extends Node

var GAME_OVER = false
var Main = null
var FULLSCREEN = false
var shaker_obj = null
var player = null
var player_obj = load("res://scenes/player.tscn")
var MainTheme = null
var CurrentLevel = null
var PlayerSpawnPoint = null
var PlayerFlipH = false
var PlayerVelocityY = 0
var ItemNotification = null

var World =[]

var Hasgrow = false
var HasSwim = false

func load_worldmap():
	var file = FileAccess.open("res://levels/world.csv",FileAccess.READ)
	while not file.eof_reached():
		var csv_line: PackedStringArray = file.get_csv_line(";")
		if not csv_line.is_empty():
			World.append(csv_line)
		
func _ready() -> void:
	player = player_obj.instantiate()
	CurrentLevel = [7, 7]
	load_worldmap()
	load_music()
	load_sfx()
	
func calcRoom(dir):
	var xx = Global.CurrentLevel[0]
	var yy = Global.CurrentLevel[1]
	if dir == "R":
		Global.CurrentLevel = [xx, yy + 1]
	elif dir == "L":
		Global.CurrentLevel = [xx, yy - 1]
	elif dir == "U":
		Global.CurrentLevel = [xx - 1, yy]
	elif dir == "D":
		Global.CurrentLevel = [xx + 1, yy]


func load_music():
	pass
	
func load_sfx():
	pass

#func emit(_global_position, count, particle_obj = null, size = 1):
	#var part = particle
	#if particle_obj:
		#part = particle_obj
	#
	#for i in range(count):
		#var p = part.instantiate()
		#p.global_position = _global_position
		#p.size = size
		#add_child(p)
	
func pick_random(container):
	if typeof(container) == TYPE_DICTIONARY:
		return container.values()[randi() % container.size() ]
	assert( typeof(container) in [
			TYPE_ARRAY, TYPE_PACKED_COLOR_ARRAY, TYPE_PACKED_INT32_ARRAY,
			TYPE_PACKED_BYTE_ARRAY, TYPE_PACKED_FLOAT32_ARRAY, TYPE_PACKED_STRING_ARRAY,
			TYPE_PACKED_VECTOR2_ARRAY, TYPE_PACKED_VECTOR3_ARRAY
			], "ERROR: pick_random" )
	return container[randi() % container.size()]

func play_sound(stream: AudioStream, options:= {}, _global_position = null, delay = 0.0) -> AudioStreamPlayer:
	var audio_stream_player = AudioStreamPlayer.new()
	audio_stream_player.process_mode = Node.PROCESS_MODE_ALWAYS

	add_child(audio_stream_player)
	audio_stream_player.stream = stream
	audio_stream_player.bus = "SFX"
	
	for prop in options.keys():
		audio_stream_player.set(prop, options[prop])
		
	if delay > 0.0:
		var timer = Timer.new()
		timer.wait_time = delay
		timer.one_shot = true
		timer.connect("timeout", audio_stream_player.play)
		add_child(timer)
		timer.start()
	else:
		audio_stream_player.play()
		
	audio_stream_player.finished.connect(kill.bind(audio_stream_player))
	
	return audio_stream_player
	
func kill(_audio_stream_player):
	if _audio_stream_player and is_instance_valid(_audio_stream_player):
		_audio_stream_player.queue_free()
