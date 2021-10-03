extends PathFollow2D

tool

export(String)var planet_name = "Planet"
export(Color)var path_color
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

#test var, delete when planet raycast works
var col_pt = Vector2()


var mat

# Called when the node enters the scene tree for the first time.
func _ready():
	
	SignalManager.connect("planet_interact",self,"on_planet_interacted")
	
	offset = rand_range(0,1000)
	
	check_temp_zone()
	
	#$OverviewShader.scale = Vector2(shader_scale, shader_scale)
	
	if Engine.editor_hint or !Engine.editor_hint:
		load_shader_assets()
	
	$Atmosphere.self_modulate = Color(1,1,1,0)
	$Body.self_modulate = Color(1,1,1,0)
	
	$SSInteract/InteractShape.shape.radius = shader_mask.get_width()/2
	$PlanetSurface/SurfaceCollision.shape.radius = (planet_sprite.get_width()/2)-5
	
	
	


func _physics_process(delta):
	
	if !Engine.editor_hint:
		
		offset += orbit_speed
		
		var first_temp_delta = temp_delta
		
		check_temp_zone()
		
		if first_temp_delta != temp_delta:
			print(planet_name,": ",first_temp_delta," - ",temp_delta)
		
		pass
		
		update()
	

func load_shader_assets():
	
	$Halo.texture = highlight_ring
	$OverviewShader/OverviewSprite.texture = shader_mask
	$OverviewShader/TextureSprite.texture = barren_shader_texture
	shader_spin_speed = rand_range(0.5,0.2)
	$Body.texture = planet_sprite
	$Atmosphere.texture = planet_atmosphere
	$Grass.texture = planet_grass
	
	
	mat = $OverviewShader/OverviewSprite.material
	
	var ratio = $OverviewShader/OverviewSprite.texture.get_size() / $OverviewShader/TextureSprite.texture.get_size()
	
	
	mat.set_shader_param("shader_texture",barren_shader_texture)
	mat.set_shader_param("speed",shader_spin_speed)
	mat.set_shader_param("ratio",ratio)
	
	pass

func check_temp_zone():
	
	
	
	var dist = position.distance_to(Vector2())
	
	if dist <= Global.SCORCH_DISTANCE:
		temp_delta = Global.TEMP_DELTA.SCORCH
		return
	elif dist >= Global.HEAT_DISTANCE and dist <= Global.CONFORT_MINIMUM:
		temp_delta = Global.TEMP_DELTA.HEAT
		return
	elif dist >= Global.CONFORT_MINIMUM and dist <= Global.CONFORT_MAXIMUM:
		temp_delta = Global.TEMP_DELTA.CONFORT
		return
	elif dist >= Global.COLD_DISTANCE:
		temp_delta = Global.TEMP_DELTA.COLD
		return
	elif dist >= Global.FREEZE_DISTANCE:
		temp_delta = Global.TEMP_DELTA.FREEZE
		return
	

func animate_overview(show_planet = true):
	
	if show_planet:
		$Tween.stop_all()
		$Tween.interpolate_property($OverviewShader/OverviewSprite,"self_modulate",$OverviewShader/OverviewSprite.self_modulate,Color(1,1,1,0),1,Tween.TRANS_EXPO)
		$Tween.interpolate_property($Halo,"self_modulate",$Halo.self_modulate,Color(1,1,1,0),1,Tween.TRANS_EXPO)
		$Tween.interpolate_property($Clouds,"modulate",$Clouds.modulate,Color(1,1,1,1),1.2,Tween.TRANS_EXPO)
		$Tween.interpolate_property($Atmosphere,"self_modulate",$Atmosphere.self_modulate,Color(1,1,1,1),1.2,Tween.TRANS_EXPO)
		$Tween.interpolate_property($Body,"self_modulate",$Body.self_modulate,Color(1,1,1,1),1,Tween.TRANS_EXPO)
		$Tween.interpolate_property($Grass,"self_modulate",$Grass.self_modulate,Color(1,1,1,1),1,Tween.TRANS_EXPO)
		$Tween.interpolate_property($Objects,"modulate",$Objects.modulate,Color(1,1,1,1),1,Tween.TRANS_EXPO)
		$Tween.start()
	else:
		$Tween.stop_all()
		$Tween.interpolate_property($OverviewShader/OverviewSprite,"self_modulate",$OverviewShader/OverviewSprite.self_modulate,Color(1,1,1,1),1,Tween.TRANS_EXPO)
		$Tween.interpolate_property($Halo,"self_modulate",$Halo.self_modulate,Color(1,1,1,1),1,Tween.TRANS_EXPO)
		$Tween.interpolate_property($Clouds,"modulate",$Clouds.modulate,Color(1,1,1,0),1.2,Tween.TRANS_EXPO)
		$Tween.interpolate_property($Atmosphere,"self_modulate",$Atmosphere.self_modulate,Color(1,1,1,0),1.2,Tween.TRANS_EXPO)
		$Tween.interpolate_property($Body,"self_modulate",$Body.self_modulate,Color(1,1,1,0),1,Tween.TRANS_EXPO)
		$Tween.interpolate_property($Grass,"self_modulate",$Grass.self_modulate,Color(1,1,1,0),1,Tween.TRANS_EXPO)
		$Tween.interpolate_property($Objects,"modulate",$Objects.modulate,Color(1,1,1,0),1,Tween.TRANS_EXPO)
		$Tween.start()
	
	
func _on_SSInteract_input_event(viewport, event, shape_idx):
	
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed :
		if Global.is_planet_null():
			SignalManager.emit_signal("planet_interact",self)
	
	pass




func _on_UIUpdateTimer_timeout():
	temperature = clamp(temperature + temp_delta, 0, Global.MAX_TEMPERATURE)
	atmosphere_density = clamp(atmosphere_density + oxygen_delta, 0, Global.MAX_ATMOSPHERE)
	if (temperature < 600 and temperature > 400) and atmosphere_density > 800:
		if !$Grass.visible and Global.check_focused_planet(self):
			$Tween.interpolate_property($Grass,"self_modulate",Color(1,1,1,0),Color(1,1,1,1),0.5,Tween.TRANS_EXPO,Tween.EASE_OUT)
			$Tween.start()
			$Grass.show()
		hospitablle = true
		mat.set_shader_param("shader_texture",terraformed_shader_texture)
		$Clouds.show()
		$Atmosphere.show()
		print($Atmosphere.visible," - ",$Atmosphere.self_modulate)
	elif temperature > 600 or temperature < 400 or atmosphere_density < 800:
		if !$Grass.visible and Global.check_focused_planet(self):
			$Tween.interpolate_property($Grass,"self_modulate",Color(1,1,1,1),Color(1,1,1,0),0.5,Tween.TRANS_EXPO,Tween.EASE_OUT)
			$Tween.start()
		hospitablle = false
		mat.set_shader_param("shader_texture",barren_shader_texture)
		$Clouds.hide()
		$Atmosphere.hide()
		
	if Global.check_focused_planet(self):
		SignalManager.emit_signal("update_planet_UI",temperature,atmosphere_density,population)
		#print(self.planet_name," update! | temp delta",temp_delta," | ", temperature," | ",atmosphere_density, " | ",population)
		
func on_planet_interacted(planet):
	if planet != self:
		$PlanetSurface.collision_layer = 0
		$PlanetSurface.collision_mask = 0
	else:
		$PlanetSurface.collision_layer = 1
		$PlanetSurface.collision_mask = 1

