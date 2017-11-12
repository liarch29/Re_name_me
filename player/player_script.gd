extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
const speed = 100
var dir = 0.4
var max_rot = 0.1
var target = Vector2(get_pos())


func _ready():
	set_fixed_process(true)
	set_rot(0.4)
	pass

func _fixed_process(delta):
	if get_rot() == dir:
		if get_pos().distance_squared_to(target) > pow(speed * delta, 2):
			var default = Vector2(0, 1).rotated(dir)
			var veloc = default * speed * delta
			move(veloc)
		else:
			set_pos(target)
	else:
		var c_rot = angle_conv(get_rot())
		var t_rot = angle_conv(dir)

		var left_dis = left_dis(c_rot, t_rot)
		var right_dis = right_dis(c_rot, t_rot)

		if abs(left_dis) < max_rot || abs(right_dis) < max_rot:
			set_rot(dir)
		elif left_dis < right_dis:
			print("Left: " + str(left_dis) + ", " + str(right_dis))
			set_rot(get_rot()-max_rot)
		else:
			print("Right: " + str(left_dis) + ", " + str(right_dis))
			set_rot(get_rot()+max_rot)


func left_dis(c_rot, t_rot):
	if c_rot < t_rot:
		print(str(2 * PI - t_rot + c_rot))
		return 2 * PI - t_rot + c_rot
	else:
		return t_rot - c_rot


func right_dis(c_rot, t_rot):
	if c_rot > t_rot:
		print(str(2 * PI - c_rot + t_rot))
		return 2 * PI - c_rot + t_rot
	else:
		return c_rot - t_rot


func angle_conv(angle):
	if angle < 0:
		return 2*PI+angle
	else:
		return angle


func set_target(pos):
	target = pos
	dir = target.angle_to_point(get_pos())
