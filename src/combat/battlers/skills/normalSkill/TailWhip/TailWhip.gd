extends Position2D

onready var anim = $AnimationPlayer
onready var Tail = $Tail
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	Tail.visible = false
	recived_signal()
	pass # Replace with function body.

func recived_signal():
	self.visible = true
	play_tail()

func play_tail():
	Tail.visible = true
	anim.queue("tail")
	emit_signal("animation_finished", "tail")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AnimationPlayer_animation_finished(anim_name):
	Tail.visible = false
	pass # Replace with function body.
