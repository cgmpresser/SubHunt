extends OptionButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _input(event: InputEvent) -> void:
	if not self.has_focus():
		return
	if event.is_action_pressed("ui_right"):
		var idx = self.get_selected()
		if idx < self.get_item_count() - 1:
			idx += 1
			self.select(idx)
			emit_signal("item_selected", idx)
			
	elif event.is_action_pressed("ui_left"):
		var idx = self.get_selected()
		if idx > 0:
			idx -= 1
			self.select(idx)
			emit_signal("item_selected", idx)
		
	
