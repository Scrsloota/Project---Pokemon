extends Position2D

onready var anim = $AnimationPlayer
#onready var anim_tree = $AnimationTree
var flag = false
#var animation_state = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	recived_signal()
	pass # Replace with function body.

func recived_signal():
	self.visible = true
	play_appear()
	
func play_appear():
	anim.queue("appear")
	play_thunder()
	
func play_thunder():
	anim.queue("thunder")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
