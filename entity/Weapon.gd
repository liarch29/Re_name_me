extends Node

# How much damage this weapon deals per hit
export(float) var fire_damage = 5

# How long between each shot fired, in seconds
export(float) var fire_cooldown = 1.0

# How far this weapon can fire
export(float) var fire_range = 300.0

# Whether this weapon should automatically acquire a target.
export(bool) var auto_acquire = false

# The current target of this weapon.
var target = null

# Time required until this weapon can fire again
var current_cooldown = 0.0

func _ready():
	pass

func _process_turn(delta):
	if target == null:
		if auto_acquire:
			target = find_nearest_target(get_tree().get_nodes_in_group("entities"))
	else:
		var in_range = entity_position().distance_squared_to(target.position) < fire_range * fire_range
		if current_cooldown == 0.0 and in_range:
			current_cooldown = fire_cooldown
			target.damage(fire_damage)
	current_cooldown = max(0.0, current_cooldown - fire_cooldown * delta)

func find_nearest_target(entities):
	var closest = null
	var closest_distsq = null
	for e in entities:
		var e_distsq = entity_position().distance_squared_to(e.position)
		if closest == null || e_distsq < closest_distsq:
			closest = e
			closest_distsq = e_distsq
	return closest

func entity_position():
	return get_node("../..").position