extends Node2D

export(NodePath) var player

var _player

func _ready():
	_player = get_node(player)
	set_pos(_player.get_pos())
	set_process(true)

func _process(delta):
	if _player.get_pos() == _player.target:
		set_hidden(true)
	else:
		set_hidden(false)
		update()

func _draw():
	if _player.get_pos() != _player.target:
		var color = get_node("indicator_shape").get_color()
		# Note: these coordinates are relative to this node
		draw_line(_player.get_pos() - get_pos(), Vector2(0, 0), color)