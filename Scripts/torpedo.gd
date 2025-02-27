extends Node3D

const SPEED = 15

@export var destination: Vector3 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass
	

func start() -> void:
	var tween = create_tween()
	
	#calculate fixed speed
	var dist = (position-destination).length()
	var time = dist/SPEED
	
	tween.tween_property(self, "position", destination, time)
	tween.tween_callback(self.queue_free)
	tween.play()
	$Sound.play()
	
