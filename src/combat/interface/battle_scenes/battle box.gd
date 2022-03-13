extends CanvasLayer

onready var select_arrow = $Control/TextureRect/arrow
onready var menu = $Control
enum ScreenLoaded { JUST_MENU, }
var screen_loaded = ScreenLoaded.JUST_MENU
#enum ScreenLoaded { NOTHING, JUST_MENU, PARTY_SCREEN, }
#var screen_loaded = ScreenLoaded.NOTHING

var selected_option: int = 0

func _ready():
	menu.visible = false
	select_arrow.rect_position.x = 8
	select_arrow.rect_position.y = 18

func load_party_screen():
	menu.visible = false
	#screen_loaded = ScreenLoaded.PARTY_SCREEN
	#var party_screen = PokemonPartyScreen.instance()
	#add_child(party_screen)
	
	
func unload_party_screen():
	menu.visible = true
	#screen_loaded = ScreenLoaded.JUST_MENU
	#remove_child($PokemonPartyScreen)

func _unhandled_input(event):
	match screen_loaded:
		#ScreenLoaded.NOTHING:
			#if event.is_action_pressed("menu"):
				#var player = Utils.get_player()
				#if !player.is_moving:
					#player.set_physics_process(false)
					#menu.visible = true
					#screen_loaded = ScreenLoaded.JUST_MENU
		
		ScreenLoaded.JUST_MENU:
			if event.is_action_pressed("ui_down"):
				selected_option += 1
			elif event.is_action_pressed("ui_up"):
				if selected_option == 0:
					selected_option = 3
				else:
					selected_option -= 1
			if selected_option % 2 == 0:
				select_arrow.rect_position.y = 18
			else: 
				select_arrow.rect_position.y = 34
			if selected_option % 4 < 2:
				select_arrow.rect_position.x = 8
			else:
				select_arrow.rect_position.x = 64
