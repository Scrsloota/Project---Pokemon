extends CanvasLayer

onready var select_arrow = $SkillBox/Box/Arrow
onready var entrance_select_arrow = $Entrance/Box/Arrow
enum ScreenLoaded { 
	SKILL,
	DIALOG,
	ENTRANCE,
	POKEMON_BAG,
	ITEM_LIST,
	BAG,
	NONE
}
var screen_loaded = ScreenLoaded.SKILL
#enum ScreenLoaded { NOTHING, JUST_MENU, PARTY_SCREEN, }
#var screen_loaded = ScreenLoaded.NOTHING
signal skill_selected(skill)
signal dialog_finished()
signal run_selected()
signal switch_pokemon_selected(index)
signal item_selected(item)

const time_each_char_in_anim: float = 0.015

var AVAILABLE_COLOR = Color(0.2, 0.2, 0.2, 1.0)
var UNAVAILABLE_COLOR = Color(0.3, 0.3, 0.3, 0.5)

var selected_option: int = 0
var messages: Array = []
var cur_msg_idx: int = 0
var skills: Array = []
var EMPTY_SKILL = PortableSkill.new()
var entrance_msg: String
var normal_mode: bool = true

func _ready():
	close_all()
	
	select_arrow.rect_position.x = 100
	select_arrow.rect_position.y = 60
	self.skills = [EMPTY_SKILL, EMPTY_SKILL, EMPTY_SKILL, EMPTY_SKILL]
	
func initialize(skills, entrance_msg: String):
	self.entrance_msg = entrance_msg
	self.skills = skills.duplicate()
	selected_option = 0
	while len(self.skills) < 4:
		self.skills.append(EMPTY_SKILL)
	for i in range(4):
		update_skill(self.skills[i], i)
	update_max_pp(skills[0].get_max_pp())
	update_cur_pp(skills[0].get_cur_pp())
	select_arrow.rect_position.x = 100
	select_arrow.rect_position.y = 60
	$SkillBox/Box/Type.set_text(skills[0].get_typename())


func update_skill(skill, index):
	var node_name = 'SkillBox/Box/Skill%d' % (index+1)
	var skill_node = get_node(node_name)
	skill_node.set_text(skill.get_skill_name())
	if skill.get_cur_pp() == 0:
		skill_node.add_color_override("font_color", UNAVAILABLE_COLOR)
	else:
		skill_node.add_color_override("font_color", AVAILABLE_COLOR)
	
func update_cur_pp(cur_pp):
	$SkillBox/Box/PPcur.set_text(str(cur_pp))
	if cur_pp==0:
		$SkillBox/Box/PPcur.add_color_override("font_color", UNAVAILABLE_COLOR)
	else:
		$SkillBox/Box/PPcur.add_color_override("font_color", AVAILABLE_COLOR)

func update_max_pp(max_pp):
	$SkillBox/Box/PPmax.set_text(str(max_pp))
	$SkillBox/Box/PPmax.add_color_override("font_color", AVAILABLE_COLOR)

func open_entrance():
	$Bag.visible = false
	$SkillBox.visible = false
	$DialogBox.visible = false
	$Entrance.visible = true
	$PokemonPartyScreen.visible = false
	selected_option = 0
	$Entrance/Hint/Label.text = entrance_msg
	$Entrance/Hint/Label.visible_characters = 0
	update_entrance_selection()
	screen_loaded = ScreenLoaded.ENTRANCE
	$Timer.start(time_each_char_in_anim)

func open_skill_box():
	$Bag.visible = false
	$SkillBox.visible = true
	$DialogBox.visible = false
	$Entrance.visible = false
	$PokemonPartyScreen.visible = false
	selected_option = 0
	update_skill_selection()
	screen_loaded = ScreenLoaded.SKILL

func open_dialog_box():
	$Bag.visible = false
	$SkillBox.visible = false
	$DialogBox.visible = true
	$Entrance.visible = false
	$PokemonPartyScreen.visible = false
	screen_loaded = ScreenLoaded.DIALOG
	
func open_bag():
	$Bag.visible = true
	$SkillBox.visible = false
	$DialogBox.visible = false
	$Entrance.visible = false
	$PokemonPartyScreen.visible = false
	$Bag.reset()
	screen_loaded = ScreenLoaded.BAG

func open_pokemon_bag():
	$Bag.visible = false
	$SkillBox.visible = false
	$DialogBox.visible = false
	$Entrance.visible = false
	$PokemonPartyScreen.visible = true
	$PokemonPartyScreen.open_screen()
	screen_loaded = ScreenLoaded.POKEMON_BAG
	
func play_message_anim(msg):
	$DialogBox/Box/Message.visible_characters = 0
	$DialogBox/Box/Message.set_text(msg)
	$Timer.start(time_each_char_in_anim)

# Array of String
func show_dialog(msg: Array):
	open_dialog_box()
	messages = msg
	cur_msg_idx = 0
	assert(len(messages) > 0)
	play_message_anim(msg[0])

func close_all():
	$SkillBox.visible = false
	$DialogBox.visible = true
	$Entrance.visible = false
	$PokemonPartyScreen.visible = false
	$DialogBox/Box/Message.set_text("")
	screen_loaded = ScreenLoaded.NONE
	
func get_skill_name(index):
	assert (index >= 0)
	assert (index < 4)
	var node_name = 'Menu/box/Skill%d' % (index+1)
	return get_node(node_name).get_text()
	
func update_skill_selection():
	if selected_option < 2:
		select_arrow.rect_position.y = 60
	else: 
		select_arrow.rect_position.y = 180
		
	if selected_option % 2 == 0:
		select_arrow.rect_position.x = 100
	else:
		select_arrow.rect_position.x = 735
		
	update_max_pp(skills[selected_option].get_max_pp())
	update_cur_pp(skills[selected_option].get_cur_pp())
	$SkillBox/Box/Type.set_text(skills[selected_option].get_typename())

func update_entrance_selection():
	if selected_option < 2:
		entrance_select_arrow.rect_position.y = 60
	else: 
		entrance_select_arrow.rect_position.y = 165
		
	if selected_option % 2 == 0:
		entrance_select_arrow.rect_position.x = 30
	else:
		entrance_select_arrow.rect_position.x = 380
			
func update_option_value(event, option):
	if event.is_action_pressed("ui_down") or event.is_action_pressed("ui_focus_next"):
		option = (option + 2) % 4
	elif event.is_action_pressed("ui_up") or event.is_action_pressed("ui_focus_prev"):
		option = (option + 4 - 2) % 4
	elif event.is_action_pressed("ui_left"):
		option = (option + 4 - 1) % 4
	elif event.is_action_pressed("ui_right"):
		option = (option + 1) % 4
	return option
	
func handle_entrance_action():
	assert(screen_loaded == ScreenLoaded.ENTRANCE)
	match selected_option:
		0:
			# Fight
			open_skill_box()
		1:
			# Bag
			open_bag()
		2:
			# Pokemon
			open_pokemon_bag()
		3:
			# Run
			emit_signal('run_selected')

func _unhandled_input(event):
	match screen_loaded:
		ScreenLoaded.SKILL:
			selected_option = update_option_value(event, selected_option)
			update_skill_selection()
			if event.is_action_pressed("ui_cancel"):
				open_entrance()
			elif event.is_action_pressed("ui_accept") and skills[selected_option].get_cur_pp() > 0:
				emit_signal('skill_selected', self.skills[selected_option])
		ScreenLoaded.DIALOG:
			if event.is_action_pressed("ui_accept"):
				cur_msg_idx += 1
				if cur_msg_idx < len(messages):
					play_message_anim(messages[cur_msg_idx])
				else:
					emit_signal("dialog_finished")
		ScreenLoaded.ENTRANCE:
			selected_option = update_option_value(event, selected_option)
			update_entrance_selection()
			if event.is_action_pressed("ui_accept"):
				handle_entrance_action()
		ScreenLoaded.POKEMON_BAG:
			$PokemonPartyScreen.on_event(event)
		ScreenLoaded.BAG:
			$Bag.on_event(event)
		ScreenLoaded.ITEM_LIST:
			pass
			
# handle signals
func _on_Timer_timeout():
	match screen_loaded:
		ScreenLoaded.DIALOG:
			if $DialogBox/Box/Message.visible_characters < len($DialogBox/Box/Message.text):
				$DialogBox/Box/Message.visible_characters += 1
				$Timer.start(time_each_char_in_anim)
		ScreenLoaded.ENTRANCE:
			if $Entrance/Hint/Label.visible_characters < len($Entrance/Hint/Label.text):
				$Entrance/Hint/Label.visible_characters += 1
				$Timer.start(time_each_char_in_anim)


func _on_PokemonPartyScreen_cancel():
	if normal_mode:
		open_entrance()
	else:
		# must choose a pokemon
		pass


func _on_PokemonPartyScreen_switch_pokemon(index):
	emit_signal('switch_pokemon_selected', index)


func _on_Bag_cancel():
	open_entrance()


func _on_Bag_item_selected(item):
	emit_signal('item_selected', item)
