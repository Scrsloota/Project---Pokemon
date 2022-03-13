extends Position2D

onready var anim = $AnimationPlayer
onready var bubble = $bubble
onready var throwns = $throwns
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	throwns.visible =false
	bubble.visible = false
	recived_signal()
	pass # Replace with function body.

func recived_signal():
	self.visible = true
	play_throwns()

func play_throwns():
	throwns.visible = true
	anim.queue("thrown")
	play_bubbles()

func play_bubbles():
	anim.queue("bubble")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
