extends Node3D

const SOUND_MODE_MOVING = 0
const SOUND_MODE_BEEPING = 1
const SOUND_MODES = 2

var marker_scene = preload("res://direction_tracker.tscn")
var rng = RandomNumberGenerator.new()
var isVisible = false
var sound_mode = SOUND_MODE_MOVING
var ball_noise = true

var voice_id = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#make set the seed to the clock
	rng.randomize()	
	#get the voice
	var voices = DisplayServer.tts_get_voices_for_language("en")
	if voices:
		voice_id = voices[0]
	
	#set up stuff
	reset()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event) -> void:
	if event.is_action_pressed('camera_toggle'):
		isVisible = !isVisible
		$Player/Camera3D.current = isVisible
		$Camera3D.current = not isVisible
	elif event.is_action_pressed('sound_mode'):
		switch_sound_mode()
	elif event.is_action_pressed('reset_ball'):
		reset()
	
func switch_sound_mode() -> void:
	#advance to the next mode
	sound_mode = (sound_mode + 1) % SOUND_MODES
	
	match sound_mode:
		SOUND_MODE_MOVING:
			$Ball/Timer.stop()
		SOUND_MODE_BEEPING:
			$Ball/Timer.start()
	
func reset() -> void:
	$Ball.set_sleeping(true)
	$Ball.set_position(Vector3(rng.randi_range(-90, 90), 3, rng.randi_range(-40, 40)))
	#$Ball.apply_central_impulse(Vector3(rng.randi_range(-40, 40), 3, rng.randi_range(-40, 40)))

	

func _on_timer_timeout() -> void:
	#put down an audio direction marker at the player's location, in the direction of the ball
	var marker = marker_scene.instantiate()
	
	if sound_mode == SOUND_MODE_MOVING:
		marker.mute = false
	else:
		marker.mute = true
	#marker.position = $Player.position
	#marker.destination = $Ball.position
	
	var playerFacing = $Player.global_basis * Vector3(0, 0, -1)
	#print(playerFacing)
	#player's positive x
	var pp = $Player.get_global_position()
	var bp = $Ball.get_global_position()
	var dirPB = pp.direction_to(bp)
	
	if playerFacing.dot(dirPB) > 0:
		#print("Front")
		marker.position = bp
		marker.destination = pp
	else:
		#print("Back")
		marker.position = pp
		marker.destination = bp
	add_child(marker)
	marker.start()


func _on_ball_body_entered(body: Node) -> void:	
	if body == $Player :
		DisplayServer.tts_speak("Hit!", voice_id)


func _on_ball_timer_timeout() -> void:
	ball_noise = !ball_noise
	if ball_noise:
		$Ball/BeepSound.play()
	else:
		$Ball/BeepSound.stop()
	
