extends Control


signal done(next: bool)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup()
	
func setup() -> void:
	#$HBoxContainer/Time.set_text("Time: %d"%time)
	$GameOver.set_visible(false)
	$NextLevel.set_visible(false)
	#$Timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


#func end_game(message: String) -> void:
#	$GameOver.set_text(message)
#	TTS_Speaker.speak_text(message)


func _on_visibility_changed() -> void:
	if self.is_visible():
		setup()
	else:
		pass


func _on_game_over_pressed() -> void:
	done.emit(false)


func _on_next_level_pressed() -> void:
	done.emit(true)
	$NextLevel.set_visible(false)

func _on_main_update(damage: int, hits: int, end: bool, next: bool) -> void:
	#print("update in main")
	$HBoxContainer/Health.set_text("Damage: %d%%"%damage)
	$HBoxContainer/Score.set_text("Score: %d"%hits)
	if end:
		if next:
			$NextLevel.set_visible(true)
			$NextLevel.grab_focus()
		else:
			$GameOver.set_visible(true)
			$GameOver.grab_focus()
		$Timer.start()
			
			


func _on_timer_timeout() -> void:
	print("t.o.")
	if $NextLevel.is_visible():
		TTS_Speaker.speak_text($NextLevel.get_text())
	elif $GameOver.is_visible():
		TTS_Speaker.speak_text($GameOver.get_text())
		
