extends Node3D

signal update(damage: int, hits: int, end:bool, next:bool)

const RANGE = 30 # Seconds
var torpedo_scene = preload("res://Scenes/torpedo.tscn")
var target_scene = preload("res://Scenes/target.tscn")
var isVisible = false
var ball_noise = true
#var voice_id = ""
var rng = RandomNumberGenerator.new()
var level_rng = RandomNumberGenerator.new()

var paused = false

var location_known = false
var last_location = Vector3(0, 0, 0)

var total_targets = 1
var targets_destroyed = 0
var all_targets_destroyed = 0
var total_damage = 0
var level = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level_rng.set_seed(13)
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
		
	elif event.is_action_pressed('enemy_location'):
		enemy_location()
	

func reset() -> void:
	targets_destroyed = 0
	for target in $Enemies.get_children():
			#target.set_sleeping(true)
			target.reset_to(Vector3(rng.randi_range(-60, 60), 3, rng.randi_range(-60, 60)))
	#$Target.set_sleeping(true)
	#$Target.set_position(Vector3(rng.randi_range(-90, 90), 3, rng.randi_range(-40, 40)))

func next_level():
	set_level(level + 1)

func set_level(l: int):
	Target.num_targets = 0
	#set_level_orig(l)
	remove_all_enemies()
	level = l
	
	var num_targets = int((level - 1) / 4) + 1
	var type = int((level - 1) % 4)
	#first four levels just have one target (each of different type)
	if level <= 4:
		create_target(type)
		speak_type(type)
	else:
		for i in range(num_targets):
			create_target(level_rng.randi_range(0,3))	
		TTS_Speaker.speak_text(str(num_targets) + " enemies.")	
	
	
	location_known = false
	last_location = Vector3()
	#randomize locations
	total_targets = num_targets
	reset()
	set_pause(false)
	
func create_target(type: int):
	var enemy = target_scene.instantiate()
	enemy.is_moving = type % 2 == 1
	enemy.can_fire = int(type / 2) == 1
		
	enemy.connect("destroyed", _on_target_destroyed)
	$Enemies.add_child(enemy)	

func speak_type(type: int):
	var mv = false
	var fr = false
	match type:
			0:
				mv = false
				fr = false
			1:
				mv = true
				fr = false
			2:
				mv= false
				fr = true
			3:
				mv = true
				fr = true
	
	var msg = "This enemy "
		
	if mv:			
		msg += "can move "
	else:
		msg += "is stationery "
	if fr:			
		msg += "and it can fire torpedos."

	TTS_Speaker.speak_text(msg)

func set_level_orig(l: int):
	remove_all_enemies()
	level = l
	var num_targets = int((level - 1) / 4) + 1
	var type = int((level - 1) % 4)
	
	print("creating " + str(num_targets) + " of type " + str(type))
	var mv = false
	var fr = false
	match type:
			0:
				mv = false
				fr = false
			1:
				mv = true
				fr = false
			2:
				mv= false
				fr = true
			3:
				mv = true
				fr = true
	
	var msg = "%d enemies which "%num_targets
		
	if mv:			
		msg += "can move "
	else:
		msg += "are stationery "
	if fr:			
		msg += "and they can fire torpedos."
		
	TTS_Speaker.speak_text(msg)
	#create targets
	for i in range(num_targets):
		#create an instance
		var enemy = target_scene.instantiate()
		
		enemy.is_moving = mv
		enemy.can_fire = fr
		
		
		enemy.connect("destroyed", _on_target_destroyed)
		location_known = false
		last_location = Vector3()
		$Enemies.add_child(enemy)	
		
	#randomize locations
	total_targets = num_targets
	reset()
	set_pause(false)

func remove_all_enemies():
	#$Enemies.get_children().clear()
	for c in $Enemies.get_children():
		c.queue_free();
	Target.num_targets = 0

func fire_torpedo() -> void:
	#put down an audio direction marker at the player's location, in the direction of the ball
	var torpedo = torpedo_scene.instantiate()
	var playerFacing = $Player.global_basis * Vector3(0, 0, -1.5)
	var playerPosition = $Player.get_global_position()
	
	torpedo.position = playerPosition + playerFacing
	torpedo.destination = playerPosition+playerFacing*RANGE
	
	add_child(torpedo)
	torpedo.start()
	
func send_sonar_ping():
	for target in $Enemies.get_children():
		#everyone ping
		target.ping($Player.position)
		last_location = target.get_position()
		#print(last_location)
		location_known = true
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
		update.emit($Player.get_damage_pct(), all_targets_destroyed, true, false)
	else:
		update.emit($Player.get_damage_pct(), all_targets_destroyed, false, false)

func set_pause(new_value: bool) -> void:
	paused = new_value
	if paused:
		$OceanNoise.stop()
	else:
		$OceanNoise.play()


func _on_target_destroyed() -> void:
	targets_destroyed += 1
	all_targets_destroyed += 1
	
	set_pause(targets_destroyed == total_targets)
	update.emit($Player.get_damage_pct(), all_targets_destroyed, 
		targets_destroyed == total_targets, targets_destroyed == total_targets)

func enemy_location():
	if location_known:
		#firgure out an angle and distance from current direction
		
		var playerFacing = $Player.global_basis * Vector3(0, 0, -1)
		var dir_to_enemy = last_location - $Player.get_position()
		var enemy_angle = rad_to_deg(playerFacing.signed_angle_to(dir_to_enemy, Vector3.UP))
		print(playerFacing)
		print(last_location)
		print(enemy_angle)
		var dir = "port"
		if enemy_angle < 0:
			dir = "starboard"
			enemy_angle *= -1
		TTS_Speaker.speak_text("The enemy was %.2f degrees to %s"%[enemy_angle,dir])
	else:
		TTS_Speaker.speak_text("Location not known. Use sonar. s key.")
