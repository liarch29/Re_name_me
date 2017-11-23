extends KinematicBody2D

# How far this entity can travel in a straight line in 1 second
export(float) var speed = 100

# The initial rotation of this entity
export(float) var initial_rot = 0

# The maximum amount this entity can rotate (radians) in 1 second
export(float) var max_rot = 0.01

# The maximum health of this entity. Set to 0 to make this entity invincible.
export(float) var max_health = 100

# The current health of this entity. It is always between 0 and 100, inclusive.
export(float) var health = 100 setget set_health

# ------------------ #
# Internal variables #
# ------------------ #

# Target position to move to
onready var target = Vector2(get_pos())
onready var _healthbar = get_node("healthbar")
onready var _hitbox = get_node("hitbox")

# ------------------ #

func _ready():
	set_rot(initial_rot)

	# Setup health bar
	if max_health > 0:
		_healthbar.set_hidden(false)
		var bounds = _hitbox.get_shape().get_extents()
		var current_hp = _healthbar.get_node("current_hp")
		var max_hp = _healthbar.get_node("max_hp")
		_adjust_healthbar_offset(bounds, current_hp)
		_adjust_healthbar_offset(bounds, max_hp)
		_adjust_healthbar_shape(bounds, current_hp, 1)
		_adjust_healthbar_shape(bounds, max_hp, 1)
		update_health_bar()

func _adjust_healthbar_offset(bounds, bar):
	bar.set_offset(Vector2(-bounds.x, -bounds.y - 25))

func _adjust_healthbar_shape(bounds, polygon2d, scale):
	var poly = polygon2d.get_polygon()
	var new_verts = []
	for vert in poly:
		var updated = Vector2(vert.x, vert.y)
		if updated.x != 0:
			updated.x = bounds.x * 2 * scale
		new_verts.push_back(updated)
	polygon2d.set_polygon(Vector2Array(new_verts))

func update_health_bar():
	if max_health > 0:
		var bounds = _hitbox.get_shape().get_extents()
		var hp_bar = _healthbar.get_node("current_hp")
		_adjust_healthbar_shape(bounds, hp_bar, health / max_health)

func _process_turn(delta):
	var angle_to_target = target.angle_to_point(get_pos())
	if get_pos() == target:
		pass
	elif get_rot() == angle_to_target:
		move_forward(delta)
	else:
		var current_rot = angle_conv(get_rot())
		var target_rot = angle_conv(angle_to_target)

		var diff = target_rot - current_rot
		move_forward(delta)
		if abs(diff) < max_rot:
			set_rot(angle_to_target)
		elif (diff > 0 && diff < PI) || (diff > -2 * PI && diff < -PI):
			set_rot(get_rot() + max_rot)
		else:
			set_rot(get_rot() - max_rot)

func move_forward(delta):
	if get_pos().distance_squared_to(target) > pow(speed * delta, 2):
		var default = Vector2(0, 1).rotated(get_rot())
		var veloc = default * speed * delta
		move(veloc)
	else:
		set_pos(target)

func angle_conv(angle):
	if angle < 0:
		return angle + 2*PI
	else:
		return angle

func set_target(pos):
	print("position set ", pos)
	target = pos

# Sets the health of this entity, clamped between 0 and max_health
func set_health(h):
	health = clamp(h, 0, self.max_health)

	# set_health is called before ready, so we need to check if hitbox exists
	# before updating the health bar
	if _hitbox:
		update_health_bar()
