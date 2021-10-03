extends PathFollow2D

export(String)var planet_name = "Planet"
export(float)var temperature = 0
export(float)var atmosphere_density = 0
export(float)var population = 0
export(float)var orbit_speed = 1
export(Vector2)var camera_zoom = Vector2(1.3,1.3)
export(Texture)var highlight_ring
export(Texture)var shader_mask
export(Texture)var barren_shader_texture
export(Texture)var terraformed_shader_texture
export(float)var shader_spin_speed = 1
export(Texture)var planet_sprite
export(Texture)var planet_atmosphere
export(Texture)var planet_grass


var temp_delta = 0
var oxygen_delta = 0

var hospitablle = false




# Called when the node enters the scene tree for the first time.
func _ready():
	
	check_temp_zone()
	
	#$OverviewShader.scale = Vector2(shader_scale, shader_scale)
	
	load_shader_assets()
	
	print(planet_name," - ",temp_delta)
	
	$Atmosphere.modulate = Color(1,1,1,0)
	$Body.modulate = Color(1,1,1,0)
	
	$SSInteract/InteractShape.shape.radius = shader_mask.get_width()/2
	
	
	


func _physics_process(delta):
	
	offset += orbit_speed
	
	
	pass
	
	
	

func load_shader_assets():
	
	$Halo.texture = highlight_ring
	$OverviewShader/OverviewSprite.texture = shader_mask
	$OverviewShader/TextureSprite.texture = barren_shader_texture
	shader_spin_speed = rand_range(0.5,0.2)
	$Body.texture = planet_sprite
	$Atmosphere.texture = planet_atmosphere
	$Grass.texture = planet_grass
	
	
	var mat = $OverviewShader/OverviewSprite.material
	
	var ratio = $OverviewShader/OverviewSprite.texture.get_size() / $OverviewShader/TextureSprite.texture.get_size()
	
	
	mat.set_shader_param("shader_texture",barren_shader_texture)
	mat.set_shader_param("speed",shader_spin_speed)
	mat.set_shader_param("ratio",ratio)
	
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
	
	if show_planet:
		$Tween.stop_all()
		$Tween.interpolate_property($OverviewShader,"self_modulate",$OverviewShader.self_modulate,Color(1,1,1,0),1,Tween.TRANS_EXPO)
		$Tween.interpolate_property($Clouds,"self_modulate",$Clouds.self_modulate,Color(1,1,1,1),1.2,Tween.TRANS_EXPO)
		$Tween.interpolate_property($Atmosphere,"self_modulate",$Atmosphere.self_modulate,Color(1,1,1,1),1.2,Tween.TRANS_EXPO)
		$Tween.interpolate_property($Body,"self_modulate",$Body.self_modulate,Color(1,1,1,1),1,Tween.TRANS_EXPO)
		$Tween.start()
	else:
		$Tween.stop_all()
		$Tween.interpolate_property($OverviewShader,"self_modulate",$OverviewShader.self_modulate,Color(1,1,1,1),1,Tween.TRANS_EXPO)
		$Tween.interpolate_property($Clouds,"self_modulate",$Clouds.self_modulate,Color(1,1,1,0),1.2,Tween.TRANS_EXPO)
		$Tween.interpolate_property($Atmosphere,"self_modulate",$Atmosphere.self_modulate,Color(1,1,1,0),1.2,Tween.TRANS_EXPO)
		$Tween.interpolate_property($Body,"self_modulate",$Body.self_modulate,Color(1,1,1,0),1,Tween.TRANS_EXPO)
		$Tween.start()
	
	

	

	

func _on_SSInteract_input_event(viewport, event, shape_idx):
	
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed :
		if Global.is_planet_null():
			SignalManager.emit_signal("planet_interact",self)
	
	pass




func _on_UIUpdateTimer_timeout():
	temperature = clamp(temperature + temp_delta, 0, Global.MAX_TEMPERATURE)
	atmosphere_density = clamp(atmosphere_density + oxygen_delta, 0, Global.MAX_ATMOSPHERE)
	if (temperature < 600 and temperature > 400) and atmosphere_density > 800 and !$Grass.visible and Global.check_focused_planet(self):
		$Tween.interpolate_property($Grass,"self_modulate",Color(1,1,1,0),Color(1,1,1,1),0.5,Tween.TRANS_EXPO,Tween.EASE_OUT)
		$Tween.start()
		$Grass.show()
		
	if Global.check_focused_planet(self):
		SignalManager.emit_signal("update_planet_UI",temperature,atmosphere_density,population)
		#print(self.planet_name," update! | temp delta",temp_delta," | ", temperature," | ",atmosphere_density, " | ",population)
		


