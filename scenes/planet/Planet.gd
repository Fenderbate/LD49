extends Node2D

export(String)var planet_name = "Planet"
export(float)var temperature = 0
export(float)var atmosphere_density = 0
export(Vector2)var min_coords = Vector2(20,20)
export(Vector2)var max_coords = Vector2(100,100)
export(Vector2)var orbit_position = Vector2(0,100)
export(float)var orbit_speed = 1

export(PackedScene)var tree

export(Vector2)var camera_zoom = Vector2(1.3,1.3)

var time = 0
var orbit_start = true






# Called when the node enters the scene tree for the first time.
func _ready():
	
	orbit_position = min_coords
	
	handle_orbit()
	
	var points = []
	
	for i in range(360):
		points.append(Vector2($PlanetSurface/SurfaceCollision.shape.radius,0).rotated(deg2rad(i)))
		#print(Vector2($PlanetSurface/SurfaceCollision.shape.radius/2,0).rotated(deg2rad(i)))
	
	$Body.polygon = points
	
	print($Body.polygon.size())
	
	pass
	
	

var frequency = 10

func _physics_process(delta):
	
	
	
	global_position = orbit_position.rotated(time)
	

func _input(event):
	
	if event.is_action_pressed("left_click") and (Global.focused_planet == null || Global.focused_planet.get_ref() == self):
		return
		var t = tree.instance()
		t.global_position = get_local_mouse_position()
		add_child(t)
		
		pass
	

func handle_orbit():
	
	if orbit_start:
		$Tween.interpolate_property(self,"time",deg2rad(0),deg2rad(360),orbit_speed * 2,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
		$Tween.interpolate_property(self,"orbit_position",orbit_position,max_coords,orbit_speed,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
		#$Tween.interpolate_property(self,"orbit_position",orbit_position,max_coords,orbit_speed,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
		$Tween.start()
		
	else:
		$Tween.interpolate_property(self,"orbit_position",orbit_position,min_coords,orbit_speed,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
		#$Tween.interpolate_property(self,"orbit_position",orbit_position,min_coords,orbit_speed,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
		$Tween.start()
	

func _on_SSInteract_input_event(viewport, event, shape_idx):
	
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed:
		SignalManager.emit_signal("planet_interact",self)
	
	pass


func _on_Tween_tween_completed(object, key):
	print(key)
	if key == ":orbit_position":
		orbit_start = !orbit_start
		handle_orbit()
