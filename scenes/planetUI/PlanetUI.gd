extends CanvasLayer

var object = preload("res://scenes/planetobject/PlanetObject.tscn")

var planet_objects = [
	"tree_1",
	"tree_2",
	"bush_1",
	"mountain_1",
	"house_1",
	"temperature_machine_1"
	
	
] # add sprite names here


var select_index = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Container.hide()
	SignalManager.connect("planet_focus_enter",self,"on_planet_focus_entered")
	SignalManager.connect("planet_focus_leave",self,"on_planet_focus_left")
	
	
	
	for i in planet_objects.size():
		var btn = Button.new()#TextureButton.new()
		#btn.texture_normal = load(str("res://sprites/",planet_objects[select_index],".png"))
		if planet_objects[i].match("*machine*"):
			btn.icon = load("res://misc/Machine_UI_texture.tres")
		else:
			btn.icon = load(str("res://sprites/",planet_objects[i],".png"))
		btn.rect_min_size = Vector2(80,80)
		#btn.expand = true
		btn.expand_icon = true
		#btn.stretch_mode = TextureButton.STRETCH_KEEP_CENTERED
		btn.name = str(i)
		$Container/CenterContainer/GridContainer.add_child(btn)
		btn.connect("button_down",self,"on_object_button_pressed",[btn.name])

func _unhandled_input(event):
	
	if Global.is_planet_null() or !$Container.visible:
		return
	
	if event.is_action_pressed("left_click"):
		spawn_object()
		print("asd")
	

func spawn_object():
	
	
	var obj = object.instance()
	obj.position = Global.focused_planet.get_ref().get_local_mouse_position()
	if planet_objects[select_index].match("*machine*"):
		obj.type = obj.TYPE.Machine
		print("MACINE")
	else:
		obj.type = obj.TYPE.Flora
		print(":((")
	obj.sprite = load(str("res://sprites/",planet_objects[select_index],".png"))
	Global.focused_planet.get_ref().add_child(obj)
	



func on_planet_focus_entered():
	$Container.show()
	$Container/NamePanel/NameLabel.text = Global.focused_planet.get_ref().planet_name

func on_planet_focus_left():
	$Container.hide()

func on_object_button_pressed(name):
	select_index = int(name)
	print(name)


