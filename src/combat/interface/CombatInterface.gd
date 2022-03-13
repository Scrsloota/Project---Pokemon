extends CanvasLayer

signal action_selected(action)

# state of pokemon
var self_pokemon: Battler
var oppo_pokemon: Battler
var active_pokemon: Battler
var pokemon_bag: Array
var bag: Dictionary

# anim
# =================================
var self_hp_bar_anim: bool = false
var self_hp_target_value: int
var oppo_hp_bar_anim: bool = false
var oppo_hp_target_value: int
var self_anim_time_delta: float
var oppo_anim_time_delta: float
# =================================
const ENTRANCE_MSG_TEMPLATE = 'What does %s want to do?'
# not the actual time
const anim_time = 16

const FULL_HP_COLOR = Color("#66c242")
const HALF_HP_COLOR = Color("#ecb63a")
const NULL_HP_COLOR = Color("#e27145")
# Null, Burn, Freeze, Paralysis, Poison, Sleep
const map_nv_stat_to_frame = [null, 0, 1, 3, 2, 4]
var normal_mode = true

func initialize(oppo_pokemon: Battler, self_pokemon: Battler, pokemon_bag: Array = [], bag: Dictionary = {}):
	self.self_pokemon = self_pokemon
	self.oppo_pokemon = oppo_pokemon
	self.pokemon_bag = pokemon_bag
	self.bag = bag
	$Menu/PokemonPartyScreen.initialize(pokemon_bag)
	$Menu/Bag.initialize(bag)
	
	update_self_name(self_pokemon.get_battler_name())
	update_oppo_name(oppo_pokemon.get_battler_name())
	
	$SelfBar/MaxHp.text = str(self_pokemon.get_max_hp())
	$SelfBar/HP.max_value = self_pokemon.get_max_hp()
	$SelfBar/HP.set_value(self_pokemon.get_cur_hp())
	$SelfBar/Level.text = str(self_pokemon.get_level())
	
	$OppoBar/HP.max_value = oppo_pokemon.get_max_hp()
	$OppoBar/HP.set_value(oppo_pokemon.get_cur_hp())
	$OppoBar/Level.text = str(oppo_pokemon.get_level())
	
	update_status()

func open_actions_menu(active_pokemon: Battler, normal_mode = true):
	self.active_pokemon = active_pokemon
	$Menu.normal_mode = normal_mode
	
	if normal_mode:
		$Menu.initialize(active_pokemon.get_portable_skills(), ENTRANCE_MSG_TEMPLATE % active_pokemon.get_battler_name())
		$Menu.open_entrance()
	else:
		var flag = false
		for pokemon in pokemon_bag:
			if pokemon.get_cur_hp() > 0:
				flag = true
				break
		if flag:
			$Menu.open_pokemon_bag()
		else:
			var action = SurrenderAction.new()
			emit_signal("action_selected", action)

func update_status():
	update_self_nv_status(map_nv_stat_to_frame[self_pokemon.get_nv_status()])
	update_oppo_nv_status(map_nv_stat_to_frame[oppo_pokemon.get_nv_status()])
	update_self_hp(self_pokemon.get_cur_hp())
	update_oppo_hp(oppo_pokemon.get_cur_hp())
	$Menu/PokemonPartyScreen.initialize(pokemon_bag)
	$Menu/Bag.initialize(bag)
	$Menu/Bag.reset()

func open_dialog():
	pass
	
func open_item_menu():
	pass
	
func show_message(msg):
	$Menu.show_dialog(msg)
	yield($Menu, "dialog_finished")
	$Menu.close_all()

func update_self_hp(cur_hp):
	self_hp_bar_anim = true
	self_hp_target_value = cur_hp
	self_anim_time_delta = 0
	
func update_self_name(name):
	$SelfBar/Name.set_text(name)

func update_self_nv_status(nv_stat):
	if nv_stat != null:
		$SelfBar/state.set_visible(true)
		$SelfBar/state.set_frame(nv_stat)
	else:
		$SelfBar/state.set_visible(false)
	
func update_oppo_nv_status(nv_stat):
	if nv_stat != null:
		$OppoBar/state.set_visible(true)
		$OppoBar/state.set_frame(nv_stat)
	else:
		$OppoBar/state.set_visible(false)

func update_oppo_hp(cur_hp):
	oppo_hp_bar_anim = true
	oppo_hp_target_value = cur_hp
	oppo_anim_time_delta = 0

func update_oppo_name(name):
	$OppoBar/Name.set_text(name)

func get_hp_color(ratio):
	var color
	if ratio > 0.5:
		ratio = range_lerp(ratio, 0.5, 1.0, 0.0, 1.0)
		color = lerp(HALF_HP_COLOR, FULL_HP_COLOR, ratio)
	else:
		ratio = range_lerp(ratio, 0.0, 0.5, 0.0, 1.0)
		color = lerp(NULL_HP_COLOR, HALF_HP_COLOR, ratio)
	return color
	
# helper function
func is_close(value: float, target: float):
	return abs(target - value) < 0.1

# HP damage animation
func _process(delta):
	if self_hp_bar_anim:
		self_anim_time_delta += delta
		var cur_hp
		if self_anim_time_delta >= anim_time || is_close($SelfBar/HP.value, self_hp_target_value):
			# stop anim
			cur_hp = self_hp_target_value
			self_hp_bar_anim = false
		else:
			cur_hp = range_lerp(self_anim_time_delta, 0.0, anim_time, $SelfBar/HP.value, self_hp_target_value)
		$SelfBar/HP.set_value(cur_hp)
		$SelfBar/CurHp.set_text(str(int(cur_hp)))
		var ratio = $SelfBar/HP.get_as_ratio()
		var color = get_hp_color(ratio)
		$SelfBar/HP.get("custom_styles/fg").bg_color = color
	
	if oppo_hp_bar_anim:
		oppo_anim_time_delta += delta
		var cur_hp
		if oppo_anim_time_delta >= anim_time || is_close($OppoBar/HP.value, oppo_hp_target_value):
			# stop anim
			cur_hp = oppo_hp_target_value
			oppo_hp_bar_anim = false
		else:
			cur_hp = range_lerp(oppo_anim_time_delta, 0.0, anim_time, $OppoBar/HP.value, oppo_hp_target_value)
		$OppoBar/HP.set_value(cur_hp)
		var ratio = $OppoBar/HP.get_as_ratio()
		var color = get_hp_color(ratio)
		$OppoBar/HP.get("custom_styles/fg").bg_color = color

# ============= signals ==============

func _on_Menu_skill_selected(skill):
	var action = SkillAction.new(skill)
	emit_signal('action_selected', action)


func _on_Menu_switch_pokemon_selected(index):
	var action = ChangeAction.new(pokemon_bag[index])
	emit_signal('action_selected', action)


func _on_Menu_run_selected():
	var action = RunAction.new()
	emit_signal('action_selected', action)

func _on_Menu_item_selected(item):
	var action = ItemAction.new(item)
	emit_signal('action_selected', action)
