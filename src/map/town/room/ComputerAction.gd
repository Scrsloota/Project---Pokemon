extends MapAction
class_name ComputerAction

onready var select_arrow = $SelectArrow
onready var menu_selectable = false
onready var pokemon_list = [null,null,null,null,null,null,null,
null,null,null,null,null,null,null,
null,null,null,null,null,null,null,
null,null,null,null,null,null,null,
null,null,null,null,null,null,null]
onready var icon_List = [preload("res://assets/pokemon_mini/1.png"),
preload("res://assets/pokemon_mini/4.png"),
preload("res://assets/pokemon_mini/7.png"),
preload("res://assets/pokemon_mini/25.png"),
preload("res://assets/pokemon_mini/16.png"),
preload("res://assets/pokemon_mini/88.png")]

onready var game = get_node("/root/Game")
onready var pokemon_to_change = null
onready var to_change_index:int = 0

export (String, FILE, "*.json") var dialogue_file_path: String
signal dialogue_loaded(data)

onready var arrow_index_x = 1
onready var arrow_index_y = 1
onready var cnt = 0

func set_menu_selectable(flag:bool):
	menu_selectable = flag

func _ready():
	select_arrow.visible = false
	load_pokemon_depository()
	refresh_all()

func interact() -> void:
	print("has_interact")
	menu_selectable = true
	get_tree().set_input_as_handled()
	select_arrow.visible = true
	$Control.visible = true
	select_arrow.anim_player.play("wiggle")
	var player = get_node("/root/Game/SceneManager").get_player()
	if !player.is_moving:
		player.set_physics_process(false)
		arrow_index_x = 1
		arrow_index_y = 1
		select_arrow.rect_position.x = 30 + (arrow_index_x-1)*75
		select_arrow.rect_position.y = 190 + (arrow_index_y-1)*100
	
func get_index():
	return (arrow_index_y-1)*7 + arrow_index_x-1

func exchange_pokemon(pokemon_in_bag,index):
	pokemon_list[to_change_index] = pokemon_in_bag
	game.set_pokemons_in_depository(pokemon_to_change,index)
	refresh(pokemon_in_bag)
	
func refresh(pokemon):
	var icon = get_icon(pokemon)
	$Control/PokemonList.get_child(get_index()).set_texture(icon)
	$ExchangePokemon.initialize(game.get_pokemons_in_party())
	
func refresh_all():
	var cnt = 0
	for pokemon in pokemon_list:
		if pokemon != null:
			var icon = get_icon(pokemon)
			$Control/PokemonList.get_child(cnt).set_texture(icon)
		cnt+=1
		
func load_pokemon_depository():
	var children =  game.get_pokemons_in_depository()
	cnt = 0
	for child in children:
		pokemon_list[cnt] = child
		cnt+=1


func get_icon(pokemon):
	if pokemon:
		var name = pokemon.stats.pokemon_name
		match name:
			"Bulbasaur":
				return icon_List[0]
			"Charmander":
				return icon_List[1]
			"Squirtle":
				return icon_List[2]
			"Pikachu":
				return icon_List[3]
			"Pidgey":
				return icon_List[4]
			"Grimer":
				return icon_List[5]
	else:
		return null

func _unhandled_input(event):
	if menu_selectable:
		if  event.is_action_pressed("interaction_with_pawn"):
			get_tree().set_input_as_handled()
			$ExchangePokemon.initialize(game.get_pokemons_in_party())
			to_change_index = get_index()
			pokemon_to_change = pokemon_list[to_change_index]
			$ExchangePokemon.visible = true
			menu_selectable = false
		elif event.is_action_pressed("ui_left"):
			get_tree().set_input_as_handled()
			if arrow_index_x<=1:
				arrow_index_x = 7
			else:
				arrow_index_x-=1
			select_arrow.rect_position.x = 30 + (arrow_index_x-1)*75
		elif event.is_action_pressed("ui_right"):
			get_tree().set_input_as_handled()
			if arrow_index_x >=7:
				arrow_index_x = 1
			else:
				arrow_index_x += 1
			select_arrow.rect_position.x = 30 + (arrow_index_x-1)*75
		elif event.is_action_pressed("ui_up"):
			get_tree().set_input_as_handled()
			if arrow_index_y <=1:
				arrow_index_y = 5
			else:
				arrow_index_y -= 1
			select_arrow.rect_position.y = 190 + (arrow_index_y-1)*100
		elif event.is_action_pressed("ui_down"):
			get_tree().set_input_as_handled()
			if arrow_index_y >=5:
				arrow_index_y = 1
			else:
				arrow_index_y += 1
			select_arrow.rect_position.y = 190 + (arrow_index_y-1)*100
		elif event.is_action_pressed("ui_cancel"):
			get_tree().set_input_as_handled()
			menu_selectable = false
			$Control.visible = false
			$SelectArrow.visible = false
			var player = get_node("/root/Game/SceneManager").get_player()
			player.set_physics_process(true)
			emit_signal("finished")




func _on_ExchangePokemon_cancel():
	menu_selectable = true


func _on_ExchangePokemon_switch_pokemon(pokemon,index):
	exchange_pokemon(pokemon,index)
