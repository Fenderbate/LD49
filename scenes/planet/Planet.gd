extends Node2D


var camera_zoom = Vector2(1,1)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_SSInteract_input_event(viewport, event, shape_idx):
	
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed:
		print("Asd")
		SignalManager.emit_signal("planet_interact",weakref(self))
	
	pass
