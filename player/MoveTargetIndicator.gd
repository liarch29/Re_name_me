extends Node2D

export(NodePath) var player

var _player

# Rate at which to approximate movement line, in seconds
var line_draw_rate = 0.1

# Maximum amount of time to draw movement approx line, in seconds
var max_draw_time = 10.0

# Cache of points in the movement approx line
var move_approx_cache = []


func _ready():
	_player = get_node(player)
	self.position = self._player.position
	self.set_process(true)

func _process(delta):
	if _player.position == _player.target:
		self.hide()
	else:
		self.show()
		var color = get_node("indicator_shape").get_color()
		recalculate_move_approx_line(color)
		# Note: "update" as in "schedule a draw call"
		self.update()

func _draw():
	if _player.position != _player.target:
		var color = get_node("indicator_shape").get_color()
		# Note: these coordinates are relative to this node
		# draw_line(_player.position - self.position, Vector2(0, 0), color)
		draw_move_approx_line(color)

func draw_move_approx_line(color):
#	if move_approx_cache.size() > 1:
#		var points = PoolVector2Array(move_approx_cache)
#		for i in range(0, move_approx_cache.size() - 1):
#			points.set(i, points[i] - self.position)
#		self.draw_polyline(points, color, 1.0, true)
	var previous = Vector2(_player.position)
	for next in move_approx_cache:
		draw_line(previous - self.position, next - self.position, color)
		previous = next

func recalculate_move_approx_line(color):
	var max_rot = _player.max_rot * line_draw_rate
	var speed_diff = _player.speed * line_draw_rate

	var rot = _player.rotation
	var previous_point = Vector2(_player.position)
	var draw_time = 0
	var drawing = true
	move_approx_cache.clear()
	move_approx_cache.append(_player.position)
	while drawing:
		var angle_to_target = _player.target.angle_to_point(previous_point)
		var current_rot = _player.angle_conv(rot)
		var target_rot = _player.angle_conv(angle_to_target)
		var angle_diff = target_rot - current_rot
		var next_point = previous_point
		if previous_point.distance_squared_to(_player.target) > pow(speed_diff, 2):
			#TODO: Refactor to dedicated utility/physics class
			var veloc = Vector2(speed_diff, 0).rotated(rot)
			next_point += veloc
		else:
			next_point = _player.target
		if abs(angle_diff) < max_rot:
			rot = angle_to_target
		elif (angle_diff > 0 && angle_diff < PI) || (angle_diff > -2 * PI && angle_diff < -PI):
			rot = rot + max_rot
		else:
			rot = rot - max_rot
		
		if previous_point == next_point or draw_time > max_draw_time:
			drawing = false
		else:
			draw_time += line_draw_rate
		move_approx_cache.append(next_point)
		previous_point = next_point
