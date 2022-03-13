extends Position2D

onready var anim = $AnimationPlayer
onready var wind = $wind
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	
	self.visible = false
	wind.visible = false
	recived_signal()
#	pass # Replace with function body.
#
func recived_signal():
	self.visible = true
	play_gust()
#
func play_gust():
	wind.visible = true
	anim.queue("gust")
#	print("yes")
#	anim.play("gust")
## Called every frame. 'delta' is the elapsed time since the previous frame.
##func _process(delta):
##	pass
