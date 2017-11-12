extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
const speed = 100
export(float) var dir
var max_rot = 0.01
var target = Vector2(get_pos())


func _ready():
	set_fixed_process(true)
	set_rot(dir)
	pass

func _fixed_process(delta):
	if get_rot() == dir:
		move_forward(delta)
	else:
		var current_rot = angle_conv(get_rot())
		var target_rot = angle_conv(dir)

		var diff = target_rot - current_rot
		move_forward(delta)
		if abs(diff) < max_rot:
			set_rot(dir)
		elif (diff > 0 && diff < PI) || (diff > -2 * PI && diff < -PI):
			set_rot(get_rot() + max_rot)
		else:
			set_rot(get_rot() - max_rot)

func move_forward(delta):
	if get_pos().distance_squared_to(target) > pow(speed * delta, 2):
		var default = Vector2(0, 1).rotated(get_rot())
		var veloc = default * speed * delta
		move(veloc)
		dir = target.angle_to_point(get_pos())
	else:
		set_pos(target)

func angle_conv(angle):
	if angle < 0:
		return angle + 2*PI
	else:
		return angle

func set_target(pos):
	target = pos
