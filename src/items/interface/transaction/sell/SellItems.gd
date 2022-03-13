extends CanvasLayer
onready var selectable:bool = false
onready var select_arrow = $Control/SelectArrow
onready var parent_menu = get_parent().get_parent()
onready var item_change = preload("res://src/items/interface/transaction/sell/SellConfirm.tscn")
onready var inventory = get_node("/root/Game").get_inventory()
onready var big_icon = $Control/BigIcon
onready var thank = $Control/Thank
onready var descirption = $Control/Description
onready var control = $Control

signal buy_menu_activate
var selected_option: int = 0
var item_list
var num_list
var list_size:int = 0 
var item2num

func _ready():
	select_arrow.anim_player.play("wiggle")
	initialize()
	refresh_all_items()
	refresh()

func reset():

	selectable = true
	
func initialize():
	item_list = []
	num_list = []
	item2num = inventory.content
	for key in item2num:
		item_list.append(key)
		num_list.append(item2num[key])
	list_size = len(item_list)

func _unhandled_input(event):
	if selectable:
		if event.is_action_pressed("ui_down"):
			get_tree().set_input_as_handled()
			selected_option += 1
			selected_option  = selected_option % list_size
			select_arrow.rect_position.y = 100 + selected_option * 90
			refresh()
		elif event.is_action_pressed("ui_up"):
			get_tree().set_input_as_handled()
			if selected_option == 0:
				selected_option = list_size-1
			else:
				selected_option -= 1
			selected_option = selected_option % list_size
			select_arrow.rect_position.y = 100 + selected_option * 90
			refresh()
		elif  event.is_action_pressed("interaction_with_pawn"):
			selectable = false
			var child = item_change.instance()
			var text = str(item_list[selected_option].name)
			var image = item_list[selected_option].icon
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
	if(selected_option>=len(item_list)):
		selected_option = 0
		select_arrow.rect_position.y = 100 + selected_option * 90
	$Control/BigIcon/Root/Body.texture = item_list[selected_option].icon
	$Control/Description.text = "Bag:"+str(num_list[selected_option])+"\n"+item_list[selected_option].description
	$Control/BigIcon.play_walk()
	$Control/Thank.play_walk()
	
func refresh_all_items():
	var displayed_items = $Control/Items.get_children()
	for i in range(7):
		if i < list_size:
			displayed_items[i].text = item_list[i].name
			displayed_items[i].visible = true
		else:
			displayed_items[i].visible = false
			pass
	
func menu_after_change():
	initialize()
	refresh()
	refresh_all_items()
