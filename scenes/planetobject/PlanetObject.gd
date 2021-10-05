extends KinematicBody2D
class_name PlanetObject

# anim calculations
var anim_height = 0
var anim_time = 1.5

# interactions
var under_mouse = false

# function calculations
var MACHINE_TEMP_DELTA_CONJSTANT = 20

var MOUNTAIN_TEMP_DELTA_CONSTANT = -9

var planet = null

var can_emit = false

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
		if [Global.OBJECT_TYPE.FLORA_SMALL, Global.OBJECT_TYPE.FLORA_MED,Global.OBJECT_TYPE.FLORA_BIG].has(data["Type"]):
			add_to_group("Flora")
		if data["Type"] == Global.OBJECT_TYPE.OBJECT:
			add_to_group("Mountain")
	else:
		$SpritePivot/Sprite.hframes = 4
		$SpriteAnimator.play("base")
		add_to_group("Machine")
	
	
	$Tween.interpolate_property($SpritePivot/Sprite,"position",Vector2(0,-anim_height),Vector2(0,-16),anim_time,Tween.TRANS_EXPO,Tween.EASE_IN)
	$Tween.interpolate_property($SpritePivot/Sprite.material,"shader_param/flash_modifier",1.0,0.0,anim_time* 0.3,Tween.TRANS_CUBIC)
	$Tween.start()
	
	$Teleport.play()
	$Land.play()
	
	$LandParticleTimer.wait_time = anim_time
	$LandParticleTimer.start()
	



func _input(event):
	
	if event.is_action_pressed("left_click") and under_mouse:
		get_tree().set_input_as_handled()
		remove(true)
		SignalManager.emit_signal("reset_select_index")

func machine_function(temperature):
	
	var temp = 0
			  
	var temp_diff = temperature - (Global.MAX_TEMPERATURE / 2)
	
	
	var polarity = 0 if temp_diff == 0 else -(temp_diff / abs(temp_diff))
	
	temp = MACHINE_TEMP_DELTA_CONJSTANT if abs((Global.MAX_TEMPERATURE / 2) - planet.temperature) > MACHINE_TEMP_DELTA_CONJSTANT else abs(500 - planet.temperature)
	
	temp *= polarity
	
	if can_emit:
		if temp > 0:
			if !$HeatParticles.emitting: $HeatParticles.emitting = true
			if $CoolParticles.emitting: $CoolParticles.emitting = false
		elif temp < 0:
			if $HeatParticles.emitting: $HeatParticles.emitting = false
			if !$CoolParticles.emitting: $CoolParticles.emitting = true
		else:
			if $HeatParticles.emitting: $HeatParticles.emitting = false
			if $CoolParticles.emitting: $CoolParticles.emitting = false
	
	return temp

func mountain_function(temperature):
	
	return MOUNTAIN_TEMP_DELTA_CONSTANT if(temperature > Global.TEMP_LIMITS.FREEZE) else 0
	


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
		
		$Teleport.play()
		
		yield($Tween,"tween_all_completed")
		
		Global.OBJECT_TYPE_SUPPLY[Global.OBJECT_TYPE.keys()[data["Type"]]] += 1
		SignalManager.emit_signal("update_supply_display")
	
	queue_free()

func _on_PlanetObject_mouse_entered():
	under_mouse = true

func _on_PlanetObject_mouse_exited():
	under_mouse = false


func _on_BuildingSpawnTimer_timeout():
	if planet.habitable and planet.population < planet.max_population:
		var p = Global.person.instance()
		
		p.position = position
		
		get_parent().add_child(p)
		
		$BuildingSpawnTimer.wait_time = rand_range(1.5,3)
	$BuildingSpawnTimer.start()
	


func _on_LandParticleTimer_timeout():
	pass

func _on_Tween_tween_completed(object, key):
	
	if key == ":position":
		$AnimationPlayer.play("squash")
		$Particles.emitting = true
		input_pickable = true
		if data["Type"] == Global.OBJECT_TYPE.BUILDING:
			$BuildingSpawnTimer.start()
	
func _on_Land_finished():
	can_emit = true
