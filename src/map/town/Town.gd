# Initializes the map's pawns and emits signals so the
# Game node can start encounters
# Processes in pause mode
extends Scene2D
class_name Town

signal enemies_encountered(wild_pokemon)
signal dialogue_finished

onready var player = $YSort/Player

func _ready() -> void:
	#初始化每个可交互点可以执行的动作
	for action in get_tree().get_nodes_in_group("map_action"):
		(action as MapAction).initialize(self)


func spawn_party(party) -> void:
	$Pawns.spawn_party(party, player)


func start_encounter(wild_pokemon) -> void:
	emit_signal("enemies_encountered", wild_pokemon)
#	emit_signal("network_player_encountered")
