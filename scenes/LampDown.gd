extends Node2D

var pivot_point:Vector2	#point the pendulum rotates around
var end_position: = Vector2() #pendulum itself
var arm_length:float
var angle #Get angle between position + add godot angle offset

var gravity = 0.4 * 60
var damping = 0.995  #Arbitrary dampening force

var angular_velocity = 0.0
var angular_acceleration = 0.0

var health = 15

@export var LampDown : Node2D
@export var Chain : Line2D

var super_parent = null

func _ready()->void:
	set_start_position(position, LampDown.position)

func set_start_position(start_pos:Vector2, end_pos:Vector2):
	pivot_point = start_pos
	end_position = end_pos
	arm_length = Vector2.ZERO.distance_to(end_position-pivot_point)
	angle = 0#Vector2.ZERO.angle_to(end_position-pivot_point) - deg_to_rad(-90)
	angular_velocity = 0.0
	angular_acceleration = 0.0

func process_velocity(delta:float)->void:
	angular_acceleration = (((-gravity*delta) / arm_length) *sin(angle))	#Calculate acceleration (see: http://www.myphysicslab.com/pendulum1.html)
	angular_velocity += angular_acceleration				#Increment velocity
	angular_velocity *= damping								#Arbitrary damping
	angle += angular_velocity								#Increment angle
	
	end_position = pivot_point + Vector2(arm_length*sin(angle), arm_length*cos(angle))
	
	LampDown.position = end_position - pivot_point
	Chain.clear_points()
	Chain.add_point(position)
	Chain.add_point(LampDown.position)

func add_angular_velocity(force:float)->void:
	angular_velocity += force

func _physics_process(delta)->void:		#example of in game swing kick
	process_velocity(delta)
	super_parent = get_parent()

func _on_lamp_area_body_entered(body):
	if health > 0:
		if body and (body.is_in_group("player") or body.is_in_group("enemies") or body.is_in_group("prisoners") or body.is_in_group("interactuable")):
			var sound = null #Global.pick_random([Global.Chains1SFX, Global.Chains2SFX])
			var db = linear_to_db(abs(20) * 0.01)
			var options = {"volume_db": db}
			if body.is_in_group("bosses"):
				Global.play_sound(sound)
			else:
				Global.play_sound(sound, options, global_position)
			
			var mult = 1
			if Global.player.global_position.x > global_position.x:
				mult = -1
			
			var dir = sign(100) * mult
			add_angular_velocity(dir * 0.02)
			health -= 5
			if health <= 0:
				LampDown.deactivate_lamp()
				Global.emit(LampDown.global_position, 5)
