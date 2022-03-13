extends MapAction
class_name StartCombatAction

export var wild_pokemon: String

const pokemon_sets = ["Charmander", "Pikachu", "Grimer", "Pidgey", "Bulbasaur", "Squirtle"]

func interact() -> void:
	get_tree().paused = false
	var pokemon: String = pokemon_sets[randi() % len(pokemon_sets)] 
	local_map.start_encounter(PokemonFactory.construct_battler(pokemon, 1))
	emit_signal("finished")
