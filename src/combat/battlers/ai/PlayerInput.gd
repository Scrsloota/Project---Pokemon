extends BattlerAI
class_name PlayerInput
var interface: Node

# actor is battler 
func choose_action(actor, normal_mode = true):
	# Select an action to perform in combat
	# Can be based on state of the actor
	interface.call_deferred("open_actions_menu", actor, normal_mode)
	return yield(interface, "action_selected")
