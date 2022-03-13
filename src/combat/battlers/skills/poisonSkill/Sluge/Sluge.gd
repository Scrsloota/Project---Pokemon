extends Position2D

onready var anim = $AnimationPlayer
onready var muds = $muds
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	muds.visible =false
	recived_signal()
	pass # Replace with function body.

func recived_signal():
	self.visible = true
	play_throw()
	
func play_throw():
	anim.queue("throw")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
