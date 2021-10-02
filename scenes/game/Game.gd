extends Node2D


var camera_target = null

var focusing_on_planet = false


# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.connect("planet_interact",self,"_on_planet_interacted")


func _physics_process(delta):
	
	pass
	

func focus_on_planet():
	
	$Camera/Tween.interpolate_property($Camera,"zoom",$Camera.zoom,camera_target.get_ref().camera_zoom,1,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	$Camera/Tween.start()
	$Camera/Tween.interpolate_property($Camera,"position",$Camera.position,camera_target.get_ref().global_position,1,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	$Camera/Tween.start()
	
	pass
	

func camera_follow_planet():
	
	pass
	

func _on_planet_interacted(target_planet):
	
	camera_target = target_planet
	
	focus_on_planet()
	
	pass
