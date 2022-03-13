extends Position2D

onready var anim = $AnimationPlayer
onready var star = $star
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	star.visible =false
	recived_signal()
	pass # Replace with function body.

func recived_signal():
	self.visible = true
	play_star()

func play_star():
	star.visible = true
	anim.queue("leer")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
