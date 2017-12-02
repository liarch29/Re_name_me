extends Node2D

# Color of bar covered by the value
export(Color) var color = Color(0, 1.0, 0)

# Background color of the bar (where the value does not reach)
export(Color) var background_color = Color(1.0, 0, 0)

# The maximum health of this health bar.
export(float) var max_value = 100.0

# The current health.
export(float) var value = 100.0 setget set_value

# Whether this progress bar should be displayed when the value is at max
export(bool) var show_on_max = true

onready var _current_hp = get_node("current_hp")
onready var _max_hp = get_node("max_hp")

func _ready():
	self._current_hp.color = color
	self._max_hp.color = background_color

func set_value(new_value):
	value = clamp(new_value, 0, self.max_value)

	if max_value > 0 and self._current_hp and self._max_hp:
		if value != max_value or show_on_max:
			# Warning: value or max_value may be integers!
			# So we need to turn them into floats
			self._current_hp.set_scale(Vector2(1.0 * value / self.max_value, 1))

# Automatically update the value of this progress bar to the one emitted by the
# target node in the specified signal
func register_value_event(signal_name, target):
	target.connect(signal_name, self, "set_value")