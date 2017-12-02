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

signal health_change

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
	_healthbar.register_value_event("health_change", self, health, max_health)

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
	health = clamp(h, 0, max_health)
	self.emit_signal("health_change", health)