extends Node3D

const RANGE = 30 # Seconds
var torpedo_scene = preload("res://Scenes/torpedo.tscn")
var isVisible = false
var ball_noise = true
var voice_id = ""
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var voices = DisplayServer.tts_get_voices_for_language("en")
	if voices:
		voice_id = voices[0]
	#set up stuff
	reset()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(event) -> void:
	
	if event.is_action_pressed('camera_toggle'):
		isVisible = !isVisible
		$Player/Camera3D.current = isVisible
		$Camera3D.current = not isVisible
		
	elif event.is_action_pressed("sonar_ping"):
		send_sonar_ping()
	
	elif event.is_action_pressed("shoot_torpedo"):
		fire_torpedo()

	elif event.is_action_pressed('reset_ball'):
		reset()
	

func reset() -> void:
	for target in $Enemies.get_children():
			#target.set_sleeping(true)
			target.reset_to(Vector3(rng.randi_range(-90, 90), 0.51, rng.randi_range(-40, 40)))
	#$Target.set_sleeping(true)
	#$Target.set_position(Vector3(rng.randi_range(-90, 90), 3, rng.randi_range(-40, 40)))

func fire_torpedo() -> void:
	#put down an audio direction marker at the player's location, in the direction of the ball
	var torpedo = torpedo_scene.instantiate()
	var playerFacing = $Player.global_basis * Vector3(0, 0, -1)
	var playerPosition = $Player.get_global_position()
	
	torpedo.position = playerPosition +playerFacing
	torpedo.destination = playerPosition+playerFacing*RANGE
	
	add_child(torpedo)
	torpedo.start()
	
func send_sonar_ping():
	for target in $Enemies.get_children():
		#everyone ping
		target.ping($Player.position)
	#play response (each target)?
	
	#collect info for nearest target
		
	
func _on_target_body_entered(body: Node) -> void:	
	
	if body == $Player :
		print("Hit target")
		DisplayServer.tts_speak("Bumped into target", voice_id)
	elif body.is_in_group("TorpedoGroup"):
		DisplayServer.tts_speak("Hit target", voice_id)
		
	


func _on_player_damaged(remaining_health: Variant) -> void:
	pass # Replace with function body.
