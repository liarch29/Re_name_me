extends Node2D
# This file contains the main game logic

# ---------------- #
# Public variables #
# ---------------- #

# The current turn
export(int) var turn = 1

# Duration of one turn, in seconds
export(float) var turn_duration = 10.0

# Fired when a turn is being processed.
# The only argument is the time difference from the previous frame
signal process_turn

# ----------------------- #
# Implementation details  #
# Don't modify outside of #
# this file!              #
# ----------------------- #

# Whether a turn is currently being executed
var _executing_turn = false
# If the turn is being executed, how far into the turn, in seconds
var _sim_time = 0.0

onready var _end_turn_button = get_node("end_turn_button")
onready var _player_ship = get_node("player_ship")

# ----------------------- #

func _ready():
	set_process_unhandled_input(true)
	set_fixed_process(true)
	set_turn(turn)

func _unhandled_input(ev):
	# Mouse in viewport coordinates
	if ev.type == InputEvent.MOUSE_BUTTON and not _executing_turn:
		_player_ship.set_target(ev.pos)
		get_node("move_target_indicator").set_pos(ev.pos)

func _fixed_process(delta):
	if _executing_turn:
		_sim_time += delta
		get_tree().call_group(0, "entities", "_process_turn", delta)
		if _sim_time > turn_duration:
			_executing_turn = false
			_sim_time = 0
			_end_turn_button.set_disabled(false)
			set_turn(turn + 1)

func set_turn(new_turn):
	turn = new_turn
	get_node("turn_label").text = "Turn: " + str(turn)

func end_turn():
	_end_turn_button.set_disabled(true)
	_executing_turn = true