extends Node


func construct_battler(pokemon_name: String, create_type: int) -> Battler:
	var rnt = preload("res://src/combat/battlers/Battler.tscn").instance()
	if create_type == 0:
		rnt.stats = load("res://src/combat/battlers/stats/Self%sStats.tres" % pokemon_name).copy()
	if create_type == 1:
		rnt.stats = load("res://src/combat/battlers/stats/Oppo%sStats.tres" % pokemon_name).copy()

	add_child(rnt)
	remove_child(rnt)
	
	rnt.stats.pokemon_name = pokemon_name

	rnt.stats.reset()

	if create_type == 0: # selfpokemon
		rnt.party_member = true
		rnt.change_skin(create_type)
		rnt.battler_name = pokemon_name
	elif create_type == 1:
		rnt.change_skin(create_type)
		rnt.battler_name = "Wild " + pokemon_name
	return rnt


func construct_battler_from_state_dict(dict, create_type: int) -> Battler:
	var stats = Utils.load_stats(dict['stats'])
	var battler = preload("res://src/combat/battlers/Battler.tscn").instance()
	battler.stats = stats
	battler.battler_name = dict['battler_name']
	battler.party_member = dict['party_member']
	
	add_child(battler)
	remove_child(battler)
	
	if create_type == 0: # selfpokemon
		battler.party_member = true
		battler.change_skin(create_type)
	elif create_type == 1:
		battler.party_member = false
		battler.change_skin(create_type)
	
	battler.selected = dict['selected']
	battler.selectable = dict['selectable']
	
	return battler

