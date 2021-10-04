extends Node

var cloud = preload("res://sprites/cloud_1.png")
var currency_texture = preload("res://misc/CurrencyTexture.tres")
var person = preload("res://scenes/person/Person.tscn")

var GRAVITY = 10

var focused_planet = null


var SCORCH_DISTANCE = 180
var HEAT_DISTANCE = 210
var CONFORT_MINIMUM = 220
var CONFORT_MAXIMUM = 230
var COLD_DISTANCE = 350
var FREEZE_DISTANCE = 400

var TEMP_LIMITS = {"SCORCH":900,"HEAT":700,"CONFORT_MAX":600,"CONFORT_MIN":400,"COLD":300,"FREEZE":100}

var TEMP_DELTA = {"SCORCH":50,"HEAT":30,"CONFORT":0,"COLD":-30,"FREEZE":-50}

var OXYGEN_DELTA = {"NEG_BIG":-3,"NEG_MED":-2,"NEG_SMALL":-1,"NONE":0,"SMALL":1,"MED":2,"BIG":3}

var OBJECT_TYPE = {"FLORA_SMALL":0,"FLORA_MED":1,"FLORA_BIG":2,"OBJECT":3,"BUILDING":4,"MACHINE":5}

var OBJECT_TYPE_COST = {"FLORA_SMALL":1,"FLORA_MED":2,"FLORA_BIG":3,"OBJECT":3,"BUILDING":4,"MACHINE":5}

var OBJECT_TYPE_SUPPLY = {"FLORA_SMALL":5,"FLORA_MED":2,"FLORA_BIG":1,"OBJECT":2,"BUILDING":1,"MACHINE":1}

var MAX_ATMOSPHERE = 1000
var MAX_TEMPERATURE = 1000

var currency = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func reset_data():
	focused_planet = null
	OBJECT_TYPE_SUPPLY = {"FLORA_SMALL":5,"FLORA_MED":2,"FLORA_BIG":1,"OBJECT":2,"BUILDING":1,"MACHINE":1}
	currency = 0
	SignalManager.emit_signal("update_supply_display")

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
