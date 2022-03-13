extends CanvasLayer

#const PokemonPartyScreen = preload("./PokemonPartyScreen.tscn")

signal change_preset(index)

onready var select_arrow = $Control/NinePatchRect/Arrow
onready var menu = $Control

enum ScreenLoaded { NOTHING, JUST_MENU, MUSIC_SWITCHER, POKEMON_BAG, BAG, CHANGE_SKILL, AUTHORS, DONATE}
var screen_loaded = ScreenLoaded.NOTHING
const arrow_offset = 26
const num_options = 6

var selected_option: int = 0
var icon = null

func _ready():
	menu.visible = false
	selected_option = 0
	$Control/NinePatchRect/VBoxContainer.get_children()[selected_option].rect_position.y

func exit_menu():
	var player = Utils.get_player()
	player.set_physics_process(true)
	menu.visible = false
	screen_loaded = ScreenLoaded.NOTHING
	
func handle_select():
	match selected_option:
		0:
			$PokemonPartyScreen.initialize(Utils.get_player_bag())
			$PokemonPartyScreen.visible = true
			screen_loaded = ScreenLoaded.POKEMON_BAG
		1:
			$Bag.visible = true
			screen_loaded = ScreenLoaded.BAG
			var tmp = Utils.get_inventory().content
			$Bag.initialize(Utils.get_inventory().content)
			$Bag.reset()
		2:
			screen_loaded = ScreenLoaded.AUTHORS
			$Authors.visible = true
		3:
			screen_loaded = ScreenLoaded.DONATE
			$Donate.visible = true
		4:
			# Music switcher
			screen_loaded = ScreenLoaded.MUSIC_SWITCHER
			$MusicSwitcher.visible = true
			select_arrow.visible = false
			$MusicSwitcher.reset()
		5:
			exit_menu()
		_:
			pass

func _unhandled_input(event):
	match screen_loaded:
		ScreenLoaded.NOTHING:
			if event.is_action_pressed("menu_calling"):
				var player = get_node("/root/Game/SceneManager").get_player()
				if !player.is_moving:
					player.set_physics_process(false)
					menu.visible = true
					screen_loaded = ScreenLoaded.JUST_MENU
		
		ScreenLoaded.JUST_MENU:
			if event.is_action_pressed("menu_calling") or event.is_action_pressed("ui_cancel"):
				exit_menu()
			elif event.is_action_pressed("ui_down"):
				selected_option = (selected_option + 1) % num_options
				select_arrow.rect_position.y = $Control/NinePatchRect/VBoxContainer.get_children()[selected_option].rect_position.y + arrow_offset
			elif event.is_action_pressed("ui_up"):
				selected_option = (selected_option + num_options - 1) % num_options
				select_arrow.rect_position.y = $Control/NinePatchRect/VBoxContainer.get_children()[selected_option].rect_position.y + arrow_offset
			elif event.is_action_pressed("ui_accept"):
				handle_select()
		ScreenLoaded.MUSIC_SWITCHER:
			$MusicSwitcher.on_event(event)
		ScreenLoaded.POKEMON_BAG:
			$PokemonPartyScreen.on_event(event)
		ScreenLoaded.BAG:
			$Bag.on_event(event)
		ScreenLoaded.CHANGE_SKILL:
			$PokemonPartyScreen/SkillChangeRect.on_event(event)
		ScreenLoaded.AUTHORS:
			if event.is_action_pressed("ui_cancel"):
				$Authors.visible = false
				screen_loaded = ScreenLoaded.JUST_MENU
		ScreenLoaded.DONATE:
			if event.is_action_pressed("ui_cancel"):
				$Donate.visible = false
				screen_loaded = ScreenLoaded.JUST_MENU

func _on_MusicSwitcher_exit():
	$MusicSwitcher.visible = false
	select_arrow.visible = true
	screen_loaded = ScreenLoaded.JUST_MENU


func _on_MusicSwitcher_change_bgm_preset(index):
	emit_signal("change_preset", index)


func _on_PokemonPartyScreen_cancel():
	$PokemonPartyScreen.visible = false
	screen_loaded = ScreenLoaded.JUST_MENU


func _on_Bag_cancel():
	$Bag.visible = false
	screen_loaded = ScreenLoaded.JUST_MENU

func _on_PokemonPartyScreen_show_change_skill(index):
	if screen_loaded==ScreenLoaded.POKEMON_BAG:
		$PokemonPartyScreen/SkillChangeRect.initialize(Utils.get_player_bag()[index])
		$PokemonPartyScreen/SkillChangeRect.visible = true
		screen_loaded = ScreenLoaded.CHANGE_SKILL


func _on_SkillChangeRect_exit_change_skill_menu():
	if screen_loaded==ScreenLoaded.CHANGE_SKILL:
		$PokemonPartyScreen/SkillChangeRect.visible = false
		screen_loaded = ScreenLoaded.POKEMON_BAG
