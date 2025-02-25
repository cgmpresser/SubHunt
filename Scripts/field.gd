extends Node3D

var left = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_in_bounds_detector_body_exited(body: Node3D) -> void:
	#tell player they have gone too far, start beeping in the center
	if body.is_in_group("PlayerGroup"):
		left = true
		TTS_Speaker.speak_text("Out of bounds")
		#start beeping
		$CenterSignal.play()


func _on_in_bounds_detector_body_entered(body: Node3D) -> void:
	if left and body.is_in_group("PlayerGroup"):
		#this will fire once at start up
		left = false
		TTS_Speaker.speak_text("Back in bounds")
		#stop beeping
		$CenterSignal.stop()
