extends Node2D

export(Color)var sun_color

var default_camera_zoom = Vector2(10,10)
var focusing_on_planet = false
var moving_camera = false

var time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.connect("planet_interact",self,"_on_planet_interacted")


func _physics_process(delta):
	
	update()
	
	if moving_camera and focusing_on_planet:
		
		if $Camera/MoveTimer.is_stopped():
			$Camera/MoveTimer.start()
		
		var dist = $Camera.global_position.distance_to(Global.focused_planet.get_ref().global_position)
		
		if dist > 80.0:
			print("wat - ",$Camera.global_position.distance_to(Global.focused_planet.get_ref().global_position))
			$Camera.global_position += (Global.focused_planet.get_ref().global_position - $Camera.global_position) / 4
		else:
			$Camera.global_position = Global.focused_planet.get_ref().global_position
		moving_camera = true
		
		
	if focusing_on_planet and !moving_camera:
		camera_follow_planet()
	
	pass
	
func _input(event):
	
	if event.is_action_pressed("esc"):
		if(focusing_on_planet):
			leave_planet_focus()
			Global.clear_planet_focus()
			
	

func _draw():
	
	draw_circle(Vector2(),256,sun_color)

func focus_on_planet():
	
	focusing_on_planet = true
	moving_camera = true
	$Camera/Tween.interpolate_property($Camera,"zoom",$Camera.zoom,Global.focused_planet.get_ref().camera_zoom,1,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	#$Camera/Tween.interpolate_property($Camera,"position",$Camera.position,Global.focused_planet.get_ref().global_position,1,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	$Tween.interpolate_property($BG,"self_modulate",$BG.self_modulate,Color(1,1,1,0),1)
	$Camera/Tween.start()
	
	

func leave_planet_focus():
	
	SignalManager.emit_signal("planet_focus_leave")
	focusing_on_planet = false
	$Camera/Tween.interpolate_property($Camera,"zoom",$Camera.zoom,default_camera_zoom,1,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	$Camera/Tween.interpolate_property($Camera,"position",$Camera.position,Vector2(0,0),1,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	$Tween.interpolate_property($BG,"self_modulate",$BG.self_modulate,Color(1,1,1,1),1)
	$Camera/Tween.start()
	

func camera_follow_planet():
	
	$Camera.position = Global.focused_planet.get_ref().global_position
	
	pass
	


func _on_planet_interacted(target_planet):
	
	Global.set_planet_focus(target_planet)
	
	focus_on_planet()
	
	pass


func _on_Tween_tween_completed(object, key):
	if key == ":zoom" and focusing_on_planet:
		SignalManager.emit_signal("planet_focus_enter")


func _on_MoveTimer_timeout():
	moving_camera = false
