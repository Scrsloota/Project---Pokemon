extends Scene2D
class_name Linen

signal enemies_encountered(wild_pokemon)
signal dialogue_finished

onready var dialogue_box = get_node("../../MapInterface/DialogueBox")
onready var player = $YSort/Player


func _ready() -> void:
	#初始化每个可交互点可以执行的动作
	for action in get_tree().get_nodes_in_group("map_action"):
		(action as MapAction).initialize(self)


func spawn_party(party) -> void:
	$Pawns.spawn_party(party, player)


func start_encounter(wild_pokemon) -> void:
	emit_signal("enemies_encountered", wild_pokemon)
