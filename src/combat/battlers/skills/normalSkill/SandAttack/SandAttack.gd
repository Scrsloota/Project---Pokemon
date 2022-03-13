extends Position2D

onready var anim = $AnimationPlayer
onready var sand = $sand
onready var throwns = $throwns
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	throwns.visible =false
	sand.visible = false
	recived_signal()
	pass # Replace with function body.

func recived_signal():
	self.visible = true
	play_throwns()

func play_throwns():
	throwns.visible = true
	anim.queue("thrown")
	play_sand()

func play_sand():
	anim.queue("sand")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
