extends Node3D

signal update(damage: int, hits: int, end:bool, next:bool)

const RANGE = 30 # Seconds
var torpedo_scene = preload("res://Scenes/torpedo.tscn")
var target_scene = preload("res://Scenes/target.tscn")
var isVisible = false
var ball_noise = true
#var voice_id = ""
var rng = RandomNumberGenerator.new()

var paused = false

var total_targets = 1
var targets_destroyed = 0
var total_damage = 0
var level = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var voices = DisplayServer.tts_get_voices_for_language("en")
	#if voices:
	#	voice_id = voices[0]
	#set up stuff
	set_level(1)
	reset()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(event) -> void:
	if paused:
		return
		
	if event.is_action_pressed('camera_toggle'):
		#print("camera")
		isVisible = !isVisible
		$Player/Camera3D.current = isVisible
		$SkyCam.current = not isVisible
		
	elif event.is_action_pressed("sonar_ping"):
		send_sonar_ping()
	
	elif event.is_action_pressed("shoot_torpedo"):
		fire_torpedo()

	elif event.is_action_pressed('reset_ball'):
		reset()
	

func reset() -> void:
	targets_destroyed = 0
	for target in $Enemies.get_children():
			#target.set_sleeping(true)
			target.reset_to(Vector3(rng.randi_range(-60, 60), 0.51, rng.randi_range(-60, 60)))
	#$Target.set_sleeping(true)
	#$Target.set_position(Vector3(rng.randi_range(-90, 90), 3, rng.randi_range(-40, 40)))

func next_level():
	set_level(level + 1)

func set_level(l: int):
	remove_all_enemies()
	level = l
	var num_targets = int((level - 1) / 4) + 1
	var type = int((level - 1) % 4)
	
	print("creating " + str(num_targets) + " of type " + str(type))
	#create targets
	for i in range(num_targets):
		#create an instance
		var enemy = target_scene.instantiate()
		
		match type:
			0:
				enemy.is_moving = false
				enemy.can_fire = false
			1:
				enemy.is_moving = true
				enemy.can_fire = false
			2:
				enemy.is_moving = false
				enemy.can_fire = true
			3:
				enemy.is_moving = true
				enemy.can_fire = true
		
		enemy.connect("destroyed", _on_target_destroyed)
		$Enemies.add_child(enemy)	
		
	#randomize locations
	reset()

func remove_all_enemies():
	#$Enemies.get_children().clear()
	for c in $Enemies.get_children():
		c.queue_free();
	Target.num_targets = 0

func fire_torpedo() -> void:
	#put down an audio direction marker at the player's location, in the direction of the ball
	var torpedo = torpedo_scene.instantiate()
	var playerFacing = $Player.global_basis * Vector3(0, 0, -2)
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
		#DisplayServer.tts_speak("Bumped into target", voice_id)
		TTS_Speaker.speak_text("Bumped into target")
	elif body.is_in_group("TorpedoGroup"):
		#DisplayServer.tts_speak("Hit target", voice_id)
		TTS_Speaker.speak_text("Hi by torpedo target")
		
	


func _on_player_damaged(damage: int) -> void:
	
	print("player damage in main")
	if damage == 100:
		set_pause(true)
		update.emit($Player.get_damage_pct(), targets_destroyed, true, false)
	else:
		update.emit($Player.get_damage_pct(), targets_destroyed, false, false)

func set_pause(new_value: bool) -> void:
	paused = new_value
	if paused:
		$OceanNoise.stop()
	else:
		$OceanNoise.play()


func _on_target_destroyed() -> void:
	targets_destroyed += 1
	update.emit($Player.get_damage_pct(), targets_destroyed, 
		targets_destroyed == total_targets, targets_destroyed == total_targets)
