extends KinematicBody2D
class_name PlanetObject

var moving = true

var collision

var speed = 0

var TYPE = {"Flora":0,"Object":1,"Building":2}

var type = TYPE.Flora

var sprite = null

# Called when the node enters the scene tree for the first time.
func _ready():
	look_at(get_parent().global_position)
	$SpritePivot/Sprite.texture = sprite


func _physics_process(delta):
	
	if moving:
		speed += Global.GRAVITY * delta
		
		position += (get_parent().global_position - global_position).normalized() * speed
		
		
		
		if $Raycast.is_colliding():
			$AnimationPlayer.play("squash")
			$Particles.emitting = true
			if $Raycast.is_colliding() and $Raycast2.is_colliding():
				moving = false
	
	
	

