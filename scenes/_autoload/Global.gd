extends Node

var cloud = preload("res://sprites/cloud_1.png")

var GRAVITY = 10

var focused_planet = null


var SCORCH_DISTANCE = 200
var HEAT_DISTANCE = 220
var CONFORT_MINIMUM = 230
var CONFORT_MAXIMUM = 250
var COLD_DISTANCE = 350
var FREEZE_DISTANCE = 400

var TEMP_DELTA = {"SCORCH":50,"HEAT":30,"CONFORT":0,"COLD":-30,"FREEZE":-50}

var FLORA_DELTA = {"SMALL":1,"MED":2,"BIG":3}

var OBJECT_TYPE = {"FLORA":0,"OBJECT":1,"BUILDING":2,"MACHINE":3}

var MAX_ATMOSPHERE = 1000
var MAX_TEMPERATURE = 1000


var plant_supply = 10
var object_supply = 10
var machine_supply = 3


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func reset_data():
	focused_planet = null
	plant_supply = 10
	object_supply = 10
	machine_supply = 3

func set_planet_focus(new_planet = null):
	
	if is_planet_null() or new_planet != focused_planet.get_ref():
		focused_planet = weakref(new_planet)
		focused_planet.get_ref().animate_overview(true)

func clear_planet_focus():
	focused_planet.get_ref().animate_overview(false)
	focused_planet = null

func is_planet_null():
	if focused_planet == null:
		return true
	return false
	
func check_focused_planet(planet_to_check):
	if focused_planet == null or focused_planet.get_ref() != planet_to_check:
		return false
	return true
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
