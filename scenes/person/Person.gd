extends KinematicBody2D


var moving = false

var motion = Vector2(0,10)

var speed = 10


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	
	look_at(get_parent().global_position)
	
	
	if moving:
		#if $AnimationPlayer.
		if !test_move(get_transform(),Vector2(0,motion.y)):
			motion += Vector2(0, Global.GRAVITY * delta)
			position += motion.y
		else:
			motion = Vector2(0, 20)
		
		position.x += speed
	
	
	
