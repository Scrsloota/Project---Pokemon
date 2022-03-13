extends Control

signal item_selected(item)
signal cancel()

const OFFSET = 3
const anim_time = 0.015

var items = []
var num = []
var page = 0
var selected_option = 0

func _ready():
	pass # Replace with function body.

# pass in array of items
func initialize(item2num: Dictionary):
	items = []
	num = []
	for key in item2num:
		items.append(key)
		num.append(item2num[key])
	page = 0
	
func reset():
	selected_option = 0
	page = 0
	update_page()
	update_selection()
	
func get_selected_idx():
	var idx = page * 6 + selected_option
	return idx
	
func update_selection():
	if len(items) > 0:
		$Arrow.visible = true
		var selected_item = $Items.get_children()[selected_option]
		$Arrow.rect_position.y = selected_item.rect_position.y + OFFSET
		update_description()
	else:
		$Arrow.visible = false

func update_description():
	var idx = get_selected_idx()
	$Description.text = items[idx].description
	$Description.visible_characters = 0
	$BigIcon.texture = items[idx].icon
	$Timer.start(anim_time)

func update_page():
	var displayed_items = $Items.get_children()
	for i in range(6):
		var idx = page * 6 + i
		if idx < len(items):
			displayed_items[i].get_node('Name').text = items[idx].name
			displayed_items[i].get_node('Icon').texture = items[idx].icon
			displayed_items[i].get_node("Num").text = 'x'+str(num[i])
			displayed_items[i].visible = true
		else:
			displayed_items[i].visible = false
			pass

func page_up():
	if (page + 1)* 6 < len(items):
		page += 1
		selected_option = 0
		update_selection()
		update_page()
	
func page_down():
	if page > 0:
		page -= 1
		selected_option = 0
		update_selection()
		update_page()
		
func next_option():
	if len(items) > 0:
		var displayed_items = $Items.get_children()
		selected_option = (selected_option + 1) % 6
		while not displayed_items[selected_option].visible:
			selected_option = (selected_option + 1) % 6
			
		update_selection()
	
func prev_option():
	if len(items) > 0:
		var displayed_items = $Items.get_children()
		selected_option = (selected_option + 6 - 1) % 6
		while not displayed_items[selected_option].visible:
			selected_option = (selected_option + 6 - 1) % 6
			
		update_selection()

func on_event(event):
	if self.visible:
		if event.is_action_pressed("ui_down"):
			next_option()
		elif event.is_action_pressed("ui_up"):
			prev_option()
		elif event.is_action_pressed("ui_left"):
			page_up()
		elif event.is_action_pressed("ui_right"):
			page_down()
		elif event.is_action_pressed("ui_accept"):
			if len(items) > 0:
				emit_signal("item_selected", items[get_selected_idx()])
		elif event.is_action_pressed('ui_cancel'):
			emit_signal('cancel')

# anim here
func _on_Timer_timeout():
	if $Description.visible_characters < len($Description.text):
		$Description.visible_characters += 1
		$Timer.start(anim_time)
