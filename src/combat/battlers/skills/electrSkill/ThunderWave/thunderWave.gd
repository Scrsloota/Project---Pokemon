extends Position2D

onready var anim = $AnimationPlayer
onready var electric = $electric
onready var wave = $wave
signal select_skill

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	electric.visible = false
	wave.visible = false
	recived_signal()
	pass # Replace with function body.

func recived_signal():
	self.visible = true
	play_thund()

func play_thund():
	#闪电效果
	anim.queue("thund")
	play_wave()

func play_electric():
	#被电状态保留
	anim.queue("electric")
	
	#self.visible = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func play_wave():
	anim.queue("wave")
	#play_electric()


#func _on_AnimationPlayer_animation_finished(anim_name):
#	pass # Replace with function body.
