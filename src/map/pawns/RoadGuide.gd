extends StaticBody2D
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.

export var sight_distance = 120
onready var raycasts = $Raycasts
onready var RoadGuide_text = $Control/Label
var active_raycasts := []
export var Label_message = ""


func _ready():
	RoadGuide_text.text = Label_message
	for raycast in raycasts.get_children():
		raycast.enabled = true
		raycast.cast_to = raycast.cast_to.normalized() * sight_distance
		active_raycasts.append(raycast)
	

func _physics_process(delta: float) -> void:
	var flag = false
	# Only runs if using raycasts/specific directions for player detection
	for raycast in active_raycasts:
		if raycast.is_colliding():
			$Control.show_message()
			flag = true
			break
	if not flag:
		$Control.close_message()
		
		

	
	

#func _unhandled_input(event: InputEvent) -> void:
#	if event.is_action_pressed("ui_accept"):
#		$Control.show_message()
#	print("close")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
