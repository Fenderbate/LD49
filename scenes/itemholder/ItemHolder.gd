extends Panel




onready var button = $AddButton

var icon
var type = Global.OBJECT_TYPE.FLORA_SMALL
var obj_name = "N/A"
var cost = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	
	SignalManager.connect("set_object_selection_focus",self,"on_object_selection_focus_set")
	
	$SelectButton/ItemRect.texture = icon
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func on_object_selection_focus_set(other_type):
	if other_type == type:
		$SelectButton.grab_focus()
	else:
		if $SelectButton.has_focus():
			$SelectButton.release_focus()

func _on_AddButton_mouse_entered():
	$CostPanel.show()
	$CostPanel/CostLabel.text = str(cost)
	$CostPanel/CostCurrency.texture = Global.currency_texture

func _on_AddButton_mouse_exited():
	$CostPanel.hide()
