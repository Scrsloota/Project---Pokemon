extends MapAction
class_name ShopAction


onready var shop_menu = $ShopMenu/Control
onready var buy_menu = $ShopMenu/BuyMenu/Control
onready var sell_menu = $ShopMenu/SellMenu/Control
onready var select_arrow = $ShopMenu/Control/NinePatchRect/TextureRect
onready var menu_selectable = false
export (String, FILE, "*.json") var dialogue_file_path: String
signal dialogue_loaded(data)
enum ScreenLoaded { BUY,SELL,EXIT }
var screen_loaded = ScreenLoaded.BUY

var selected_option: int = 0

func set_menu_selectable(flag:bool):
	menu_selectable = flag

func _ready():
	shop_menu.visible = false
	sell_menu.visible = false
	buy_menu.visible = false
	select_arrow.rect_position.y = 9 + (selected_option % 3) * 15

func interact() -> void:
	menu_selectable = true
	get_tree().set_input_as_handled()
	var player = get_node("/root/Game/SceneManager").get_player()
	if !player.is_moving:
		player.set_physics_process(false)
		shop_menu.visible = true
		screen_loaded = ScreenLoaded.BUY
		selected_option = 0
		select_arrow.rect_position.y =  9 + (selected_option % 3) * 15
	
	
func _unhandled_input(event):
	if menu_selectable:
		match screen_loaded:
			ScreenLoaded.BUY:
				print("buy")
				if  event.is_action_pressed("interaction_with_pawn"):
					buy_menu.visible = true
					$ShopMenu/BuyMenu.selectable = true
					menu_selectable = false
					pass
				elif event.is_action_pressed("ui_down"):
					get_tree().set_input_as_handled()
					selected_option += 1
					select_arrow.rect_position.y = 9 + (selected_option % 3) * 15
					screen_loaded =  ScreenLoaded.SELL
				elif event.is_action_pressed("ui_up"):
					get_tree().set_input_as_handled()
					if selected_option == 0:
						selected_option = 2
					else:
						selected_option -= 1
					select_arrow.rect_position.y =  9 + (selected_option % 3) * 15
					screen_loaded =  ScreenLoaded.EXIT
					
			ScreenLoaded.SELL:
				print("sell")
				if  event.is_action_pressed("interaction_with_pawn"):
					sell_menu.visible = true
					$ShopMenu/SellMenu.selectable = true
					menu_selectable = false
					pass
				elif event.is_action_pressed("ui_down"):
					get_tree().set_input_as_handled()
					selected_option += 1
					select_arrow.rect_position.y = 9 + (selected_option % 3) * 15
					screen_loaded =  ScreenLoaded.EXIT
				elif event.is_action_pressed("ui_up"):
					get_tree().set_input_as_handled()
					if selected_option == 0:
						selected_option = 2
					else:
						selected_option -= 1
					select_arrow.rect_position.y = 9 + (selected_option % 3) * 15
					screen_loaded =  ScreenLoaded.BUY
			
			
			ScreenLoaded.EXIT:
				print("exit")
				#quit
				if  event.is_action_pressed("interaction_with_pawn"):
					get_tree().set_input_as_handled()
					var player = get_node("/root/Game/SceneManager").get_player()
					player.set_physics_process(true)
					shop_menu.visible = false
					menu_selectable = false
					emit_signal("finished")
				elif event.is_action_pressed("ui_down"):
					get_tree().set_input_as_handled()
					selected_option += 1
					select_arrow.rect_position.y = 9 + (selected_option % 3) * 15
					screen_loaded =  ScreenLoaded.BUY
				elif event.is_action_pressed("ui_up"):
					get_tree().set_input_as_handled()
					if selected_option == 0:
						selected_option = 2
					else:
						selected_option -= 1
					select_arrow.rect_position.y = 9 + (selected_option % 3) * 15
					screen_loaded =  ScreenLoaded.SELL
					


