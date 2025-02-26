extends CharacterBody3D

signal damaged(remaining_health)

const SPEED = 10.0
const ROTATION_SPEED = 2
const JUMP_VELOCITY = 4.5

@export var max_health = 5
var health = max_health


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(0, 0, input_dir.y)).normalized()
	
	rotate_y(-ROTATION_SPEED*input_dir.x*delta)
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func health_status():
	var dmg_pct = int(100 - 100*health/max_health)
	TTS_Speaker.speak_text("Damage at " + str(dmg_pct) + " percent.", false)

func _on_hit_zone_body_entered(body: Node3D) -> void:
	if body.is_in_group("TorpedoGroup"):
		TTS_Speaker.speak_text("You've been hit.")
		health -= 1
		if health == 0:
			damaged.emit(health)
		else:
			health_status()
		body.queue_free()
