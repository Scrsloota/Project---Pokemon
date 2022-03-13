extends YSort

class_name TurnQueue

signal queue_changed

onready var active_battler: Battler
var last_action_canceled: bool = false


func initialize():
	var self_pokemon = get_party()[0]
	var oppo_pokemon = get_monsters()[0]
	var self_speed = self_pokemon.stats.get_speed()
	var oppo_speed = oppo_pokemon.stats.get_speed()
	var slow_one
	if self_speed != oppo_speed:
		if self_speed < oppo_speed:
			slow_one = self_pokemon
		else:
			slow_one = oppo_pokemon
	else:
		var r = RandomGenerater.randf()
		var main_node = RandomGenerater.is_main_node()
		if (r < 0.5 and main_node) or (r >= 0.5 and (not main_node)) :
			slow_one = self_pokemon
		else:
			slow_one = oppo_pokemon
	slow_one.raise()
	active_battler = get_child(0)
	emit_signal("queue_changed", get_battlers(), active_battler)


func play_turn(action: CombatAction, battler, targets) -> Array:

	# animation
	if not last_action_canceled:
		yield(active_battler.skin.move_forward(), "completed")
	
	var message = []
	var yield_action = action.execute(battler, targets)
	if yield_action is GDScriptFunctionState:
		message = yield(yield_action, "completed")
	else:
		message = yield_action
	# if not hit_target:
	# 	last_action_canceled = true
	# 	return
	# last_action_canceled = false
	
	# yield(turn_end_action(),"complete");
	
	_next_battler()
	
	return message


func skip_turn():
	_next_battler()
	
	
func turn_end_action():
	#TODO: burning, poison
	pass


func _next_battler():
	# always two on the field
	var next_battler_index: int = (active_battler.get_index() + 1) % 2
	active_battler = get_child(next_battler_index)
	emit_signal("queue_changed", get_battlers(), active_battler)

func get_oppo_battler():
	var next_battler_index: int = (active_battler.get_index() + 1) % 2
	return get_child(next_battler_index)

func get_party_nocheck():
	return _get_targets_nocheck(true)
	
func get_monster_nocheck():
	return _get_targets_nocheck(false)

func get_party():
	return _get_targets(true)


func get_monsters():
	return _get_targets(false)

func _get_targets_nocheck(in_party: bool = false):
	for child in get_children():
		if child.party_member == in_party:
			return child

func _get_targets(in_party: bool = false) -> Array:
	var targets: Array = []
	for child in get_children():
		if child.party_member == in_party && child.stats.health > 0:
			targets.append(child)
	return targets


func get_battlers():
	return get_children()


func print_queue():
	# Prints the Battlers' and their speed in the turn order
	var string: String
	for battler in get_children():
		string += battler.name + "(%s)" % battler.stats.get_speed() + " "
