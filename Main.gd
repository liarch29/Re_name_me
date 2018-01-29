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
	set_physics_process(true)
	set_turn(turn)

	for e in get_tree().get_nodes_in_group("entities"):
		e.connect("input_event", self, "_on_entity_click", [e])

func _on_entity_click(viewport, ev, shape_id, entity):
	if ev.is_pressed() and ev.get_button_index() == BUTTON_LEFT:
		_selected_info.show()
		get_tree().set_input_as_handled()
		_selected_info.get_node("health_bar").register_value_event(
			"health_change", entity, entity.health, entity.max_health)

		if entity != _player_ship:
			_player_ship.get_node("Weapons/MainGun").target = entity

func _unhandled_input(ev):
	# Mouse in viewport coordinates
	if ev is InputEventMouseButton and ev.is_pressed():
		if ev.get_button_index() == BUTTON_RIGHT:
			if not _executing_turn and _player_ship.can_turn_to(ev.position):
				_player_ship.target = ev.position
				get_node("move_target_indicator").position = ev.position
				var entity_demo = ev.position + Vector2(0, 50)
				get_node("ship_2").target = entity_demo
				get_node("move_target_indicator_ship2").position = entity_demo
		elif ev.get_button_index() == BUTTON_LEFT:
			_selected_info.hide()

func _physics_process(delta):
	get_node("elapsed_time_label").text = "Elapsed time: %.2fs" % _elapsed_time
	if _executing_turn:
		_sim_time += delta
		_elapsed_time += delta
		get_tree().call_group("entities", "_process_turn", delta)

		# If the turn is over
		if _sim_time > turn_duration:
			_executing_turn = false
			_sim_time = 0
			_end_turn_button.disabled = false
			set_turn(turn + 1)

func set_turn(new_turn):
	turn = new_turn
	get_node("turn_label").set_text("Turn: " + str(turn))

func end_turn():
	_end_turn_button.set_disabled(true)
	_executing_turn = true