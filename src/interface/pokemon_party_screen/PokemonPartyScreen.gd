extends Control

signal cancel()
signal switch_pokemon(index)
signal show_change_skill(index)

enum Options { FIRST_SLOT, SECOND_SLOT, THIRD_SLOT, FOURTH_SLOT, FIFTH_SLOT, SIXTH_SLOT, CANCEL }
var selected_option: int = Options.FIRST_SLOT

# trick is_alive[6] should always be true, it's cancel button
var is_alive = [true, true, true, true, true, true, true]

onready var options: Dictionary = {
	Options.FIRST_SLOT:  $Slots/PokemonSlot1,
	Options.SECOND_SLOT: $Slots/PokemonSlot2,
	Options.THIRD_SLOT:  $Slots/PokemonSlot3,
	Options.FOURTH_SLOT: $Slots/PokemonSlot4,
	Options.FIFTH_SLOT:  $Slots/PokemonSlot5,
	Options.SIXTH_SLOT:  $Slots/PokemonSlot6,
	Options.CANCEL: $CancelSprite,
}

const FULL_HP_COLOR = Color("#66c242")
const HALF_HP_COLOR = Color("#ecb63a")
const NULL_HP_COLOR = Color("#e27145")

func open_screen():
	unset_active_option()
	selected_option = 0
	skip_disabled_option()
	set_active_option()
	self.visible = true

func close_screen():
	self.visible = false

func get_hp_color(ratio):
	var color
	if ratio > 0.5:
		ratio = range_lerp(ratio, 0.5, 1.0, 0.0, 1.0)
		color = lerp(HALF_HP_COLOR, FULL_HP_COLOR, ratio)
	else:
		ratio = range_lerp(ratio, 0.0, 0.5, 0.0, 1.0)
		color = lerp(NULL_HP_COLOR, HALF_HP_COLOR, ratio)
	return color

# Array of Battler
func initialize(bag: Array):
	assert(bag.size() <= 6)
	var slots = $Slots.get_children()
	for i in range(len(bag)):
		var slot = slots[i]
		var pokemon = bag[i]
		if pokemon.get_cur_hp() > 0:
			is_alive[i] = true
		else:
			is_alive[i] = false
		initialize_pokemon_slot(slot, pokemon)
	
	for i in range(len(bag), 6):
		var slot = slots[i]
		disable_slot(slot)

func initialize_pokemon_slot(slot, pokemon):
	slot.visible = true
	slot.get_node('PokemonName').text = pokemon.get_battler_name()
	slot.get_node('LevelLabel').text = str(pokemon.get_level())
	slot.get_node('HealthLabel').text = str(pokemon.get_cur_hp())
	slot.get_node('MaxHealthLabel').text = str(pokemon.get_max_hp())
	slot.get_node('PokemonPartySprite').texture = pokemon.get_icon()
	
	var hp_bar = slot.get_node('HP')
	hp_bar.max_value = pokemon.get_max_hp()
	hp_bar.value = pokemon.get_cur_hp()
	var color = get_hp_color(hp_bar.get_as_ratio())
	hp_bar.get("custom_styles/fg").bg_color = color
	
func disable_slot(slot):
	slot.visible = false
	
func unset_active_option():
	if selected_option == Options.CANCEL:
		options[selected_option].frame = 0
	else:
		options[selected_option].get_node('Background').frame = 0
	
func set_active_option():
	if selected_option == Options.CANCEL:
		options[selected_option].frame = 1
	else:
		options[selected_option].get_node('Background').frame = 1

func skip_disabled_option(forward = true):
	var step = 1 if forward else 6
	while not options[selected_option].visible or not is_alive[selected_option]:
		selected_option = (selected_option + step) % 7

func _ready():
	set_active_option()


func on_event(event):
	if self.visible:
		if event.is_action_pressed("ui_down"):
			unset_active_option()
			selected_option = (selected_option + 1) % 7
			skip_disabled_option()
		elif event.is_action_pressed("ui_up"):
			unset_active_option()
			if selected_option == 0:
				selected_option = Options.CANCEL
			else:
				selected_option -= 1
			skip_disabled_option(false)
		elif event.is_action_pressed("ui_left"):
			unset_active_option()
			selected_option = 0
			skip_disabled_option(false)
		elif event.is_action_pressed("ui_right") and selected_option == Options.FIRST_SLOT:
			unset_active_option()
			selected_option = 1
			skip_disabled_option()
		set_active_option()
		if event.is_action_pressed("ui_accept"):
			match selected_option:
				Options.CANCEL:
					emit_signal('cancel')
				# pokemon 1-6
				1,2,3,4,5:
					if options[selected_option].visible:
						emit_signal('switch_pokemon', selected_option)
						emit_signal('show_change_skill', selected_option)
				0:
					if options[selected_option].visible:
						emit_signal('show_change_skill', selected_option)
		elif event.is_action_pressed("ui_cancel"):
			emit_signal('cancel')
