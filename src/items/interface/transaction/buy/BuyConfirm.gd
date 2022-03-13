extends CanvasLayer
onready var select_arrow = $Control/SelectArrow
onready var control = $Control
onready var Bag = $Control/BagLabel
onready var Cash = $Control/CashLabel
onready var Price = $Control/CountLabel
onready var parent_menu = get_parent().get_parent()
enum ScreenLoaded { Yes,No }
onready var screen_loaded = ScreenLoaded.Yes
onready var inventory =  get_node("/root/Game").get_inventory()
onready var selected_option: int = 0
var item 
onready var amount:int = 0
onready var question = $Control/Remind
onready var icon = $Control/BigIcon
onready var yes_player = $Control/Yes/AnimationPlayer
onready var no_player = $Control/No/AnimationPlayer
onready var cash_number = 0
signal buy_items

func _ready():
	Bag.text = "Bag:" + str(inventory.get_number(item)) 
	cash_number = inventory.get_coins()
	Cash.text = "Cash:" + str(cash_number)
	select_arrow.anim_player.play("wiggle")
	get_parent().control.visible = false
	connect("buy_items",parent_menu.get_child(2),"menu_after_change")


func _unhandled_input(event):
	if event.is_action_pressed("ui_left"):
		get_tree().set_input_as_handled()
		screen_loaded = ScreenLoaded.Yes
		select_arrow.rect_position.x = 250
	elif event.is_action_pressed("ui_right"):
		get_tree().set_input_as_handled()
		screen_loaded = ScreenLoaded.No
		select_arrow.rect_position.x = 750
	elif event.is_action_pressed("ui_up"):
		get_tree().set_input_as_handled()
		
		if (cash_number>=(amount+1)*item.buy_price):
			amount+=1
			refresh()
			icon.play_walk()
	elif event.is_action_pressed("ui_down"):
		get_tree().set_input_as_handled()
		if(amount>0):
			amount-=1
			refresh()
			icon.play_walk()
	elif event.is_action_pressed("ui_cancel"):
		get_tree().set_input_as_handled()
		get_parent().selectable = true
		get_parent().control.visible = true
		queue_free()
		
	match screen_loaded:
		ScreenLoaded.Yes:
			if  event.is_action_pressed("interaction_with_pawn"):
				get_tree().set_input_as_handled()
				yes_player.play("click")
				yield(yes_player,"animation_finished")
				inventory.add(item,amount)
				inventory.remove_coins(amount*item.buy_price)
				emit_signal("buy_items")
				get_parent().selectable = true
				get_parent().control.visible = true
				queue_free()
		ScreenLoaded.No:
			if  event.is_action_pressed("interaction_with_pawn"):
				get_tree().set_input_as_handled()
				no_player.play("click")
				yield(no_player,"animation_finished")
				get_parent().selectable = true
				get_parent().control.visible = true
				queue_free()
func refresh():
	Price.text = "x"+ str(amount)+"   "+str(amount*item.buy_price) + "$" 

	
func initialize(text,image):
	item = load("res://src/items/meds/"+str(text)+".tres")
	if (item==null):
		item = load("res://src/items/pokemonBall/"+str(text)+".tres")
	$Control/Remind.text = "Do you want to buy "+str(text)+"?"
	$Control/BigIcon/Root/Body.texture = image
