extends Node2D

class_name CombatArena

#const BattlerNode = preload("res://src/combat/battlers/Battler.tscn")

onready var turn_queue: TurnQueue = $TurnQueue
onready var interface = $CombatInterface
onready var rewards = $Rewards
onready var anim_layer = $AnimLayer

var inventory

var active: bool = false
var party: Array = []
var all_party_pokemons: Array = []
var run_away_status = false
var catch_satus = false
var network_peer = null

var self_ai: BattlerAI = null
var oppo_ai: BattlerAI = null
# TODO: Refactor and clean up this script
# sent when the battler is starting to end (before battle_completed)
signal battle_ends
# sent when battle is completed, contains status updates for the party
# so that we may persist the data
signal battle_completed
signal victory
signal game_over
signal catch_wild_pokemon


func initialize(wild_pokemon: Battler, all_party_pokemons: Array, inventory: Inventory, network_peer):
	self.network_peer = network_peer
	$Background.frame = RandomGenerater.randi() % 11
	if self.network_peer == null:
		self_ai = PlayerInput.new()
		oppo_ai = RandomAI.new()
		self_ai.set("interface", interface)
	else:
		self_ai = NetworkSelfAI.new()
		oppo_ai = NetworkOppoAI.new()
		self_ai.initialize(self.network_peer)
		oppo_ai.initialize(self.network_peer)
		self_ai.set("interface", interface)
	
	var prime_party_pokemon: Battler = all_party_pokemons[0].duplicate()
	self.all_party_pokemons = all_party_pokemons
	self.inventory = inventory

	ready_field(wild_pokemon, prime_party_pokemon)

	# reparent the enemy battlers into the turn queue
	wild_pokemon.initialize()
	prime_party_pokemon.initialize()

	interface.initialize(wild_pokemon, prime_party_pokemon, all_party_pokemons,inventory.get_content(self.network_peer))
	rewards.initialize(wild_pokemon)
	turn_queue.initialize()

	rewards.add_appearing(prime_party_pokemon)


func battle_start():
	yield(play_intro(), "completed")
	active = true
	play_turn()


func play_intro():
	for battler in turn_queue.get_party():
		battler.appear()
	yield(get_tree().create_timer(0.5), "timeout")
	for battler in turn_queue.get_monsters():
		battler.appear()
	yield(get_tree().create_timer(0.5), "timeout")


func ready_field(wild_pokemon: Battler, party_pokemon: Battler):
	# use a formation as a factory for the scene's content
	# @param formation - the combat template of what the player will be fighting
	# @param party_members - list of active party battlers that will go to combat

	var spawn_positions = $SpawnPositions

	turn_queue.add_child(wild_pokemon)
	wild_pokemon.position = spawn_positions.get_node("Oppo").position

	# TODO move this into a battler factory and pass already copied info into the scene
	turn_queue.add_child(party_pokemon)
	party_pokemon.position = spawn_positions.get_node("Self").position

	# battler.set_meta("party_pokemon", party_pokemon)  # To get original party member when need
	# self.party.append(party_pokemon)

	# safely attach the interface to the AI in case player input is needed
#	wild_pokemon.ai.set("interface", interface)
	if network_peer != null:
		wild_pokemon.change_skin(1)
		wild_pokemon.party_member = false


func battle_end():
	emit_signal("battle_ends")
	active = false
	var active_battler = get_active_battler()
	active_battler.selected = false
	var player_loss = active_battler.party_member
	if not player_loss:
		emit_signal("victory")
		var message = rewards.on_battle_completed()
		yield(interface.show_message(message), "completed")
		emit_signal("battle_completed")
	else:
		emit_signal("game_over")
		var message = rewards.on_battle_loss()
		yield(interface.show_message([message]), "completed")
		emit_signal("battle_completed")


func battler_flee():
	emit_signal("battle_ends")
	emit_signal("battle_completed")
	
func catch_pokemon():
	emit_signal("catch_wild_pokemon",turn_queue.get_monsters()[0])
	emit_signal("battle_ends")
	emit_signal("battle_completed")


func play_turn():
	var battler: Battler = get_active_battler()
	var action: CombatAction

	while not battler.is_able_to_play():
		turn_queue.skip_turn()
		battler = get_active_battler()

	battler.selected = true
	var opponents: Array = get_targets()
	if not opponents:
		battle_end()
		return
	
#	var yield_action = battler.ai.choose_action(battler)
	var yield_action = null
	if battler.party_member:
		yield_action = self_ai.choose_action(battler)
	else:
		yield_action = oppo_ai.choose_action(battler)
	if yield_action is GDScriptFunctionState:
		action = yield(yield_action, "completed")
	else:
		action = yield_action
		
	var ball_flag = false

	if action is SkillAction:
		action.connect("anim_start_signal",self,"_on_anim_start_signal")
		action.connect("anim_stop_signal",self,"_on_anim_stop_signal")
	if action is ChangeAction:
		action.connect("change_pokemon", self, "_on_change_pokemon")
	if action is RunAction:
		action.connect("run_away", self, "_on_run_away")
	if action is ItemAction:
		action.inventory = inventory
		if action.item is PokemonBall:
			if network_peer==null:
				action.item.connect("catch_success", self, "_on_catch_success")
			else:
				ball_flag = true
	if action is SurrenderAction:
		yield(interface.show_message(["Enemy surrendered"]), "completed")
		battle_end()

	battler.selected = false
	
	var message
	if ball_flag:
		message = ["You try to cheat!! ^m^"]
	else:
		message = yield(turn_queue.play_turn(action, battler, opponents[0]), "completed")
	yield(interface.show_message(message), "completed")
	
	if run_away_status:
		battler_flee()
		return
		
	if catch_satus:
		catch_pokemon()
		return

	interface.update_status()
	yield(turn_ending_stage(battler.stats), "completed")
	if opponents[0].get_cur_hp() == 0:
		if opponents[0].party_member:
			yield_action = self_ai.choose_action(opponents[0], false)
		else:
			yield_action = oppo_ai.choose_action(opponents[0], false)
		if yield_action is GDScriptFunctionState:
			action = yield(yield_action, "completed")
		else:
			action = yield_action
		if action is ChangeAction:
			action.connect("change_pokemon", self, "_on_change_pokemon")
			yield(action.execute(opponents[0], battler), "completed")
			yield(interface.show_message(["New Pokemon entered the battle"]), "completed")
		else:
			battle_end()
	if battler.get_cur_hp() == 0:
		if battler.party_member:
			yield_action = self_ai.choose_action(battler, false)
		else:
			yield_action = oppo_ai.choose_action(battler, false)
		if yield_action is GDScriptFunctionState:
			action = yield(yield_action, "completed")
		else:
			action = yield_action
		if action is ChangeAction:
			action.connect("change_pokemon", self, "_on_change_pokemon")
			yield(action.execute(opponents[0], battler), "completed")
			yield(interface.show_message(["New Pokemon entered the battle"]), "completed")
		else:
			battle_end()

	if active:
		play_turn()

	interface.update_status()


func get_active_battler():
	return turn_queue.active_battler


func get_targets() -> Array:
	if get_active_battler().party_member:
		return turn_queue.get_monsters()
	else:
		return turn_queue.get_party()


func turn_ending_stage(battler_stat):
	var ending_message = battler_stat.ending_stage_nv_status()
	if ending_message:
		yield(interface.show_message(ending_message), "completed")
	else:
		yield(get_tree().create_timer(0), "timeout")


func _on_change_pokemon(input_change_pokemon: Battler, self_side: bool):
	var change_pokemon = input_change_pokemon.duplicate()
	var cur_self_pokemon = turn_queue.get_party_nocheck()
	var cur_oppo_pokemon = turn_queue.get_monster_nocheck()
	if self_side:
		turn_queue.remove_child(cur_self_pokemon)
		turn_queue.add_child(change_pokemon)
		change_pokemon.position = $SpawnPositions.get_node("Self").position
		for i in len(self.all_party_pokemons):
			if self.all_party_pokemons[i].equal(change_pokemon):
				self.all_party_pokemons.remove(i)
				break
		all_party_pokemons.push_front(change_pokemon)
		interface.initialize(cur_oppo_pokemon, change_pokemon, self.all_party_pokemons, self.inventory.get_content(self.network_peer))
		
	else:
		turn_queue.remove_child(cur_oppo_pokemon)
		turn_queue.add_child(change_pokemon)
		change_pokemon.position = $SpawnPositions.get_node("Oppo").position
		interface.initialize(change_pokemon, cur_self_pokemon, self.all_party_pokemons, self.inventory.get_content(self.network_peer))
		
	change_pokemon.initialize()
	change_pokemon.appear()

	rewards.add_appearing(change_pokemon)


func _on_run_away():
	run_away_status = true


func _on_catch_success():
	catch_satus = true
	
func _on_anim_start_signal(anim):
	anim_layer.add_child(anim)
	
func _on_anim_stop_signal(anim):
	anim_layer.remove_child(anim)
