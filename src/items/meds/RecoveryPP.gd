extends Item
class_name RecoveryPP

func implement_function(actor, target):
	actor.stats.recover_pp()
	return "%s's PP has been recovered!" % actor.stats.text_name
