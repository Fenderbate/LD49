extends CanvasLayer


var new_scene

var transition_done = false

var restart = false

# Called when the node enters the scene tree for the first time.
func _ready():
	print("YAH")

func _input(event):
	
	if event.is_action_pressed("restart"):
		start_transition("",true)
		
	

func start_transition(to : String = "", res = false):
	restart = res
	transition_done = false
	new_scene = to
	$Tween.interpolate_property($Sprite.material,"shader_param/progress", 0, 1, 2, Tween.TRANS_CUBIC, Tween.EASE_OUT) 
	$Tween.start()


func _on_Tween_tween_completed(object, key):
	
	if !transition_done:
		if restart:
			get_tree().reload_current_scene()
		else:
			get_tree().change_scene_to(load(new_scene).instance())
		$Tween.interpolate_property($Sprite.material,"shader_param/progress", 1, 0, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT) 
		$Tween.start()
	transition_done = true


