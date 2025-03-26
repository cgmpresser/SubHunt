extends RigidBody3D
class_name Target

signal destroyed

var torpedo_scene = preload("res://Scenes/torpedo.tscn")

@export var is_moving = false
@export var can_fire = false

const SPEED = 3.0
const FORCE_MULT = 6
const TIMER_DIFF = .5
const TORPEDO_START_OFFSET = 2;
const TORPEDO_END_OFFSET = 20;

static var num_targets = 0
var target_id =  0
var target_position = Vector3(0,0,0)
var prep_target_position = Vector3(0,0,0)
var was_hit = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target_id = num_targets
	num_targets += 1
	$Timer.wait_time = TIMER_DIFF * target_id + TIMER_DIFF
	#print("Target " + str(target_id) + " created.")

func reset_to(pos: Vector3) -> void:
	set_position(pos)
	target_position = pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _physics_process(_delta: float) -> void:
	if is_moving:
		#using physics engine (it will actually overshoot its 
		#target and come back
		var dir_vector = (target_position - position).normalized()
		dir_vector.y = 0
		var force = dir_vector * SPEED * FORCE_MULT
		apply_central_force(force)
	
	#if not is_on_floor():
	#	velocity += get_gravity() * delta

	#move_and_slide()
	#position = position + delta*velocity
	

func ping(pos: Vector3):
	prep_target_position = pos
	
	#var dir_vector = (target_position - position).normalized()
	#dir_vector.y = 0
	#var force = dir_vector * SPEED
	#print(force)
	
	$Timer.start()
	
	#start firing timer
	$FiringTimer.start()
	
	


func _on_body_entered(body: Node) -> void:
	if !was_hit and body.is_in_group("TorpedoGroup"):
		was_hit = true;
		$ExplodeSound.play()
		


func _on_explode_sound_finished() -> void:
	destroyed.emit()
	queue_free()


func _on_timer_timeout() -> void:
	$BeepSound.play()
	print(target_id)
	


func _on_firing_timer_timeout() -> void:
	$BeepSound.play()
	target_position = prep_target_position
	if can_fire:
		#fire a torpedo at the target position
		var torpedo = torpedo_scene.instantiate()
		#var playerFacing = $Player.global_basis * Vector3(0, 0, -1)
		#var playerPosition = $Player.get_global_position()
	
		var offset = ((target_position - position).normalized())
		torpedo.position = position + offset*TORPEDO_START_OFFSET
		torpedo.destination = target_position + offset*TORPEDO_END_OFFSET
	
		print(torpedo.position)
		print(torpedo.destination)
	
		get_tree().root.add_child(torpedo)
		torpedo.start()
