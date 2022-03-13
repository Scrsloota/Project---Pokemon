extends Position2D

onready var anim = $AnimationPlayer
onready var pump = $pumps
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	pump.visible =false
	
	recived_signal()
	pass # Replace with function body.

func recived_signal():
	self.visible = true
	play_pumps()


func play_pumps():
	pump.visible = true
	for i in range(2):
		anim.queue("pumps")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
