extends Position2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var attack_sprite = $attack_sprite
onready var anim = $AnimationPlayer
onready var powder = $absorb_powder

signal prepare_absorb

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	attack_sprite.visible = false
	powder.visible = false
	recived_signal()

func recived_signal():
	self.visible = true
	play_attack()
	
func play_attack():
	anim.queue("attack")
	play_absorb()
	
func play_absorb():
	anim.queue("absorb_powder")
