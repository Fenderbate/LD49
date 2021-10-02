extends Node


var GRAVITY = 10

var focused_planet = null


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_planet_focus(new_planet = null):
	
	if focused_planet == null or new_planet != focused_planet.get_ref():
		focused_planet = weakref(new_planet)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
