extends Position2D

onready var anim = $AnimationPlayer
onready var fires = $fires
onready var throwns = $throwns
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	throwns.visible =false
	fires.visible = false
	recived_signal()
	pass # Replace with function body.

func recived_signal():
	self.visible = true
	play_throwns()

func play_throwns():
	anim.queue("thrown")
	play_fires()

func play_fires():
	for i in range(4):
		anim.queue("fired")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
