extends BattlerAI
class_name NetworkOppoAI
var interface: Node
var initialized = false
var multiplayer_interface

func initialize(multiplayer_interface):
	self.multiplayer_interface = multiplayer_interface
	initialized = true

func choose_action(actor: Battler, normal_mode = true):
	assert(initialized)
	var action = yield(multiplayer_interface.get_var(), "completed")
	action = Utils.load_action(action)
	return action
