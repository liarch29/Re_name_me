# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	set_process_input(true)
	pass

func _input(ev):
	# Mouse in viewport coordinates
	if (ev.type==InputEvent.MOUSE_BUTTON):
		
		print("Mouse Click/Unclick at: ", ev.pos)
		get_node("player_ship").set_target(ev.pos)

