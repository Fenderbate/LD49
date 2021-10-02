extends KinematicBody2D

var moving = true

var collision

var speed = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	look_at(get_parent().global_position)


func _physics_process(delta):
	
	if moving:
		speed += Global.GRAVITY * delta
		
		collision = move_and_collide((get_parent().global_position - global_position).normalized() * speed)
		
		if collision:
			moving = false
	
	
	

