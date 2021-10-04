extends KinematicBody2D
class_name PlanetObject

# anim calculations
var anim_height = 0
var anim_time = 1

# interactions
var under_mouse = false

# function calculations
var MACHINE_TEMP_DELTA_CONJSTANT = 5
var new_machine_temp_delta = 0
var machine_temp_delta = 0
var PLANET_TEMPS = {"COLD":-1,"NORM":0,"HOT":1}
var current_planet_temp = PLANET_TEMPS.NORM
var current_machine_temp = PLANET_TEMPS.NORM

var planet = null

# init vars
var data = {
	"Type" : Global.OBJECT_TYPE.FLORA_SMALL,
	"OxygenDelta" : Global.OXYGEN_DELTA.NONE,
	"Sprite" : null,
	"Name" : "N/A"
}

# Called when the node enters the scene tree for the first time.
func _ready():
	planet = get_parent().get_parent()
	
	look_at(get_parent().global_position)
	$SpritePivot/Sprite.texture = data["Sprite"]
	if !data["Type"] == Global.OBJECT_TYPE.MACHINE:
		$SpriteAnimator.play("none")
	else:
		$SpriteAnimator.play("base")
	
	Global.focused_planet.get_ref().oxygen_delta += data["OxygenDelta"]
	
	
	$Tween.interpolate_property($SpritePivot/Sprite,"position",Vector2(0,-anim_height),Vector2(0,-16),anim_time,Tween.TRANS_EXPO,Tween.EASE_IN)
	$Tween.interpolate_property($SpritePivot/Sprite.material,"shader_param/flash_modifier",1.0,0.0,anim_time* 0.3,Tween.TRANS_CUBIC)
	$Tween.start()
	
	$LandParticleTimer.wait_time = anim_time
	$LandParticleTimer.start()
	



func _input(event):
	
	if event.is_action_pressed("left_click") and under_mouse:
		get_tree().set_input_as_handled()
		remove(true)

func machine_function():
	
	
	
	if planet.temperature < Global.TEMP_LIMITS.CONFORT_MIN and current_planet_temp != PLANET_TEMPS.COLD:
		print("new temp is cold")
	elif planet.temperature in range(Global.TEMP_LIMITS.CONFORT_MIN,Global.TEMP_LIMITS.CONFORT_MAX) and current_planet_temp != PLANET_TEMPS.NORM:
		print("new temp is normal")
	elif planet.temperature < Global.TEMP_LIMITS.CONFORT_MAX and current_planet_temp != PLANET_TEMPS.HOT:
		print("new temp is hot")
	
	if current_machine_temp != current_planet_temp:
		
		planet.temp_delta -= machine_temp_delta
		new_machine_temp_delta = -MACHINE_TEMP_DELTA_CONJSTANT
		planet.temp_delta += machine_temp_delta
		


func remove(pickup = false):
	if Global.is_planet_null():
		return
	Global.focused_planet.get_ref().oxygen_delta -= data["OxygenDelta"]
	if pickup:
		
	
		input_pickable = false
		collision_layer = 0
		collision_mask = 0
		
		$Tween.stop_all()
		$Tween.interpolate_property($SpritePivot/Sprite,"scale",$SpritePivot/Sprite.scale,Vector2(0,0),0.5,Tween.TRANS_CUBIC)
		$Tween.interpolate_property($SpritePivot/Sprite.material,"shader_param/flash_modifier",0,1,0.25,Tween.TRANS_CUBIC)
		$Tween.start()
		
		yield($Tween,"tween_all_completed")
		
		Global.OBJECT_TYPE_SUPPLY[Global.OBJECT_TYPE.keys()[data["Type"]]] += 1
		SignalManager.emit_signal("update_supply_display")
	
	queue_free()

func _on_PlanetObject_mouse_entered():
	under_mouse = true

func _on_PlanetObject_mouse_exited():
	under_mouse = false


func _on_BuildingSpawnTimer_timeout():
	var p = Global.person.instance()
	
	p.position = position
	
	get_parent().add_child(p)
	


func _on_LandParticleTimer_timeout():
	$AnimationPlayer.play("squash")
	$Particles.emitting = true


func _on_Tween_tween_completed(object, key):
	if key == ":position":
		if data["Type"] == Global.OBJECT_TYPE.BUILDING:
			$BuildingSpawnTimer.start()
	
	
	
