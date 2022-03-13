extends Control

signal cancel()
signal switch_pokemon(pokemon,index)

enum Options { FIRST_SLOT, SECOND_SLOT, THIRD_SLOT, FOURTH_SLOT, FIFTH_SLOT, SIXTH_SLOT, CANCEL }
var selected_option: int = Options.FIRST_SLOT

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
onready var pokemon_list


func open_screen():
	selected_option = 0
	skip_disabled_option()
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
	pokemon_list = bag
	for i in range(len(bag)):
		var slot = slots[i]
		var pokemon = bag[i]
		initialize_pokemon_slot(slot, pokemon)
	if len(bag) < 6:
		initialize_pokemon_slot(slots[len(bag)], null)
	for i in range(len(bag) + 1, 6):
		var slot = slots[i]
		disable_slot(slot)

func initialize_pokemon_slot(slot, pokemon):
	slot.visible = true
	if pokemon:
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
	else:
		slot.get_node('PokemonName').text = '-'
		slot.get_node('LevelLabel').text = '-'
		slot.get_node('HealthLabel').text = '-'
		slot.get_node('MaxHealthLabel').text = '-'
		slot.get_node('PokemonPartySprite').texture = null
		
		var hp_bar = slot.get_node('HP')
		hp_bar.max_value = 1
		hp_bar.value = 0
	
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
	while not options[selected_option].visible:
		selected_option = (selected_option + step) % 7

func _ready():
	set_active_option()


func _unhandled_input(event):
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
					get_tree().set_input_as_handled()
					visible = false
					emit_signal('cancel')
				# pokemon 1-6
				0,1,2,3,4,5:
					if options[selected_option].visible:
						if selected_option < len(pokemon_list):
							emit_signal('switch_pokemon',pokemon_list[selected_option],selected_option)
						else:
							emit_signal('switch_pokemon', null, selected_option)
						get_tree().set_input_as_handled()
						visible = false
						emit_signal("cancel")
		elif event.is_action_pressed("ui_cancel"):
			get_tree().set_input_as_handled()
			visible = false
			emit_signal("cancel")
