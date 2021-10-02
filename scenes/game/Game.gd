extends Node2D


var default_camera_zoom = Vector2(10,10)
var focusing_on_planet = false


# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.connect("planet_interact",self,"_on_planet_interacted")


func _physics_process(delta):
	
	if(focusing_on_planet):
		camera_follow_planet()
	
	pass
	
func _input(event):
	
	if event.is_action_pressed("esc"):
		if(focusing_on_planet):
			leave_planet_focus()
			
	

func focus_on_planet():
	
	focusing_on_planet = true
	$Camera/Tween.interpolate_property($Camera,"zoom",$Camera.zoom,Global.focused_planet.get_ref().camera_zoom,1,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	$Camera/Tween.interpolate_property($Camera,"position",$Camera.position,Global.focused_planet.get_ref().global_position,1,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	$Camera/Tween.start()
	
	

func leave_planet_focus():
	
	focusing_on_planet = false
	$Camera/Tween.interpolate_property($Camera,"zoom",$Camera.zoom,default_camera_zoom,1,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	$Camera/Tween.interpolate_property($Camera,"position",$Camera.position,Vector2(0,0),1,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	$Camera/Tween.start()
	

func camera_follow_planet():
	
	$Camera.position = Global.focused_planet.get_ref().global_position
	
	pass
	

func _on_planet_interacted(target_planet):
	
	Global.set_planet_focus(target_planet)
	
	focus_on_planet()
	
	pass


func _on_Tween_tween_completed(object, key):
	if key == ":position":
		pass
