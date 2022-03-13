extends CanvasLayer
onready var selectable:bool = false
onready var select_option = 0
onready var main_menu = get_parent().get_parent()
onready var list_state = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
func sub_play_hide():
	$FurtherDetailedInfo/AnimationPlayer.play("Hide")
func sub_play_show():
	$FurtherDetailedInfo/AnimationPlayer.play("Show")
func activate():
	selectable = true
	set_visible(true)
	$Control/SelectArrow.anim_player.play("wiggle")
func sleep():
	
	selectable = false
	$Control/SelectArrow.anim_player.stop()
	if(list_state==0):
		$AnimationPlayer.play("Hide")
	else:
		$AnimationPlayer.play("HideAll")
	
func refresh(height,weight,feature,category,description,attribute_image,attribute_image2,icon):
	$Control/AttributeList/Height.text = "    Height:            " + str(height)
	$Control/AttributeList/Weight.text = "    Weight:            " + str(weight)
	$Control/AttributeList/Feature.text = "   Feature:         " + str(feature)
	$Control/AttributeList/Category.text = "   Category:         " + str(category)
	$Control/AttributeImage.texture = attribute_image
	$Control/AttributeImage2.texture = attribute_image2
	$FurtherDetailedInfo/Control/AttributeList/Description/Label.text = str(description)
	$FurtherDetailedInfo/Control/Profile.texture = icon
	
func set_visible(flag:bool):
	$Control/Attribute.visible = flag
	$Control/AttributeImage.visible = flag
	$Control/BackGround.visible = flag
	$Control/AttributeList.visible = flag
	$Control/AttributeImage2.visible = flag
	$Control/ShowButton.visible = flag
	$Control/HideButton.visible = flag
	$Control/Show.visible = flag
	$Control/Hide.visible = flag
	$FurtherDetailedInfo/Control/BackGround.visible = flag
	$FurtherDetailedInfo/Control/AttributeList/Description/Label.visible = flag
	$FurtherDetailedInfo/Control/Profile.visible = flag
	$Control/SelectArrow.visible = flag

func _unhandled_input(event):
	if selectable:
		if event.is_action_pressed("ui_left"):
			select_option -=1
			select_option = select_option%2
			$Control/SelectArrow.rect_position.x = 90 + select_option*310
		elif event.is_action_pressed("ui_right"):
			select_option +=1
			select_option = select_option%2
			$Control/SelectArrow.rect_position.x = 90 + select_option*310
		elif event.is_action_pressed("interaction_with_pawn"):
			if(select_option==0):
				$FurtherDetailedInfo/AnimationPlayer.play("Show")
				list_state = 1
			elif (select_option==1):
				$FurtherDetailedInfo/AnimationPlayer.play("Hide")
				list_state = 0
		elif event.is_action_pressed("ui_cancel"):
			sleep()
			yield($AnimationPlayer,"animation_finished")
			set_visible(false)
			main_menu.activate()
			
