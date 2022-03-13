extends Position2D

onready var anim = $AnimationPlayer
onready var ball = $Ball
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	ball.visible = false
	recived_signal()
	pass # Replace with function body.

func recived_signal():
	self.visible = true
	play_double()

func play_double():
	ball.visible = true
	anim.queue("double")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
