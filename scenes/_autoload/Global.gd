extends Node

var cloud = preload("res://sprites/cloud_1.png")
var currency_texture = preload("res://misc/CurrencyTexture.tres")
var person = preload("res://scenes/person/Person.tscn")

var GRAVITY = 10

var SCORCH_DISTANCE = 180
var HEAT_DISTANCE = 210
var CONFORT_MINIMUM = 220
var CONFORT_MAXIMUM = 230
var COLD_DISTANCE = 350
var FREEZE_DISTANCE = 400


var MAX_ATMOSPHERE = 1000
var MAX_TEMPERATURE = 1000

var TEMP_LIMITS = {"SCORCH":900,"HEAT":700,"CONFORT_MAX":600,"CONFORT_MIN":400,"COLD":300,"FREEZE":100}

var TEMP_DELTA = {"SCORCH":50,"HEAT":30,"CONFORT":0,"COLD":-30,"FREEZE":-50}

var OXYGEN_DELTA = {"NEG_BIG":-3,"NEG_MED":-2,"NEG_SMALL":-1,"NONE":0,"SMALL":2,"MED":4,"BIG":8}

var OBJECT_TYPE = {"FLORA_SMALL":0,"FLORA_MED":1,"FLORA_BIG":2,"OBJECT":3,"BUILDING":4,"MACHINE":5}

var OBJECT_TYPE_COST = {"FLORA_SMALL":1,"FLORA_MED":2,"FLORA_BIG":3,"OBJECT":3,"BUILDING":4,"MACHINE":5}

var OBJECT_TOOLTIP = {
	"FLORA_SMALL":"A small plant, that produces a small amount of oxygen.",
	"FLORA_MED":"A small tree, that produces a medium amount of oxygen.",
	"FLORA_BIG":"A big tree, that produces a large amount of oxygen.",
	"OBJECT":"A mountain, naturally cools the planet.",
	"BUILDING":"A small settlement, produces population if the planet has an atmosphere and vegetation.",
	"MACHINE":"A complicated contraption, that pushes the planetary climate to a confortable level."
	}

var TUTORIAL_TEXT = [
	"[b]Gameplay[/b]\nYour goal is to terraform every planet by keeping the planets' [color=#f5c22f]temperature[/color] and the [color=#4d9be6]oxygen[/color] level in check.\nInformations about the selected planet will be in the bottom left corner.\nThis needs to be done in [color=#ed4d37]10 minutes[/color], your boss is impatient.",
	"[b]Tools to terraform[/b]\nYou can place various objects to terraform any planet!\nSelect an item from the panel at the bottom and simply place them in the proximity of the planet.\nIf you're running low on something, you can easily exchange humans by clicking the [color=#ed4d37] [+] [/color] button above the items.\n",
	"[b]Tools to terraform[/b]\nPlants generate [color=#4d9be6]oxygen[/color] to create an atmosphere.\nMountains [color=#509ce2]cool[/color] planets. Machines will keep the [color=#ae2334]temperature[/color] at a livable state.\nSettlements will generate more [color=eeeeee]humans[/color].\nTo exchange your [color=eeeeee]humans[/color] you need to pick them up from the planet.\nYou can also [color=#ed4d37]pick up objects that you placed[/color]."
	]

### CHANGING VARIABLES, RESET THERE ON RESTART ###

var OBJECT_TYPE_SUPPLY = {"FLORA_SMALL":5,"FLORA_MED":2,"FLORA_BIG":1,"OBJECT":2,"BUILDING":1,"MACHINE":1}

var PLANET_STATUS = {"PLANET_1":0,"PLANET_2":0,"PLANET_3":0,"PLANET_4":0}

var currency = 0

var focused_planet = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed("mute_music"):
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"),!AudioServer.is_bus_mute(AudioServer.get_bus_index("Music")))
	if event.is_action_pressed("mute_sound"):
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Sound"),!AudioServer.is_bus_mute(AudioServer.get_bus_index("Sound")))
	if event.is_action_pressed("toggle_tutorial"):
		SignalManager.emit_signal("tutorial_open")
	

func reset_data():
	OBJECT_TYPE_SUPPLY = {"FLORA_SMALL":5,"FLORA_MED":2,"FLORA_BIG":1,"OBJECT":2,"BUILDING":1,"MACHINE":1}
	var PLANET_STATUS = {"PLANET_1":0,"PLANET_2":0,"PLANET_3":0,"PLANET_4":0}
	currency = 0
	focused_planet = null
	
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
		
func change_planet_status(planet_id : String, value : int):
	if PLANET_STATUS.keys().has(planet_id):
		print(planet_id," - ",PLANET_STATUS[planet_id])
		PLANET_STATUS[planet_id] = value
	
	print(PLANET_STATUS)
	
	for value in PLANET_STATUS.values():
		if value == 0:
			return
	
	SignalManager.emit_signal("game_win")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
