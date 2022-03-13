extends Position2D

onready var anim = $AnimationPlayer
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
	play_armor()

func play_armor():
	anim.queue("armor")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
