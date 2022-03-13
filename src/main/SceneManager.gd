extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var INACTIVE_MAP = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func switch_map(new_scene):
	var current_map = get_child(0)
	remove_child(current_map)
	current_map.queue_free()
	add_child(new_scene)
	if new_scene.has_signal("enemies_encountered"):
		new_scene.connect("enemies_encountered",get_game(), "enter_battle")
	if new_scene.has_signal("network_player_encountered"):
		new_scene.connect("network_player_encountered",get_game(), "enter_network_pvp_battle")
	
func switch_to_battle(battle_scene):
	var current_map = get_child(0)
	INACTIVE_MAP = current_map
	remove_child(current_map)
	add_child(battle_scene)
	
func switch_back_to_map():
	var battle_scene = get_child(0)
	remove_child(battle_scene)
	add_child(INACTIVE_MAP)
	# suppose to be unnecessary code 
#	if INACTIVE_MAP.has_signal("enemies_encountered"):
#		INACTIVE_MAP.connect("enemies_encountered",get_game(), "enter_battle")
	INACTIVE_MAP = null

func get_current_scene():
	return get_child(0)

func get_player():
	return get_child(0).get_player()
	
func get_game():
	return get_parent()
