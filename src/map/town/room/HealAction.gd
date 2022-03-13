extends MapAction
class_name HealAction

onready var select_arrow = $SelectArrow
onready var diaglog_box = $DialogBox
onready var menu_selectable = false
onready var dialog_list = [" Hello traveller! Do you want to heal your pokemons?\n                       Yes                                  No",
"Please hold on for a sec","All your pokemons have become healthy again!","Goodbye traveller! Have a nice trip!"
]
onready var dialog_state:int = 0
onready var game = get_node("/root/Game")
signal heal_pokemons

export (String, FILE, "*.json") var dialogue_file_path: String
signal dialogue_loaded(data)

var selected_option: int = 0

func set_menu_selectable(flag:bool):
	menu_selectable = flag

func _ready():
	connect("heal_pokemons",game,"heal_all_pokemons")
	diaglog_box.visible = false
	select_arrow.visible = false
	select_arrow.rect_position.x = 430 + selected_option*750

func interact() -> void:
	menu_selectable = true
	get_tree().set_input_as_handled()
	diaglog_box.visible = true
	select_arrow.visible = true
	select_arrow.anim_player.play("wiggle")
	var player = get_node("/root/Game/SceneManager").get_player()
	if !player.is_moving:
		player.set_physics_process(false)
		dialog_state = 0
		selected_option = 0
		select_arrow.rect_position.x = 430 + selected_option*750
	
func refresh():
	$DialogBox/Box/Message.text = str(dialog_list[dialog_state])


func _unhandled_input(event):
	if menu_selectable:
		match dialog_state:
			0:
				if  event.is_action_pressed("interaction_with_pawn"):
					get_tree().set_input_as_handled()
					if selected_option == 0:
						dialog_state = 1
						emit_signal("heal_pokemons")
						refresh()
						select_arrow.visible = false
					else:
						dialog_state = 3
						refresh()
						select_arrow.visible = false
				elif event.is_action_pressed("ui_left"):
					get_tree().set_input_as_handled()
					if selected_option == 0:
						selected_option = 1
					else:
						selected_option = 0
					select_arrow.rect_position.x = 430 + selected_option*710
				elif event.is_action_pressed("ui_right"):
					get_tree().set_input_as_handled()
					if selected_option == 0:
						selected_option = 1
					else:
						selected_option = 0
					select_arrow.rect_position.x = 430 + selected_option*710
			1:
				if  event.is_action_pressed("interaction_with_pawn"):
					get_tree().set_input_as_handled()
					dialog_state = 2 
					refresh()
			2:
				if  event.is_action_pressed("interaction_with_pawn"):
					get_tree().set_input_as_handled()
					dialog_state = 3
					refresh()
			3:
				if  event.is_action_pressed("interaction_with_pawn"):
					dialog_state = 0
					refresh()
					get_tree().set_input_as_handled()
					menu_selectable = false
					diaglog_box.visible = false
					select_arrow.visible = false
					var player = get_node("/root/Game/SceneManager").get_player()
					player.set_physics_process(true)
					emit_signal("finished")


