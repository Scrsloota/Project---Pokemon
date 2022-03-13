extends Node

var experience_earned: float = 0.0
var party: Array = []

const loss_messages = ["blacked out!", "Out of usable Pokemon!", "Hesitation Is Defeat!"]

func initialize(wild_pokemon: Battler):
	# We rely on signals to only add experience of enemies that have been defeated.
	# This allows us to support enemies running away and not receiving exp for them,
	# as well as allowing the party to run away and only earn partial exp
#	$Panel.visible = false
	party = []
	experience_earned = _calculate_experience(wild_pokemon.stats)


func _calculate_experience(wild_pokemon_stats: CharacterStats):
	var level = wild_pokemon_stats._get_level()
	return level * level * 10

func add_appearing(pokemon: Battler):
	party.append(pokemon)

func on_battle_loss():
	return loss_messages[randi() % len(loss_messages)]

func on_battle_completed():
	var message = []

	var survival = []
	for pokemon in party:
		if pokemon.stats.health != 0:
			survival.append(pokemon)

	if survival:
		var experience = int(experience_earned/len(survival))
		for pokemon in survival:
			var new_level = pokemon.stats.add_experience(experience)
			message.append("%s gained %d Exp!" % [pokemon.stats.text_name, experience])
			if new_level!=0:
				message.append("%s growed to Lv. %d!" % [pokemon.stats.text_name, new_level])
	
	return message
