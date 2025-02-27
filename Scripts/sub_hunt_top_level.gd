extends Node3D

const SCREEN_START = 0
const SCREEN_SOUND = 1
const SCREEN_GAME = 2
const SCREEN_INSTRUCTIONS = 3

var main_scene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup()
	
func setup() -> void:
	main_scene = $Main
	main_scene.set_pause(true)
	remove_child(main_scene)
	switch_screen(0)
	
func switch_screen(screen) -> void:
	$UI/StartScreen.set_visible(screen == SCREEN_START)
	$UI/SoundSettings.set_visible(screen == SCREEN_SOUND)
	$UI/GameHUD.set_visible(screen == SCREEN_GAME)
	$UI/Instructions.set_visible(screen == SCREEN_INSTRUCTIONS)
	
	if screen == SCREEN_GAME:
		#ass main back to tree
		add_child(main_scene)
		main_scene.set_pause(false)
	elif get_children().has(main_scene):
		#remove main from tree
		main_scene.set_pause(true)
		remove_child(main_scene)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_screen_play_game() -> void:
	switch_screen(SCREEN_GAME)
	$Main.set_level(1)


func _on_start_screen_sound_settings() -> void:
	switch_screen(SCREEN_SOUND)


func _on_sound_settings_done() -> void:
	switch_screen(SCREEN_START)


func _on_game_hud_done(next: bool) -> void:
	if next:
		main_scene.next_level()
		main_scene.set_pause(false)
	else:
		if get_children().has(main_scene):
			#remove main from tree
			remove_child(main_scene)
		switch_screen(SCREEN_START)


func _on_main_update(damage: int, hits: int, end: bool, next: bool) -> void:
	pass


func _on_instructions_instructions_done() -> void:
	switch_screen(SCREEN_START)


func _on_start_screen_instructions() -> void:
	switch_screen(SCREEN_INSTRUCTIONS)
