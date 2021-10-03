extends Node2D



var speed = 50

var height = -256*rand_range(0.8,1.2)


# Called when the node enters the scene tree for the first time.
func _ready():
	rotation_degrees = rand_range(0,360)
	speed *= rand_range(0.5,1.5)
	


func _process(delta):
	
	rotate(deg2rad(speed * delta))
	update()
	

func _draw():
	
	draw_texture(Global.cloud,Vector2(0,height))
	
