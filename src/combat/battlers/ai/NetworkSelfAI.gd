extends BattlerAI
class_name NetworkSelfAI
var interface: Node
var initialized = false
var multiplayer_interface

func initialize(multiplayer_interface):
	self.multiplayer_interface = multiplayer_interface
	initialized = true

func choose_action(actor: Battler, normal_mode = true):
	assert(initialized)
	interface.call_deferred("open_actions_menu", actor, normal_mode)
	var action = yield(interface, "action_selected")
	multiplayer_interface.put_var(Utils.save_action(action))
	return action
