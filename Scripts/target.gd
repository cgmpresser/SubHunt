extends RigidBody3D
class_name Target

@export var is_moving = false

const SPEED = 3.0
const TIMER_DIFF = .5

static var num_targets = 0
var target_id =  0
var target_position = Vector3(0,0,0)

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
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if is_moving:
		var force = (target_position - position).normalized() * SPEED
		apply_central_force(force)
	
	#if not is_on_floor():
	#	velocity += get_gravity() * delta

	#move_and_slide()
	#position = position + delta*velocity
	pass

func ping(pos: Vector3):
	target_position = pos
	$Timer.start()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("TorpedoGroup"):
		$ExplodeSound.play()
		


func _on_explode_sound_finished() -> void:
	queue_free()


func _on_timer_timeout() -> void:
	$BeepSound.play()
	print(target_id)
	
