extends Control

signal instructions_done

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_done_pressed() -> void:
	instructions_done.emit()


func _on_visibility_changed() -> void:
	if is_visible():
		TTS_Speaker.speak_text($VBoxContainer/Instructions.get_text())
		$VBoxContainer/Done.grab_focus()
		
