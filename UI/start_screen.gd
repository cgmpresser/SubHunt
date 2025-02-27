extends Control

signal play_game
signal sound_settings
signal instructions

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup()
	
func setup() -> void:
	$VBoxContainer/Instructions.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func handle_focus(item) -> void:
	TTS_Speaker.speak_text(item.get_text())

func _on_play_game_button_focus_entered() -> void:
	handle_focus($VBoxContainer/PlayGameButton)

func _on_sound_settings_button_focus_entered() -> void:
	handle_focus($VBoxContainer/SoundSettingsButton)


func _on_play_game_button_pressed() -> void:
	play_game.emit()

func _on_sound_settings_button_pressed() -> void:
	sound_settings.emit()


func _on_visibility_changed() -> void:
	if self.is_visible():
		setup()


func _on_instructions_focus_entered() -> void:
	handle_focus($VBoxContainer/Instructions)


func _on_instruction_button_pressed() -> void:
	instructions.emit()


func _on_instruction_button_focus_entered() -> void:
	handle_focus($VBoxContainer/InstructionButton)
