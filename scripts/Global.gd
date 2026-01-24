extends Node
const CELL_SIZE = 32
const ROWS = 5
const COLS = 5
const OFFSET = Vector2(192, 96)

var TurnCountTotal = 3
var TurnCount = 3
var FLOOR = 1
var QuestObj = []
var GRID_ELEMENTS = [] #rows,cols
var LEVELS = []
var LEVEL = 0
var GAME_OVER = false
var Main = null
var FULLSCREEN = false
var shaker_obj = null      
var TIME_SIZE = 1.0
var TIME_LEFT = 0
var minutes = 0
var seconds = 0
var player = null
var life = 3
var DMG = 0
var KeyAppeared = false
var NEXT = null
var MainQuest = {}
var Objetives = []

var TutorialLevel = true
var MainTheme = null

var HurtSFX = null
var WalkSFX1 = null
var WalkSFX2 = null
var BeepSFX = null
var WeaponSFX = null
var HealSFX = null
var DoorSFX = null
var KeysSFX = null
var EnemyHitSFX = null
var PlayerDieSFX = null

var PotionMergeSFX = null
var MonsterMergeSFX = null
var WeaponMergeSFX = null
var PlayerAttack = null
var Wok = false
var Aok = false
var Sok = false
var Dok = false
var WPos = Vector2(256, 192)
var APos = Vector2(224, 224)
var SPos = Vector2(256, 224)
var DPos = Vector2(288, 224)

enum GridType { 
	EMPTY = 0,
	ENEMY = 1,
	WEAPON = 2,
	ITEM = 3,
	PLAYER = 4,
	KEY = 5,
	LETTER = 6,
	STATIC = 7,
}

var spawn_weights := {
	GridType.ENEMY: 60,
	GridType.WEAPON: 20,
	GridType.ITEM: 20,
}

var spawn_weights_full := {
	GridType.ENEMY: 49,
	GridType.WEAPON: 24,
	GridType.ITEM: 30,
	GridType.KEY: 1,
}

enum LegalMoves {
	NON,
	MOVEMENT,
	MERGE,
	ATTACK,
	GET_WEAPON,
	GET_ITEM,
	GET_KEY,
}

func _ready() -> void:
	define_objetives()
	load_music()
	load_sfx()
	game_reset()
	
func game_reset():
	Wok = false
	Aok = false
	Sok = false
	Dok = false
	
	FLOOR = 1
	GAME_OVER = false
	life = 3
	DMG = 0
	KeyAppeared = false
	QuestObj = []
	
func define_objetives():
	var files = list_directory_contents("res://levels/")
	for f in files:
		var content = read_level("res://levels/" + f).split(";")
		var layout = content[0]
		var objetive = content[1]
		
		LEVELS.append(layout)
		var lo = str_to_var(objetive)
		Objetives.append(lo)
		
	for i in 5:
		var row = []
		for j in 5:
			row.append(null)
		GRID_ELEMENTS.append(row)
	
func load_music():
	MainTheme = load("res://music/dungeon.wav")
	
func list_directory_contents(path: String):
	var files = []
	var dir_access = DirAccess.open(path)

	if dir_access:
		dir_access.list_dir_begin()
		var file_name = dir_access.get_next()
		while file_name != "":
			if dir_access.current_is_dir():
				print("Found directory: " + file_name)
			else:
				files.append(file_name)
			file_name = dir_access.get_next()
		dir_access.list_dir_end()
		
		return files
	else:
		print("An error occurred when trying to access the path.")
	
func read_level(path: String):
	if not FileAccess.file_exists(path):
		print("Error: File not found at path ", path)
		return

	var file: FileAccess = FileAccess.open(path, FileAccess.READ)

	if file == null:
		print("Error opening file: ", FileAccess.get_open_error())
		return
		
	var content: String = file.get_as_text()
	file.close()
	return content
	
func load_sfx():
	HurtSFX = load("res://sfx/hurt_snd.wav")
	WalkSFX1 = load("res://sfx/walk.mp3")
	BeepSFX = load("res://sfx/beep.mp3")
	WeaponSFX = load("res://sfx/sword.5.ogg")
	HealSFX = load("res://sfx/heal.wav")
	KeysSFX = load("res://sfx/keys_01.ogg")
	DoorSFX = load("res://sfx/door_open.wav")
	PlayerDieSFX = load("res://sfx/PlayerDieSfx.wav")
	EnemyHitSFX = load("res://sfx/EnemyHit.wav")	
	PotionMergeSFX = load("res://sfx/potionmerge.wav")
	MonsterMergeSFX = load("res://sfx/monstermerge.wav")
	WeaponMergeSFX = load("res://sfx/weaponmerge.wav")
	PlayerAttack = load("res://sfx/Attack.wav")

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
