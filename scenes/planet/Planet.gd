extends PathFollow2D

tool

export(String)var planet_name = "Planet"
export(String)var planet_id = "Planet_1"
export(Color)var path_color
export(Curve)var atmosphere_alpha_curve
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

var habitable = false

var dist = Vector2()

var col_pt = Vector2()

var mat

var tut_open = false

var atmosphere_ideal = false
var temp_ideal = false

# Called when the node enters the scene tree for the first time.
func _ready():
	
	SignalManager.connect("planet_interact",self,"on_planet_interacted")
	SignalManager.connect("game_win",self,"on_game_won")
	SignalManager.connect("game_lose",self,"on_game_lost")
	SignalManager.connect("add_person",self,"on_person_added")
	SignalManager.connect("remove_person",self,"on_person_removed")
	SignalManager.connect("tutorial_open",self,"on_tutorial_opened")
	SignalManager.connect("tutorial_close",self,"on_tutorial_closed")
	
	
	
	offset = rand_range(0,1000)
	
	check_temp_zone()
	
	#$OverviewShader.scale = Vector2(shader_scale, shader_scale)
	
	if Engine.editor_hint or !Engine.editor_hint:
		load_shader_assets()
	
	$Atmosphere.self_modulate = Color(1,1,1,0)
	$Body.modulate = Color(1,1,1,0)
	$Body/ClimateParticles.process_material.emission_sphere_radius = $Body.texture.get_size().x/2
	
	$SSInteract/InteractShape.shape.radius = shader_mask.get_width()/2
	$PlanetSurface/SurfaceCollision.shape.radius = (planet_sprite.get_width()/2)-10
	
	$OverviewShader/OverviewSprite/Warning.position = shader_mask.get_size().x*0.75 * Vector2(1,-1).normalized()

func _physics_process(delta):
	
	if !Engine.editor_hint:
		
		if Global.check_focused_planet(self):
			pass
			
		
		if !tut_open:
			offset += orbit_speed
		
		$Atmosphere.self_modulate.a = atmosphere_alpha_curve.interpolate(atmosphere_density / Global.MAX_ATMOSPHERE)
		
		if !atmosphere_ideal or !temp_ideal:
			$OverviewShader/OverviewSprite/Warning.show()
		else:
			$OverviewShader/OverviewSprite/Warning.hide()
		
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
	
	var new_temp_delta = 0
	
	dist = (global_position - position).distance_to(Vector2() - global_position)
	
	if dist <= Global.SCORCH_DISTANCE:
		new_temp_delta = Global.TEMP_DELTA.SCORCH
	elif dist >= Global.HEAT_DISTANCE and dist <= Global.CONFORT_MINIMUM:
		new_temp_delta = Global.TEMP_DELTA.HEAT
	elif dist >= Global.CONFORT_MINIMUM and dist <= Global.CONFORT_MAXIMUM:
		new_temp_delta = Global.TEMP_DELTA.CONFORT
	elif dist >= Global.COLD_DISTANCE:
		new_temp_delta = Global.TEMP_DELTA.COLD
	elif dist >= Global.FREEZE_DISTANCE:
		new_temp_delta = Global.TEMP_DELTA.FREEZE
	
	return new_temp_delta
	

func animate_overview(show_planet = true):
	
	if show_planet:
		$Tween.stop_all()
		$Tween.interpolate_property($OverviewShader/OverviewSprite,"modulate",$OverviewShader/OverviewSprite.modulate,Color(1,1,1,0),1,Tween.TRANS_EXPO)
		$Tween.interpolate_property($Halo,"self_modulate",$Halo.self_modulate,Color(1,1,1,0),1,Tween.TRANS_EXPO)
		$Tween.interpolate_property($Clouds,"modulate",$Clouds.modulate,Color(1,1,1,1),1.2,Tween.TRANS_EXPO)
		$Tween.interpolate_property($Atmosphere,"modulate",$Atmosphere.modulate,Color(1,1,1,1),1.2,Tween.TRANS_EXPO)
		$Tween.interpolate_property($Body,"modulate",$Body.modulate,Color(1,1,1,1),1,Tween.TRANS_EXPO)
		$Tween.interpolate_property($Grass,"self_modulate",$Grass.self_modulate,Color(1,1,1,1),1,Tween.TRANS_EXPO)
		$Tween.interpolate_property($Objects,"modulate",$Objects.modulate,Color(1,1,1,1),1,Tween.TRANS_EXPO)
		$Tween.start()
	else:
		$Tween.stop_all()
		$Tween.interpolate_property($OverviewShader/OverviewSprite,"modulate",$OverviewShader/OverviewSprite.modulate,Color(1,1,1,1),1,Tween.TRANS_EXPO)
		$Tween.interpolate_property($Halo,"self_modulate",$Halo.self_modulate,Color(1,1,1,1),1,Tween.TRANS_EXPO)
		$Tween.interpolate_property($Clouds,"modulate",$Clouds.modulate,Color(1,1,1,0),1.2,Tween.TRANS_EXPO)
		$Tween.interpolate_property($Atmosphere,"modulate",$Atmosphere.modulate,Color(1,1,1,0),1.2,Tween.TRANS_EXPO)
		$Tween.interpolate_property($Body,"modulate",$Body.modulate,Color(1,1,1,0),1,Tween.TRANS_EXPO)
		$Tween.interpolate_property($Grass,"self_modulate",$Grass.self_modulate,Color(1,1,1,0),1,Tween.TRANS_EXPO)
		$Tween.interpolate_property($Objects,"modulate",$Objects.modulate,Color(1,1,1,0),1,Tween.TRANS_EXPO)
		$Tween.start()
	
	
func _on_SSInteract_input_event(viewport, event, shape_idx):
	
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed :
		if Global.is_planet_null():
			SignalManager.emit_signal("planet_interact",self)
	
	pass




func _on_UIUpdateTimer_timeout():
	
	temperature = clamp(temperature + check_temp_zone(), 0, Global.MAX_TEMPERATURE)
	
	for object in $Objects.get_children(): #get_tree().get_nodes_in_group("Machine")
		if object.is_in_group("Machine"):
			temperature += object.machine_function(temperature)
			
			temperature = clamp(temperature, 0, Global.MAX_TEMPERATURE)
		elif object.is_in_group("Mountain"):
			temperature += object.mountain_function(temperature)
		elif object.is_in_group("Flora"):
			atmosphere_density = clamp(atmosphere_density + object.data["OxygenDelta"], 0, Global.MAX_ATMOSPHERE)
	
	if (temperature < Global.TEMP_LIMITS.CONFORT_MAX and temperature > Global.TEMP_LIMITS.CONFORT_MIN) and atmosphere_density > 800:
		mat.set_shader_param("shader_texture",terraformed_shader_texture)
		$Clouds.show()
		
		habitable = true
		
		if !$Grass.visible and Global.check_focused_planet(self):
			Global.change_planet_status(planet_id,1)
			$Grass.show()
			$Tween.interpolate_property($Grass.material,"shader_param/flash_modifier",1,0,1,Tween.TRANS_EXPO,Tween.EASE_OUT)
			$Tween.start()
			yield($Tween,"tween_completed")
		
	elif temperature > Global.TEMP_LIMITS.CONFORT_MAX or temperature < Global.TEMP_LIMITS.CONFORT_MIN or atmosphere_density < 800:
		mat.set_shader_param("shader_texture",barren_shader_texture)
		$Clouds.hide()
		
		habitable = false
		
		if $Grass.visible and Global.check_focused_planet(self):
			Global.change_planet_status(planet_id,0)
			$Tween.interpolate_property($Grass,"self_modulate",$Grass.self_modulate,Color(1,1,1,0),0.75,Tween.TRANS_EXPO,Tween.EASE_OUT)
			$Tween.start()
			yield($Tween,"tween_completed")
			$Grass.hide()
	
	if temperature > Global.TEMP_LIMITS.CONFORT_MAX or temperature < Global.TEMP_LIMITS.CONFORT_MIN:
		temp_ideal = false
	else:
		temp_ideal = true
	
	if atmosphere_density < 800:
		atmosphere_ideal = false
	else:
		atmosphere_ideal = true
	
	if temperature >= Global.TEMP_LIMITS.SCORCH or temperature <= Global.TEMP_LIMITS.FREEZE:
		if temperature >= Global.TEMP_LIMITS.SCORCH:
			$Body/ClimateParticles.texture = load("res://sprites/fire_particle.png")
		else:
			$Body/ClimateParticles.texture = load("res://sprites/ice_particle.png")
		if !$Body/ClimateParticles.emitting:
			$Body/ClimateParticles.emitting = true
	else:
		if $Body/ClimateParticles.emitting:
			$Body/ClimateParticles.emitting = false
		
	if Global.check_focused_planet(self):
		SignalManager.emit_signal("update_planet_UI",temperature,atmosphere_density,shader_spin_speed,dist,population)
		
		
func on_planet_interacted(planet):
	if planet != self:
		$PlanetSurface.collision_layer = 0
		$PlanetSurface.collision_mask = 0
	else:
		$PlanetSurface.collision_layer = 1
		$PlanetSurface.collision_mask = 1

func on_person_added(other_planet_id):
	if other_planet_id == planet_id:
		population += 1

func on_person_removed(other_planet_id):
	if other_planet_id == planet_id:
		population -= 1

func on_tutorial_opened():
	tut_open = true

func on_tutorial_closed():
	tut_open = false

func on_game_won():
	$UIUpdateTimer.paused = true

func on_game_lost():
	$UIUpdateTimer.paused = true


