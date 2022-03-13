extends Position2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var attack_sprite = $attack_sprite
onready var anim = $AnimationPlayer
onready var sleep_state = $sleep_state
onready var powder = $absorb_powder
signal prepare_absorb

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	attack_sprite.visible = false
	powder.visible = false
	sleep_state.visible = false
	recived_signal()

func recived_signal():
	self.visible = true
	play_attack()
	
func play_attack():
	attack_sprite.visible = true
	anim.queue("attack")
	absorb_powder()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func absorb_powder():
	#粒子特效
	#print("absorb_powder")
	anim.queue("absorb_powder")
	sleep()
	#emit_signal("prepare_absorb")
	#if powder.emitting == false:

func sleep():
	#print("sleep")
	anim.queue("sleep_state")
	sleep_state.visible = false

