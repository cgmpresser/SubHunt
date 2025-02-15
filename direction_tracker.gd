extends Node3D



# probably always move this toward its destination, even if its destination moves.
# recalculate distance between source and destination and move there?
# would we be able to run from it?

@export var destination: Vector3 
@export var mute: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func start() -> void:
	#setup the tween
	var tween = create_tween()
	
	tween.tween_property(self, "position", destination, 1)
	tween.tween_callback(self.queue_free)
	#play the audio
	if !mute:
		$Sound.play()
	tween.play()
	
