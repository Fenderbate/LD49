extends CanvasLayer

var object = preload("res://scenes/planetobject/PlanetObject.tscn")
var item_holder = preload("res://scenes/itemholder/ItemHolder.tscn")

export(NodePath)var timer

var planet_objects = {
	"bush_1" : {"Texture":preload("res://sprites/bush_1.png"),"Type":Global.OBJECT_TYPE.FLORA_SMALL,"Cost":Global.OBJECT_TYPE_COST.FLORA_SMALL,"OxygenDelta":Global.OXYGEN_DELTA.SMALL, "Tooltip":Global.OBJECT_TOOLTIP.FLORA_SMALL},
	"tree_1" : {"Texture":preload("res://sprites/tree_1.png"),"Type":Global.OBJECT_TYPE.FLORA_MED,"Cost":Global.OBJECT_TYPE_COST.FLORA_MED,"OxygenDelta":Global.OXYGEN_DELTA.MED, "Tooltip":Global.OBJECT_TOOLTIP.FLORA_MED},
	"tree_2" : {"Texture":preload("res://sprites/tree_2.png"),"Type":Global.OBJECT_TYPE.FLORA_BIG,"Cost":Global.OBJECT_TYPE_COST.FLORA_BIG,"OxygenDelta":Global.OXYGEN_DELTA.BIG, "Tooltip":Global.OBJECT_TOOLTIP.FLORA_BIG},
	"mountain_1" : {"Texture":preload("res://sprites/mountain_1.png"),"Type":Global.OBJECT_TYPE.OBJECT,"Cost":Global.OBJECT_TYPE_COST.OBJECT,"OxygenDelta":Global.OXYGEN_DELTA.NONE, "Tooltip":Global.OBJECT_TOOLTIP.OBJECT},
	"house_1" : {"Texture":preload("res://sprites/house_1.png"),"Type":Global.OBJECT_TYPE.BUILDING,"Cost":Global.OBJECT_TYPE_COST.BUILDING,"OxygenDelta":Global.OXYGEN_DELTA.NONE, "Tooltip":Global.OBJECT_TOOLTIP.BUILDING},
	"machine_1" : {"Texture":preload("res://sprites/temperature_machine_1.png"),"Type":Global.OBJECT_TYPE.MACHINE,"Cost":Global.OBJECT_TYPE_COST.MACHINE,"OxygenDelta":Global.OXYGEN_DELTA.NEG_BIG, "Tooltip":Global.OBJECT_TOOLTIP.MACHINE}
}


var select_index = null

var spawn_point = Vector2()

var tutorial_index = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Container.hide()
	SignalManager.connect("planet_focus_enter",self,"on_planet_focus_entered")
	SignalManager.connect("planet_focus_leave",self,"on_planet_focus_left")
	SignalManager.connect("update_planet_UI",self,"on_planet_ui_updated")
	SignalManager.connect("update_supply_display",self,"update_supply_display")
	SignalManager.connect("show_tooltip",self,"on_tooltip_shown")
	SignalManager.connect("hide_tooltip",self,"on_tooltip_hidden")
	SignalManager.connect("reset_select_index",self,"on_select_index_reset")
	SignalManager.connect("tutorial_open",self,"on_tutorial_open")
	
	SignalManager.connect("game_win",self,"on_game_won")
	SignalManager.connect("game_lose",self,"on_game_lost")
	
	$TutorialContainer/VBoxContainer/TutorialLabel.bbcode_text = Global.TUTORIAL_TEXT[tutorial_index]
	
	for item in planet_objects:
		
		var btn = item_holder.instance()
		btn.icon = planet_objects[item]["Texture"]
		btn.type = planet_objects[item]["Type"]
		btn.cost = planet_objects[item]["Cost"]
		btn.tooltip = planet_objects[item]["Tooltip"]
		btn.obj_name = item
		$Container/ItemContainer/GridContainer.add_child(btn)
		btn.get_node("SelectButton").connect("button_down",self,"on_object_button_pressed",[btn.type])
		btn.get_node("AddButton").connect("button_down",self,"on_object_add_button_pressed",[btn.type])
	
	SignalManager.emit_signal("update_supply_display")
	
	yield(get_tree(),"idle_frame")
	$TutorialContainer.show()
	
func _physics_process(delta):
	
	$TimeContainer/TimeLabel.text = str(int(get_node(timer).time_left) / 60,":",int(get_node(timer).time_left) % 60,".",str(get_node(timer).time_left).substr(4,2))
	
func _unhandled_input(event):
	
	if Global.is_planet_null() or !$Container.visible:
		return
	
	if event.is_action_pressed("left_click"):
		var planet = Global.focused_planet.get_ref()
		
		var mouse_pos = Global.focused_planet.get_ref().get_global_mouse_position()
		
		var space_state = get_viewport().get_world_2d().direct_space_state
		var result = space_state.intersect_ray(mouse_pos, planet.global_position, [self], 1)
		
		if result:
			spawn_point = result["position"] - planet.global_position
			planet.col_pt = spawn_point
			spawn_object((result["position"]).distance_to(mouse_pos))

	

func spawn_object(height):
	
	if select_index == null:
		return
	
	if Global.OBJECT_TYPE_SUPPLY.values()[select_index] > 0:
		
		Global.OBJECT_TYPE_SUPPLY[Global.OBJECT_TYPE_SUPPLY.keys()[select_index]] -= 1
	
		var obj = object.instance()
		var data = planet_objects.values()[select_index]
		obj.position = spawn_point#Global.focused_planet.get_ref().get_local_mouse_position()
		obj.data["Type"] = data["Type"]
		obj.data["Sprite"] = data["Texture"]
		obj.data["Name"] = select_index
		obj.data["OxygenDelta"] = data["OxygenDelta"]
		obj.anim_height = abs(height)
		
		Global.focused_planet.get_ref().get_node("Objects").add_child(obj)
		
		SignalManager.emit_signal("update_supply_display")
	

func update_supply_display():
	
	for item_holder in $Container/ItemContainer/GridContainer.get_children():
		item_holder.get_node("ItemCountLabel").text = str( Global.OBJECT_TYPE_SUPPLY[Global.OBJECT_TYPE_SUPPLY.keys()[item_holder.type]] )
		$Container/CurrencyContainer/CurrencyLabel.text = str(Global.currency)

func on_planet_focus_entered():
	$Container.show()
	$Container/NamePanel/NameLabel.text = Global.focused_planet.get_ref().planet_name
	SignalManager.emit_signal("set_object_selection_focus",select_index)

func on_planet_focus_left():
	$Container.hide()

func on_planet_ui_updated(temperature,atmosphere,rotation_speed,distance,population):
	$Container/InfoPanel/VBoxContainer/OxygenDisplay/OxygenSlider.value = atmosphere
	$Container/InfoPanel/VBoxContainer/TempDisplay/TempSlider.value = temperature
	$Container/InfoPanel/VBoxContainer/RotationSpeedDisplay/RotationLabel.text = str("Rot. speed: ",round(rotation_speed*1000)," km/s")
	$Container/InfoPanel/VBoxContainer/SunDistanceDisplay/DistanceLabel.text = str("Distance: ",round(distance)," km")
	$Container/InfoPanel/VBoxContainer/PopulationDisplay/PopulationLabel.text = str("Population: ",population)

func on_object_button_pressed(type):
	select_index = type
	print(name)

func on_object_add_button_pressed(type):
	
	if Global.OBJECT_TYPE_COST[Global.OBJECT_TYPE_COST.keys()[type]] <= Global.currency:
		Global.OBJECT_TYPE_SUPPLY[Global.OBJECT_TYPE_SUPPLY.keys()[type]] += 1
		Global.currency -= Global.OBJECT_TYPE_COST[Global.OBJECT_TYPE_COST.keys()[type]]
		SignalManager.emit_signal("update_supply_display")
		
		

func on_tooltip_shown(tooltip):
	$Container/TooltipContainer.show()
	$Container/TooltipContainer/TooltipLabel.text = tooltip

func on_tooltip_hidden():
	$Container/TooltipContainer.hide()

func on_select_index_reset():
	select_index = null

func on_game_won():
	$GameWonContainer.show()

func on_game_lost():
	$GameLostContariner.show()


func _on_LostButton_button_down():
	$GameLostContariner.hide()


func _on_WinButton_button_down():
	$GameWonContainer.hide()


func _on_Close_button_down():
	$TutorialContainer.hide()


func _on_Prev_button_down():
	if tutorial_index > 0:
		tutorial_index -= 1
		$TutorialContainer/VBoxContainer/HBoxContainer2/Next.self_modulate = Color(1,1,1,1)
		$TutorialContainer/VBoxContainer/TutorialLabel.bbcode_text = Global.TUTORIAL_TEXT[tutorial_index]
	if tutorial_index == 0:
		$TutorialContainer/VBoxContainer/HBoxContainer2/Prev.self_modulate = Color(1,1,1,0)


func _on_Next_button_down():
	if tutorial_index < Global.TUTORIAL_TEXT.size() - 1:
		tutorial_index += 1
		$TutorialContainer/VBoxContainer/HBoxContainer2/Prev.self_modulate = Color(1,1,1,1)
		$TutorialContainer/VBoxContainer/TutorialLabel.bbcode_text = Global.TUTORIAL_TEXT[tutorial_index]
	if tutorial_index == Global.TUTORIAL_TEXT.size() - 1:
		$TutorialContainer/VBoxContainer/HBoxContainer2/Next.self_modulate = Color(1,1,1,0)


func _on_TutorialContainer_visibility_changed():
	if $TutorialContainer.visible:
		SignalManager.emit_signal("tutorial_open")
	else:
		SignalManager.emit_signal("tutorial_close")

func on_tutorial_open():
	$TutorialContainer.show()
