extends Control

signal change_bgm_preset(index)
signal exit()

onready var Arrow = $Background/Arrow
onready var options = $Background/VBoxContainer.get_children()
onready var num_options = len(options)
const offset = 89
var selected_option = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	reset()
	
func reset():
	selected_option = 0
	Arrow.rect_position.y = options[selected_option].rect_position.y + offset

func on_event(event):
	if event.is_action_pressed("ui_down"):
		selected_option = (selected_option + 1) % num_options
		Arrow.rect_position.y = options[selected_option].rect_position.y + offset
	elif event.is_action_pressed("ui_up"):
		selected_option = (selected_option + num_options - 1) % num_options
		Arrow.rect_position.y = options[selected_option].rect_position.y + offset
	elif event.is_action_pressed("ui_accept"):
		emit_signal("change_bgm_preset", selected_option)
		emit_signal('exit')
	elif event.is_action_pressed("ui_cancel"):
		emit_signal('exit')
