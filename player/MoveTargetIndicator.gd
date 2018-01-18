extends Node2D

export(NodePath) var player

var _player
var average_delta = 0.015
var time_out = 0
var max_tick_till_time_out = 10000
var guide_list = []


func _ready():
	_player = get_node(player)
	self.position = self._player.position
	set_process(true)

func _process(delta):
	if _player.position == _player.target:
		self.hide()
	else:
		self.show()
		var color = get_node("indicator_shape").get_color()
		draw_guide_line(color)
		update()

func _draw():
	if _player.position != _player.target:
		var color = get_node("indicator_shape").get_color()
		# Note: these coordinates are relative to this node
		# draw_line(_player.position - self.position, Vector2(0, 0), color)
		draw_all(color)

func draw_all(color):
	var move_point1 = Vector2(_player.position)
	for point in guide_list:
		draw_line(move_point1-self.position, point-self.position, color)
		move_point1 = point

func draw_guide_line(color):
	# var max_rot = _player.max_rot
	guide_list = []
	average_delta = 0.1
	var move_point1 = Vector2(_player.position)
	var move_point2 = Vector2(_player.position)
	var rot = _player.rotation
	var ticks_to_target = move_point1.distance_to(_player.target) / (_player.speed * average_delta)
	var max_rot = _player.max_rot * average_delta
	while(1):
		move_point2 = move_point1
		var angle_to_target = _player.target.angle_to_point(move_point1)
		var current_rot = _player.angle_conv(rot)
		var target_rot = _player.angle_conv(angle_to_target)
		var diff = target_rot - current_rot
		if move_point1.distance_squared_to(_player.target) > pow(_player.speed * average_delta, 2):
			var default = Vector2(1, 0).rotated(rot)
			var veloc = default * _player.speed * average_delta
			move_point1 += veloc
		else:
			move_point1 = (_player.target)
		if abs(diff) < max_rot:
			rot = (angle_to_target)
		elif (diff > 0 && diff < PI) || (diff > -2 * PI && diff < -PI):
			rot = (rot + max_rot)
		else:
			rot = (rot - max_rot)

		if move_point1 == move_point2 || time_out > max_tick_till_time_out:
			time_out = 0
			break

		time_out += 1
		guide_list.append(move_point2)
		#draw_line(move_point2 - self.position, move_point1 - self.position, color)

