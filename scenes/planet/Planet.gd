extends PathFollow2D

export(String)var planet_name = "Planet"
export(float)var temperature = 0
export(float)var atmosphere_density = 0
export(float)var population = 0
export(float)var orbit_speed = 1
export(Vector2)var camera_zoom = Vector2(1.3,1.3)
export(float)var shader_scale


var temp_delta = 0
var oxygen_delta = 0




# Called when the node enters the scene tree for the first time.
func _ready():
	
	check_temp_zone()
	
	$OverviewShader.scale = Vector2(shader_scale, shader_scale)
	
	print(planet_name," - ",temp_delta)
	
	
	


func _physics_process(delta):
	
	offset += orbit_speed
	
	pass
	
	

	


func check_temp_zone():
	
	var dist = position.distance_to(Vector2())
	
	
	if dist <= Global.SCORCH_DISTANCE:
		temp_delta = Global.TEMP_DELTA.SCORCH
		print(dist," ",temp_delta)
		return
	elif dist >= Global.HEAT_DISTANCE and dist <= Global.CONFORT_MINIMUM:
		temp_delta = Global.TEMP_DELTA.HEAT
		print(dist," ",temp_delta)
		return
	elif dist >= Global.CONFORT_MINIMUM and dist <= Global.CONFORT_MAXIMUM:
		temp_delta = Global.TEMP_DELTA.CONFORT
		print(dist," ",temp_delta)
		return
	elif dist >= Global.COLD_DISTANCE:
		temp_delta = Global.TEMP_DELTA.COLD
		print(dist," ",temp_delta)
		return
	elif dist >= Global.FREEZE_DISTANCE:
		temp_delta = Global.TEMP_DELTA.FREEZE
		print(dist," ",temp_delta)
		return
	

func animate_overview(show_planet = true):
	
	print("asdasdasdasd")
	
	if show_planet:
		$Tween.interpolate_property($OverviewShader,"modulate",$OverviewShader.modulate,Color(1,1,1,0),1,Tween.TRANS_EXPO)
		$Tween.interpolate_property($Clouds,"modulate",$Clouds.modulate,Color(1,1,1,1),1.2,Tween.TRANS_EXPO)
		$Tween.interpolate_property($Atmosphere,"modulate",$Atmosphere.modulate,Color(1,1,1,1),1.2,Tween.TRANS_EXPO)
		$Tween.start()
	else:
		$Tween.interpolate_property($OverviewShader,"modulate",$OverviewShader.modulate,Color(1,1,1,1),1,Tween.TRANS_EXPO)
		$Tween.interpolate_property($Clouds,"modulate",$Clouds.modulate,Color(1,1,1,0),1.2,Tween.TRANS_EXPO)
		$Tween.interpolate_property($Atmosphere,"modulate",$Atmosphere.modulate,Color(1,1,1,0),1.2,Tween.TRANS_EXPO)
		$Tween.start()
	
	

	

	

func _on_SSInteract_input_event(viewport, event, shape_idx):
	
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed :
		if Global.is_planet_null():
			SignalManager.emit_signal("planet_interact",self)
	
	pass




func _on_UIUpdateTimer_timeout():
	temperature = clamp(temperature + temp_delta, 0, Global.MAX_TEMPERATURE)
	atmosphere_density = clamp(atmosphere_density + oxygen_delta, 0, Global.MAX_ATMOSPHERE)
	
	
	if Global.check_focused_planet(self):
		SignalManager.emit_signal("update_planet_UI",temperature,atmosphere_density,population)
		#print(self.planet_name," update! | temp delta",temp_delta," | ", temperature," | ",atmosphere_density, " | ",population)
