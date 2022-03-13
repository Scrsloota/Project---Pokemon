extends Item
class_name RecoveryHP

export (int) var healing_value = 1

func implement_function(actor, target) -> Array:	
	actor.stats.heal(healing_value)
	return "%s's HP has been recovered!" % actor.stats.text_name
