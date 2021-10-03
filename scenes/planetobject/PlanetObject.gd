extends KinematicBody2D
class_name PlanetObject

# calculations
var moving = true
var collision
var speed = 0

# init vars
var data = {
	"Type" : Global.OBJECT_TYPE.FLORA,
	"FloraSize" : Global.FLORA_DELTA.SMALL,
	"Sprite" : null,
	"Name" : "N/A"
}

# Called when the node enters the scene tree for the first time.
func _ready():
	look_at(get_parent().global_position)
	$SpritePivot/Sprite.texture = data["Sprite"]
	if data["Type"] == Global.OBJECT_TYPE.MACHINE:
		$SpriteAnimator.play("base")
	elif data["Type"] == Global.OBJECT_TYPE.FLORA:
		Global.focused_planet.get_ref().oxygen_delta += data["FloraSize"]
	else:
		print("unknown object: ",data["Name"])
	
	
	


func _physics_process(delta):
	
	speed += Global.GRAVITY * delta
	var motion = (get_parent().global_position - global_position).normalized() * speed
	var col = move_and_collide(motion,true,true,true)
	
	if moving:
		
		if col and col.collider.is_in_group("Planet") and $Raycast.is_colliding():
			moving = false
		
		position += motion
		
		if col and col.collider.is_in_group("Planet"):
			$AnimationPlayer.play("squash")
			$Particles.emitting = true
			moving = false
	else:
		if !col:
			moving = true
		
	
	
	

