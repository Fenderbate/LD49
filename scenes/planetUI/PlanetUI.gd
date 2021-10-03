extends CanvasLayer

var object = preload("res://scenes/planetobject/PlanetObject.tscn")
var item_holder = preload("res://scenes/itemholder/ItemHolder.tscn")

var planet_objects = {
	"tree_1" : {"Texture":preload("res://sprites/tree_1.png"),"Type":Global.OBJECT_TYPE.FLORA,"Size":Global.FLORA_DELTA.MED},
	"tree_2" : {"Texture":preload("res://sprites/tree_2.png"),"Type":Global.OBJECT_TYPE.FLORA,"Size":Global.FLORA_DELTA.BIG},
	"bush_1" : {"Texture":preload("res://sprites/bush_1.png"),"Type":Global.OBJECT_TYPE.FLORA,"Size":Global.FLORA_DELTA.SMALL},
	"mountain_1" : {"Texture":preload("res://sprites/mountain_1.png"),"Type":Global.OBJECT_TYPE.OBJECT},
	"house_1" : {"Texture":preload("res://sprites/house_1.png"),"Type":Global.OBJECT_TYPE.BUILDING},
	"machine_1" : {"Texture":preload("res://misc/Machine_UI_texture.tres"),"Type":Global.OBJECT_TYPE.MACHINE}
}


var select_index = null

var spawn_point = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	$Container.hide()
	SignalManager.connect("planet_focus_enter",self,"on_planet_focus_entered")
	SignalManager.connect("planet_focus_leave",self,"on_planet_focus_left")
	SignalManager.connect("update_planet_UI",self,"on_planet_ui_updated")
	
	
	
	for item in planet_objects:
		
		var btn = item_holder.instance()
		btn.icon = planet_objects[item]["Texture"]
		btn.type = planet_objects[item]["Type"]
		btn.obj_name = item
		$Container/CenterContainer/GridContainer.add_child(btn)
		btn.get_node("SelectButton").connect("button_down",self,"on_object_button_pressed",[btn.obj_name])
		btn.get_node("AddButton").connect("button_down",self,"on_object_add_button_pressed",[btn.obj_name])

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
			spawn_object()

func _input(event):
	
	if Global.is_planet_null() or !$Container.visible:
		return
	
	
	

func spawn_object():
	
	
	var obj = object.instance()
	obj.position = spawn_point#Global.focused_planet.get_ref().get_local_mouse_position()
	obj.data["Type"] = planet_objects[select_index]["Type"]
	obj.data["Sprite"] = planet_objects[select_index]["Texture"]
	obj.data["Name"] = select_index
	
	Global.focused_planet.get_ref().get_node("Objects").add_child(obj)
	



func on_planet_focus_entered():
	$Container.show()
	$Container/NamePanel/NameLabel.text = Global.focused_planet.get_ref().planet_name

func on_planet_focus_left():
	$Container.hide()

func on_planet_ui_updated(temperature,atmosphere,population):
	$Container/Panel2/VBoxContainer/OxygenDisplay/OxygenSlider.value = atmosphere
	$Container/Panel2/VBoxContainer/TempDisplay/TempSlider.value = temperature

func on_object_button_pressed(name):
	select_index = name
	print(name)

func on_object_add_button_pressed(name):
	
	print("add resource!")
	

