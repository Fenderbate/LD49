extends Control




onready var button = $AddButton

var icon
var type = Global.OBJECT_TYPE.FLORA_SMALL
var obj_name = "N/A"
var cost = 100
var tooltip = "N/A"

# Called when the node enters the scene tree for the first time.
func _ready():
	
	SignalManager.connect("set_object_selection_focus",self,"on_object_selection_focus_set")
	SignalManager.connect("reset_select_index",self,"on_select_index_reset")
	
	$SelectButton/ItemRect.texture = icon if type != Global.OBJECT_TYPE.MACHINE else load("res://misc/Machine_UI_texture.tres")
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func on_object_selection_focus_set(other_type):
	if other_type == type:
		$SelectButton.grab_focus()
	else:
		if $SelectButton.has_focus():
			$SelectButton.release_focus()

func on_select_index_reset():
	$SelectButton.release_focus()

func _on_AddButton_mouse_entered():
	$CostPanel.show()
	$CostPanel/CostLabel.text = str(cost)
	SignalManager.emit_signal("show_tooltip",str("Object cost: ",str(cost)," people."))

func _on_AddButton_mouse_exited():
	$CostPanel.hide()
	SignalManager.emit_signal("hide_tooltip")

func _on_SelectButton_mouse_entered():
	SignalManager.emit_signal("show_tooltip",tooltip)


func _on_SelectButton_mouse_exited():
	SignalManager.emit_signal("hide_tooltip")
