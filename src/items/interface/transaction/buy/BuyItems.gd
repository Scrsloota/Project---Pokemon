extends CanvasLayer
onready var selectable:bool = false
onready var select_arrow = $Control/SelectArrow
onready var parent_menu = get_parent().get_parent()
onready var control = $Control
onready var item_change = preload("res://src/items/interface/transaction/buy/BuyConfirm.tscn")
signal buy_menu_activate
var item_name_list = ["GoodRecoveryHP","GoodRecoveryPP","AbnormalFreeMed","PokemonBall","GreatBall","UltraBall","MasterBall"]

var selected_option: int = 0

func _ready():
	pass # Replace with function body.
	select_arrow.anim_player.play("wiggle")

func reset():
	selectable = true



func _unhandled_input(event):
	if selectable:
		if event.is_action_pressed("ui_down"):
			get_tree().set_input_as_handled()
			selected_option += 1
			selected_option  = selected_option % 7
			select_arrow.rect_position.y = 100 + selected_option * 90
			refresh()
		elif event.is_action_pressed("ui_up"):
			get_tree().set_input_as_handled()
			if selected_option == 0:
				selected_option = 6
			else:
				selected_option -= 1
			selected_option = selected_option % 7
			select_arrow.rect_position.y = 100 + selected_option * 90
			refresh()
		if  event.is_action_pressed("interaction_with_pawn"):
			selectable = false
			var child = item_change.instance()
			var text = str(item_name_list[selected_option])
			var image = $Control/Icons.get_child(selected_option).texture
			connect("buy_menu_activate",child,"initialize")
			emit_signal("buy_menu_activate",text,image)
			add_child(child)
			
		if event.is_action_pressed("ui_cancel"):
			get_tree().set_input_as_handled()
			var player = get_node("/root/Game/SceneManager").get_player()
			player.set_physics_process(true)
			$Control.visible = false
			selectable = false
			parent_menu.set_menu_selectable(true)
					
func refresh():
	$Control/BigIcon/Root/Body.texture = $Control/Icons.get_child(selected_option).texture
	var item = null
	if(selected_option<=2):
		item = load("res://src/items/meds/"+str(item_name_list[selected_option])+".tres")
	else:
		item = load("res://src/items/pokemonBall/"+str(item_name_list[selected_option])+".tres")
	$Control/Description.text =  item.description
	$Control/BigIcon.play_walk()
	$Control/Thank.play_walk()
