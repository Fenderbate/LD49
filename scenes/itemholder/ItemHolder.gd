extends Panel




onready var button = $AddButton

var icon
var type = Global.OBJECT_TYPE.FLORA
var obj_name = "N/A"

# Called when the node enters the scene tree for the first time.
func _ready():
	
	$SelectButton/ItemRect.texture = icon
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
