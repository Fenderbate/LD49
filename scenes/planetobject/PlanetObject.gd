extends KinematicBody2D
class_name PlanetObject

# calculations
var anim_height = 0
var anim_time = 1

# interactions
var under_mouse = false

# init vars
var data = {
	"Type" : Global.OBJECT_TYPE.FLORA_SMALL,
	"OxygenDelta" : Global.OXYGEN_DELTA.NONE,
	"Sprite" : null,
	"Name" : "N/A"
}

# Called when the node enters the scene tree for the first time.
func _ready():
	look_at(get_parent().global_position)
	$SpritePivot/Sprite.texture = data["Sprite"]
	if !data["Type"] == Global.OBJECT_TYPE.MACHINE:
		$SpriteAnimator.play("none")
	else:
		$SpriteAnimator.play("base")
	
	
	$Tween.interpolate_property($SpritePivot/Sprite,"position",Vector2(0,-anim_height),Vector2(0,-16),anim_time,Tween.TRANS_EXPO,Tween.EASE_IN)
	$Tween.interpolate_property($SpritePivot/Sprite.material,"shader_param/flash_modifier",1.0,0.0,anim_time* 0.3,Tween.TRANS_CUBIC)
	$Tween.start()
	
	$LandParticleTimer.wait_time = anim_time
	$LandParticleTimer.start()
	



func _input(event):
	
	if event.is_action_pressed("left_click") and under_mouse:
		get_tree().set_input_as_handled()
		remove(true)



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
	
	Global.focused_planet.get_ref().oxygen_delta += data["OxygenDelta"]
	
