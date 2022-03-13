extends Item
class_name PokemonBall

signal catch_success

export (float) var success_rate = 0

func implement_function(actor, target):
	if randf() < success_rate:
		emit_signal("catch_success")
		return "Gotcha! %s was caught!" % target.stats.pokemon_name
	else:
		return "Catching failed!"
