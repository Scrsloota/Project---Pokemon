extends Position2D

onready var anim = $AnimationPlayer
onready var attacks = $attacks
onready var effect = $blood
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal attack_effect

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	attacks.visible =false
	effect.visible = false
	recived_signal()
	pass # Replace with function body.

func recived_signal():
	self.visible = true
	play_attacks()

func play_attacks():
	anim.queue("attack")
	play_effect()
	
func play_effect():
	anim.queue("attack_effect")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

