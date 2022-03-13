extends Position2D

onready var anim = $AnimationPlayer
onready var vine = $Vine

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	vine.visible = false
	recived_signal()
	pass # Replace with function body.

func recived_signal():
	self.visible = true
	play_vine()

func play_vine():
	vine.visible = true
	anim.queue("Vine")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
