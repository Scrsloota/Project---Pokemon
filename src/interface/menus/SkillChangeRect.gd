extends NinePatchRect

onready var select_arrow = $Arrow
onready var labels = $VBoxContainer.get_children()
var num_options = 4
const arrow_offset = 38
var selected_option: int = 0

var selected = false

var can_learn_skills = []
var learned_skills = []
var cur_page = 0
var tot_page_num = 0

var changed_skill_index = 0

signal exit_change_skill_menu

func initialize(battler):
	learned_skills = battler.stats.get_learned_skills()
	can_learn_skills =  battler.stats.get_can_learn_skills()
	reset_interface(4)
	for i in range(len(learned_skills)):
		labels[i].text = learned_skills[i].skill.name
		for j in range(len(can_learn_skills)):
			if learned_skills[i].skill.name == can_learn_skills[j].name:
				can_learn_skills.remove(j)
				break

func exit_learned_menu():
	emit_signal("exit_change_skill_menu")
	
func exit_can_learn_menu():
	selected = false
	for i in range(len(learned_skills)):
		labels[i].text = learned_skills[i].skill.name

	
func handle_learned_select():
	selected = true
	tot_page_num = (len(can_learn_skills) - 1) / 4 + 1
	cur_page = 0
	changed_skill_index = selected_option
	selected_option = 0
	reset_arrow()
	refresh_page()
	
func handle_can_learn_select():
	var new_skill = PortableSkill.new()
	new_skill.skill = can_learn_skills[get_index()]
	can_learn_skills[get_index()] = learned_skills[changed_skill_index].skill
	new_skill.reset()
	learned_skills[changed_skill_index] = new_skill
	exit_can_learn_menu()
	
func get_index():
	return (cur_page) * 4 + selected_option
	
func refresh_page():
	var num = 4
	if cur_page + 1 == tot_page_num:
		num = len(can_learn_skills)-(tot_page_num-1) * 4
	reset_interface(num)
	for i in range(num):
		var index = (cur_page) * 4 + i
		labels[i].text = can_learn_skills[index].name
	
	
func reset_interface(num):
	for i in range(4):
		labels[i].text = "--"
	num_options = num	
	
func reset_arrow():
	select_arrow.rect_position.y = $VBoxContainer.get_children()[selected_option].rect_position.y + arrow_offset

func on_event(event):
	if !selected:
		if event.is_action_pressed("menu_calling") or event.is_action_pressed("ui_cancel"):
			exit_learned_menu()
		elif event.is_action_pressed("ui_down"):
			selected_option = (selected_option + 1) % num_options
			reset_arrow()
		elif event.is_action_pressed("ui_up"):
			selected_option = (selected_option + num_options - 1) % num_options
			reset_arrow()
		elif event.is_action_pressed("ui_accept"):
			handle_learned_select()
	else:
		if event.is_action_pressed("menu_calling") or event.is_action_pressed("ui_cancel"):
			exit_can_learn_menu()
		elif event.is_action_pressed("ui_down"):
			selected_option = (selected_option + 1) % num_options
			reset_arrow()
		elif event.is_action_pressed("ui_up"):
			selected_option = (selected_option + num_options - 1) % num_options
			reset_arrow()
		elif event.is_action_pressed("ui_right"):
			cur_page = (cur_page + 1) % tot_page_num
			refresh_page()
		elif event.is_action_pressed("ui_left"):
			cur_page = (cur_page + tot_page_num - 1) % tot_page_num
			refresh_page()
		elif event.is_action_pressed("ui_accept"):
			handle_can_learn_select()


