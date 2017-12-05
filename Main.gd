extends Node2D
# This file contains the main game logic

# ---------------- #
# Public variables #
# ---------------- #

# The current turn
export(int) var turn = 1

# Duration of one turn, in seconds
export(float) var turn_duration = 10.0

export(NodePath) var selected = null

# ----------------------- #
# Implementation details  #
# Don't modify outside of #
# this file!              #
# ----------------------- #

# Whether a turn is currently being executed
var _executing_turn = false
# If the turn is being executed, how far into the turn, in seconds
var _sim_time = 0.0
# Total time in the game
var _elapsed_time = 0.0

onready var _end_turn_button = get_node("end_turn_button")
onready var _player_ship = get_node("player_ship")
onready var _selected_info = get_node("selected_info")

# ----------------------- #

func _ready():
	set_process_unhandled_input(true)
	set_fixed_process(true)
	set_turn(turn)

	# TODO: remove test object
	get_node("foo").connect("input_event", self, "_on_entity_click", [get_node("foo")])

	for e in get_tree().get_nodes_in_group("entities"):
		# We're blocked by a bug!
		# https://github.com/godotengine/godot/issues/2314
		e.connect("input_event", self, "_on_entity_click", [e])

func _on_entity_click(viewport, ev, shape_id, entity):
	if ev.type == InputEvent.MOUSE_BUTTON and ev.is_pressed():
		_selected_info.set_hidden(false)
		get_tree().set_input_as_handled()
		# _selected_info.get_node("health_bar").register_value_event("on_health_change", entity, entity.health)
		print("eoc")
		print(entity)

func _unhandled_input(ev):
	# Mouse in viewport coordinates
	if ev.type == InputEvent.MOUSE_BUTTON and ev.is_pressed():
		if not _executing_turn:
			_player_ship.set_target(ev.pos)
			get_node("move_target_indicator").set_pos(ev.pos)

			var entity_demo = ev.pos + Vector2(0, 50)
			get_node("ship_2").set_target(entity_demo)
			get_node("move_target_indicator_ship2").set_pos(entity_demo)
		else:
			_selected_info.set_hidden(true)

func _fixed_process(delta):
	get_node("elapsed_time_label").set_text("Elapsed time: %.2fs" % _elapsed_time)
	if _executing_turn:
		_sim_time += delta
		_elapsed_time += delta
		get_tree().call_group(0, "entities", "_process_turn", delta)
		
		# If the turn is over
		if _sim_time > turn_duration:
			_executing_turn = false
			_sim_time = 0
			_end_turn_button.set_disabled(false)
			set_turn(turn + 1)

func set_turn(new_turn):
	turn = new_turn
	get_node("turn_label").set_text("Turn: " + str(turn))

func end_turn():
	_end_turn_button.set_disabled(true)
	_executing_turn = true