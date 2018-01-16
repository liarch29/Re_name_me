extends KinematicBody2D

# How far this entity can travel in a straight line in 1 second
export(float) var speed = 100

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
		var adj_rot = max_rot * (delta / 0.015)
		
		move_forward(delta)
		if abs(diff) < adj_rot:
			self.rotation = angle_to_target
		elif (diff > 0 && diff < PI) || (diff > -2 * PI && diff < -PI):
			self.rotation = self.rotation + adj_rot
		else:
			self.rotation = self.rotation - adj_rot

func move_forward(delta):
	if self.position.distance_squared_to(target) > pow(speed * delta, 2):
		var default = Vector2(1, 0).rotated(self.rotation)
		var veloc = default * speed * delta
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
