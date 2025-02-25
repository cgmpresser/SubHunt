extends Node3D


@export var destination: Vector3 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass
	

func start() -> void:
	var tween = create_tween()
	tween.tween_property(self, "position", destination, 1)
	tween.tween_callback(self.queue_free)
	tween.play()
	$Sound.play()
	
