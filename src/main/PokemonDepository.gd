# Container for the player's party
# Holds all playable game characters whether the player
# has already unlocked them or not in the game.
# After an encounter, it delegates stats update (experience and health) to each
# active party member
extends Node2D
class_name PokemonDepository

export var PARTY_SIZE: int = 3

var inventory = Inventory.new()


func _ready():
	add_child(PokemonFactory.construct_battler("Bulbasaur",0))
	add_child(PokemonFactory.construct_battler("Charmander",0))
	add_child(PokemonFactory.construct_battler("Squirtle",0))
	add_child(PokemonFactory.construct_battler("Pikachu",0))
	add_child(PokemonFactory.construct_battler("Pidgey",0))
	add_child(PokemonFactory.construct_battler("Grimer",0))
	
	
 
func get_active_members():
	# Returns the first unlocked children until the party is filled
	var active = []
	var available = get_unlocked_characters()
	for i in range(min(len(available), PARTY_SIZE)):
		active.append(available[i])
	return active


func get_unlocked_characters() -> Array:
	# Returns all the characters that can be active in the party
	var has_unlocked = []
	for member in get_children():
		if member.visible:
			has_unlocked.append(member)
	return has_unlocked
