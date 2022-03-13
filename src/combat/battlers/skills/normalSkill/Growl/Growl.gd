extends Position2D

onready var anim = $AnimationPlayer
onready var Voice = $Voice
onready var Voice2 = $Voice2
onready var Voice3 = $Voice3
onready var Voice4 = $Voice4
onready var Voice5 = $Voice5
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	Voice.visible = false
	Voice2.visible = false
	Voice3.visible = false
	Voice4.visible = false
	Voice5.visible = false
	recived_signal()
	pass # Replace with function body.

func recived_signal():
	self.visible = true
	play_voice()

func play_voice():
	anim.queue("voice")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
