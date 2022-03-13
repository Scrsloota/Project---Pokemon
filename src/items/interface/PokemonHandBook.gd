extends CanvasLayer
onready var selectable:bool = false
onready var select_arrow = $SelectArrow
onready var anim_player = $Control/PokemonDetailedInfo/AnimationPlayer
onready var sub_menu = $Control/PokemonDetailedInfo
onready var images = $AttributeImages
onready var name_list = ["Bulbasaur","Charmander","Squirtle","Pikachu","pidgey","Grimer"]
onready var icon_list = [$Control/ProfileList/Icon.texture,$Control/ProfileList/Icon2.texture,$Control/ProfileList/Icon3.texture,
$Control/ProfileList/Icon4.texture,$Control/ProfileList/Icon5.texture,$Control/ProfileList/Icon6.texture]
onready var attribute_list = [images.grass,images.fire,images.water,images.electric,images.flying,images.poison]
onready var sub_attribute_list = [images.poison,null,null,null,images.normal,null]
onready var height_list = ["0.7m","0.6m","0.5m","0.4m","0.3m","0.9m"]
onready var weight_list = ["6.9kg","8.5kg","9.0kg","6.0kg","1.8kg","30.0kg"]
onready var feature_list = ["Florish","Flame","Stream","Static","SharpEyes","Smelly"]
onready var category_list = ["Seed","Lizard","Turtle","Mouse","Bird","Mud"]
onready var description_list = ["You can see it sleeping under the sun at noon. After bathing under enough sun light, the seed on its back will strongly grow.",
"The flame on its tail represents its mood. When it is happy, the flame will wiggle. When angry, the flame will burn drastically.",
"Its test can not only protect itself but also can make itself swim faster with its round shape to reduce fraction.",
"It can store electricity into the bags on its cheek. When releasing the electricity, it can even induce thunder.",
"It can return its home wherever they go thanks to its great sense of direction.",
"Born from the corrupted mud under the sea, it loves dirty stuff."
]
onready var list_state:int = 0


var selected_option: int = 1

func _ready():
	pass # Replace with function body.
	select_arrow.anim_player.play("wiggle")
	sub_menu.set_visible(false)
	$Control.visible = false
	$SelectArrow.visible = false

	
func sleep():
	selectable = false
	select_arrow.anim_player.stop()

func activate():
	selectable = true
	select_arrow.anim_player.play("wiggle")
	$Control.visible = true
	$SelectArrow.visible = true

func _unhandled_input(event):
	if event.is_action_pressed("handbook"):
		activate()
		var player = get_node("/root/Game/SceneManager").get_player()
		player.set_physics_process(false)
	if selectable:
		if event.is_action_pressed("ui_down"):
			get_tree().set_input_as_handled()
			selected_option += 3
			if(selected_option!=6):
				selected_option  = selected_option % 6
			
			if selected_option<=3:
				select_arrow.rect_position.y = 320
			else:
				select_arrow.rect_position.y = 580
			refresh()
		elif event.is_action_pressed("ui_up"):
			get_tree().set_input_as_handled()
			selected_option -= 3
			if(selected_option<0):
				selected_option = selected_option % 6 + 6
			if(selected_option==0):
				selected_option = 6
			
			if selected_option<=3:
				select_arrow.rect_position.y = 320
			else:
				select_arrow.rect_position.y = 580
			refresh()
		elif event.is_action_pressed("ui_left"):
			get_tree().set_input_as_handled()
			if selected_option==4:
				selected_option = 6
			elif selected_option==1:
				selected_option = 3
			else:
				selected_option-=1
			
			if(selected_option<=3):
				select_arrow.rect_position.x = 45 + (selected_option-1) * 230
			else:
				select_arrow.rect_position.x = 45 + (selected_option-4) * 230
			refresh()
		elif event.is_action_pressed("ui_right"):
			get_tree().set_input_as_handled()
			if selected_option==6:
				selected_option = 4
			elif selected_option==3:
				selected_option = 1
			else:
				selected_option+=1
			
			if(selected_option<=3):
				select_arrow.rect_position.x = 45 + (selected_option-1) * 230
			else:
				select_arrow.rect_position.x = 45 + (selected_option-4) * 230
			refresh()
		if  event.is_action_pressed("interaction_with_pawn"):
			sleep()
			refresh()
			sub_menu.activate()
			list_state = 2
			anim_player.play("ShowAll")
			yield(anim_player,"animation_finished")
		if event.is_action_pressed("ui_cancel"):
			get_tree().set_input_as_handled()
			var player = get_node("/root/Game/SceneManager").get_player()
			player.set_physics_process(true)
			sleep()
			$Control.visible = false
			$SelectArrow.visible = false

func refresh():
	var height = height_list[selected_option-1]
	var weight = weight_list[selected_option-1]
	var category = category_list[selected_option-1]
	var feature = feature_list[selected_option-1]
	var description = description_list[selected_option-1]
	var attribute_image = attribute_list[selected_option-1]
	var attribute_image2 = sub_attribute_list[selected_option-1]
	var icon = icon_list[selected_option-1]
	sub_menu.refresh(height,weight,category,feature,description,attribute_image,attribute_image2,icon)
	
	
	
