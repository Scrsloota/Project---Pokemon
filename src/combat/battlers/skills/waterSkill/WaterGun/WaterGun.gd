extends Position2D

onready var anim = $AnimationPlayer
onready var watergun = $watergun
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	watergun.visible =false
	
	recived_signal()
	pass # Replace with function body.

func recived_signal():
	self.visible = true
	play_water_gun()


func play_water_gun():
	anim.queue("waterGun")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
