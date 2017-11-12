extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
const speed = 100
var dir = 0
var target = Vector2(get_pos())


func _ready():
	set_fixed_process(true)
	pass

func _fixed_process(delta):
	if get_pos().distance_squared_to(target) > pow(speed * delta, 2):
		var default = Vector2(0, 1).rotated(dir)
		var veloc = default * speed * delta
		move(veloc)
	else:
		set_pos(target)
	set_rot(dir+PI)

func set_target(pos):
	target = pos
	dir = target.angle_to_point(get_pos())