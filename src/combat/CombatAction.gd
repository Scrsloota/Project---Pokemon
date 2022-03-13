extends Node

class_name CombatAction

export (String) var description: String = "Base combat action"

func execute(actor: Battler, target: Battler):
	print("%s missing overwrite of the execute method" % name)
	return false


func return_to_start_position(actor):
	yield(actor.skin.return_to_start(), "completed")
