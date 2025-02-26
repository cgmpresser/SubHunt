extends Node

@export var voice_volume=5
@export var voice_str = ""
@export var rate=1
@export var pitch=1
@export var sound_volume = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func speak_text(text="Hello there."):
	#stop the old one
	DisplayServer.tts_stop()
	DisplayServer.tts_speak(text, voice_str, voice_volume, pitch, rate)
