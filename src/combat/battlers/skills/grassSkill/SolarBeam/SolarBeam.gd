extends Position2D


onready var anim = $AnimationPlayer
onready var second = $second
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal first_type

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	self.visible = false
	second.visible =false
	recived_signal()
	pass # Replace with function body.

func recived_signal():
	#if value == 1:
#	self.visible = true	
#	emit_signal("first_type")
	#elif value == 2:
	self.visible = true
	play_second()
#	else:
#		self.visible = false
#		self.visible = false
#		second.visible =false
	
func play_second():
	second.visible = true
	anim.queue("second")
