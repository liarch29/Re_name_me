extends KinematicBody2D

# How far this entity can travel in a straight line in 1 second
export(float) var speed = 100

# The maximum amount this entity can rotate (radians) in 1 second
export(float) var max_rot = PI / 6

# The maximum health of this entity. Set to 0 to make this entity invincible.
export(float) var max_health = 100

# The current health of this entity. It is always between 0 and 100, inclusive.
export(float) var health = 100 setget set_health

signal health_change

# ------------------ #
# Internal variables #
# ------------------ #

# Target position to move to
onready var target = Vector2(self.position)
onready var _hitbox = get_node("hitbox")

# ------------------ #

func _process_turn(delta):
	var angle_to_target = target.angle_to_point(self.position)
	if self.position == target:
		pass
	elif self.rotation == angle_to_target:
		move_forward(delta)
	else:
		var current_rot = angle_conv(self.rotation)
		var target_rot = angle_conv(angle_to_target)

		var diff = target_rot - current_rot
		var adj_rot = max_rot * delta

		move_forward(delta)
		if abs(diff) < adj_rot:
			self.rotation = angle_to_target
		elif (diff > 0 && diff < PI) || (diff > -2 * PI && diff < -PI):
			self.rotation = self.rotation + adj_rot
		else:
			self.rotation = self.rotation - adj_rot

	for w in get_node("Weapons").get_children():
		w._process_turn(delta)

func move_forward(delta):
	if self.position.distance_squared_to(target) > pow(speed * delta, 2):
		#TODO: Refactor to dedicated utility/physics class
		var veloc = Vector2(speed * delta, 0).rotated(self.rotation)
		self.position += veloc

		# Collision logic, but still needs work
		# var slide_vel = move_and_slide(veloc)
		# self.position += slide_vel
	else:
		self.position = target

func angle_conv(angle):
	if angle < 0:
		return angle + 2 * PI
	else:
		return angle

# Sets the health of this entity, clamped between 0 and max_health
func set_health(h):
	health = clamp(h, 0, max_health)
	self.emit_signal("health_change", health)

# Causes this entity to be damaged by the given amount
func damage(h):
	self.set_health(health - h)

# Whether a point is outside of the minimum turning circles
func can_turn_to(pos):
	var min_turn_radius = speed / max_rot
	var ortho_left = min_turn_radius * Vector2(1, 0).rotated(self.rotation + PI/2)
	var left_circle = self.position + ortho_left
	var right_circle = self.position - ortho_left
	var radius_squared = min_turn_radius * min_turn_radius
	return left_circle.distance_squared_to(pos) >= radius_squared and \
		right_circle.distance_squared_to(pos) >= radius_squared
