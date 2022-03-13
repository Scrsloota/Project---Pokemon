extends Position2D

onready var anim = $AnimationPlayer
onready var first = $first
onready var blood = $blood
# Declare member variables here. Examples:
# var a = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	first.visible = false
	blood.visible =false
	recived_signal()
	pass # Replace with function body.

func recived_signal():
	self.visible = true
	play_first()

func play_first():
	first.visible = true
	anim.queue("protect")
	play_blood()
	
	
func play_blood():
	anim.queue("attack_effect")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
