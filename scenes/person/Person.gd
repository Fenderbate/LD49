extends KinematicBody2D


var moving = true

var motion = Vector2(0,0)

var speed = 50

var remainder = Vector2()

var under_mouse = false

var picked_up = false

# Called when the node enters the scene tree for the first time.
func _ready():
	look_at(get_parent().global_position)
	$Sprite.frame = randi()%10
	
	$Tween.interpolate_property($Sprite.material,"shader_param/flash_modifier",1.0,0.0,0.3,Tween.TRANS_CUBIC)
	$Tween.start()


func _physics_process(delta):
	if picked_up:
		return
	
	if moving:
		
		if !$AnimationPlayer.is_playing() or $AnimationPlayer.current_animation != "walk":
			$AnimationPlayer.play("walk")
			
		
		look_at(get_parent().global_position)
		
		motion = Vector2(Global.GRAVITY,speed).rotated(rotation)
		
		motion = move_and_slide(motion)
	
	else:
		
		if !$AnimationPlayer.is_playing() or $AnimationPlayer.current_animation != "idle":
			$AnimationPlayer.play("idle")


func _input(event):
	if event.is_action_pressed("left_click") and under_mouse:
		get_tree().set_input_as_handled()
		
		remove(true)
		

func remove(pickup = false):
	if pickup:
		picked_up = true
		$Tween.stop_all()
		$Tween.interpolate_property($Sprite,"scale",$Sprite.scale,Vector2(0,0),0.5,Tween.TRANS_CUBIC)
		$Tween.interpolate_property($Sprite.material,"shader_param/flash_modifier",0,1,0.25,Tween.TRANS_CUBIC)
		$AnimationPlayer.play("ascend")
		$Tween.start()
		
		yield($Tween,"tween_all_completed")
		
		Global.currency += 1
		SignalManager.emit_signal("update_supply_display")
	
	
	queue_free()

func _on_Person_mouse_entered():
	under_mouse = true


func _on_Person_mouse_exited():
	under_mouse = false
