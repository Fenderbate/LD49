extends CanvasLayer

var object = preload("res://scenes/planetobject/PlanetObject.tscn")
var item_holder = preload("res://scenes/itemholder/ItemHolder.tscn")

var planet_objects = {
	"bush_1" : {"Texture":preload("res://sprites/bush_1.png"),"Type":Global.OBJECT_TYPE.FLORA_SMALL,"Cost":Global.OBJECT_TYPE_COST.FLORA_SMALL,"OxygenDelta":Global.OXYGEN_DELTA.SMALL},
	"tree_1" : {"Texture":preload("res://sprites/tree_1.png"),"Type":Global.OBJECT_TYPE.FLORA_MED,"Cost":Global.OBJECT_TYPE_COST.FLORA_MED,"OxygenDelta":Global.OXYGEN_DELTA.MED},
	"tree_2" : {"Texture":preload("res://sprites/tree_2.png"),"Type":Global.OBJECT_TYPE.FLORA_BIG,"Cost":Global.OBJECT_TYPE_COST.FLORA_BIG,"OxygenDelta":Global.OXYGEN_DELTA.BIG},
	"mountain_1" : {"Texture":preload("res://sprites/mountain_1.png"),"Type":Global.OBJECT_TYPE.OBJECT,"Cost":Global.OBJECT_TYPE_COST.OBJECT,"OxygenDelta":Global.OXYGEN_DELTA.NONE},
	"house_1" : {"Texture":preload("res://sprites/house_1.png"),"Type":Global.OBJECT_TYPE.BUILDING,"Cost":Global.OBJECT_TYPE_COST.BUILDING,"OxygenDelta":Global.OXYGEN_DELTA.NONE},
	"machine_1" : {"Texture":preload("res://sprites/temperature_machine_1.png"),"Type":Global.OBJECT_TYPE.MACHINE,"Cost":Global.OBJECT_TYPE_COST.MACHINE,"OxygenDelta":Global.OXYGEN_DELTA.NEG_BIG}
}


var select_index = null

var spawn_point = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	$Container.hide()
	SignalManager.connect("planet_focus_enter",self,"on_planet_focus_entered")
	SignalManager.connect("planet_focus_leave",self,"on_planet_focus_left")
	SignalManager.connect("update_planet_UI",self,"on_planet_ui_updated")
	SignalManager.connect("update_supply_display",self,"update_supply_display")
	
	
	for item in planet_objects:
		
		var btn = item_holder.instance()
		btn.icon = planet_objects[item]["Texture"]
		btn.type = planet_objects[item]["Type"]
		btn.cost = planet_objects[item]["Cost"]
		btn.obj_name = item
		$Container/ItemContainer/GridContainer.add_child(btn)
		btn.get_node("SelectButton").connect("button_down",self,"on_object_button_pressed",[btn.type])
		btn.get_node("AddButton").connect("button_down",self,"on_object_add_button_pressed",[btn.type])
	
	SignalManager.emit_signal("update_supply_display")
	

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

func on_planet_ui_updated(temperature,atmosphere,population):
	$Container/InfoPanel/VBoxContainer/OxygenDisplay/OxygenSlider.value = atmosphere
	$Container/InfoPanel/VBoxContainer/TempDisplay/TempSlider.value = temperature

func on_object_button_pressed(type):
	select_index = type
	print(name)

func on_object_add_button_pressed(type):
	
	if Global.OBJECT_TYPE_COST[Global.OBJECT_TYPE_COST.keys()[type]] <= Global.currency:
		Global.OBJECT_TYPE_SUPPLY[Global.OBJECT_TYPE_SUPPLY.keys()[type]] += 1
		Global.currency -= Global.OBJECT_TYPE_COST[Global.OBJECT_TYPE_COST.keys()[type]]
		SignalManager.emit_signal("update_supply_display")
		
		
	

