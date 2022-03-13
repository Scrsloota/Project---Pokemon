# Responsible for transitions between the main game screens:
# combat, game over, and the map
extends Node

signal combat_started
const combat_arena_scene = preload("res://src/combat/CombatArena.tscn")
onready var transition = $Overlays/TransitionColor
onready var party = $Party as Party
onready var music_player = $MusicPlayer
onready var depository = $PokemonDepository
onready var inventory = Inventory.new()

var transitioning = false
var combat_arena: CombatArena

var player_location = Vector2(0, 0)
var player_direction = Vector2(0, 0)

var network_pvp_ongoing: bool = false


func _ready():
	randomize()
	var current_scene = $SceneManager.get_current_scene()
	current_scene.spawn_party(party)
	current_scene.visible = true
	current_scene.connect("enemies_encountered", self, "enter_battle")
	music_player.play_town_theme()

	
	inventory.add(preload("res://src/items/meds/GoodRecoveryPP.tres"),10)
	inventory.add(preload("res://src/items/meds/GoodRecoveryHP.tres"),10)
	inventory.add(preload("res://src/items/pokemonBall/GreatBall.tres"),10)
	inventory.add(preload("res://src/items/pokemonBall/MasterBall.tres"),10)

func enter_party_screen():
	if transitioning:
		return
	transitioning = true
	yield(transition.fade_to_color(), "completed")
	$Menu.load_party_screen()
	yield(transition.fade_from_color(), "completed")
	transitioning = false


func quit_party_screen():
	if transitioning:
		return
	transitioning = true
	yield(transition.fade_to_color(), "completed")
	$Menu.unload_party_screen()
	yield(transition.fade_from_color(), "completed")
	transitioning = false


func enter_other_scene(new_scene, spawn_location, spawn_direction):
	print("entering new scene" + new_scene)
	var next_scene = new_scene
	player_location = spawn_location
	player_direction = spawn_direction
	if transitioning:
		return
	transitioning = true
	yield(transition.fade_to_color(), "completed")
	$SceneManager.switch_map(load(next_scene).instance())
	var player = $SceneManager.get_player()
	
	player.set_spawn(player_location, player_direction)
	
	yield(transition.fade_from_color(), "completed")
	transitioning = false


func enter_network_pvp_battle():
	if transitioning:
		return
	
	if network_pvp_ongoing:
		return
	network_pvp_ongoing = true
	
	print("Network starting")
	var peer = load("src/network/MultiplayerInterface.tscn").instance()
	add_child(peer)
	
	peer.start(Properties.get('server_url'))
	yield(peer, "pinp_peer_connected")
	print("connected")
	var serialized_battler = Utils.save_battler(party.get_child(0))
	peer.put_var(serialized_battler)
	var network_battler = yield(peer.get_var(), "completed")
	
	var s
	if peer.is_main_node():
		s = randi()
		peer.put_var({'seed': s})
		RandomGenerater.is_main_node = true
	else:
		s = yield(peer.get_var(), "completed")
		s = s['seed']
		RandomGenerater.is_main_node = false
	RandomGenerater.set_seed(s)
	
	network_battler = Utils.load_battler(network_battler)
	music_player.play_battle_theme()

	transitioning = true
	yield(transition.fade_to_color(), "completed")

	combat_arena = combat_arena_scene.instance()
	$SceneManager.switch_to_battle(combat_arena)
	combat_arena.connect("victory", self, "_on_CombatArena_player_victory")
	combat_arena.connect("game_over", self, "_on_CombatArena_game_over")
	combat_arena.connect(
		"battle_completed", self, "_on_CombatArena_battle_completed", [combat_arena]
	)

	combat_arena.initialize(network_battler, party.get_children(), inventory, peer)

	yield(transition.fade_from_color(), "completed")
	transitioning = false

	combat_arena.battle_start()
	emit_signal("combat_started")

func enter_battle(wild_pokemon: Battler):
	# Plays the combat transition animation and initializes the combat scene
	if transitioning:
		return

	music_player.play_battle_theme()

	transitioning = true
	yield(transition.fade_to_color(), "completed")

	combat_arena = combat_arena_scene.instance()
	$SceneManager.switch_to_battle(combat_arena)
	combat_arena.connect("victory", self, "_on_CombatArena_player_victory")
	combat_arena.connect("game_over", self, "_on_CombatArena_game_over")
	combat_arena.connect(
		"battle_completed", self, "_on_CombatArena_battle_completed", [combat_arena]
	)
	combat_arena.connect("catch_wild_pokemon", self, "_on_catch_wild_pokemon")

	combat_arena.initialize(wild_pokemon, party.get_children(), inventory, null)

	yield(transition.fade_from_color(), "completed")
	transitioning = false

	combat_arena.battle_start()
	emit_signal("combat_started")


func _on_CombatArena_battle_completed(arena):
	# At the end of an encounter, fade the screen, remove the combat arena
	# and add the local map back
	transitioning = true
	yield(transition.fade_to_color(), "completed")
	combat_arena.queue_free()
	$SceneManager.switch_back_to_map()
	yield(transition.fade_from_color(), "completed")
	transitioning = false
	network_pvp_ongoing = false
	music_player.play_town_theme()


func _on_CombatArena_player_victory():
	music_player.play_victory_fanfare()


func _on_CombatArena_game_over() -> void:
	pass
	
func _on_catch_wild_pokemon(wild_pokemon: Battler):	
	var self_pokemon = wild_pokemon.duplicate()
	if party.get_child_count() < 6:
		party.add_child(self_pokemon)
	else:
		depository.add_child(self_pokemon)
	self_pokemon.change_skin(0)
	self_pokemon.battler_name = self_pokemon.stats.pokemon_name
	self_pokemon.party_member = true

func get_inventory():
	return inventory


func _on_GameOverInterface_restart_requested():
	# TODO
	# When gameover, deduct some money and send character back to pokemon center
	pass

	# game_over_interface.hide()
	# var formation = combat_arena.initial_formation
	# combat_arena.queue_free()
	# enter_battle(formation)

func _on_Menu_change_preset(index):
	$MusicPlayer.change_preset(index)

func heal_all_pokemons():
	print("heal_all_pokemons")
	var children = party.get_children()
	for child in children:
		child.stats.reset()

func get_pokemons_in_depository():
	return $PokemonDepository.get_children()

func get_pokemons_in_party():
	return $Party.get_children()
	
func set_pokemons_in_depository(pokemon,index):
	if index < len(party.get_children()):
		var current_pokemon = party.get_child(index)
		party.remove_child(current_pokemon)
		depository.add_child(current_pokemon)
	if pokemon:
		depository.remove_child(pokemon)
		party.add_child(pokemon)
	
	
