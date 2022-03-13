extends Position2D

onready var anim = $AnimationPlayer
onready var embers = $embers
onready var emit_ember = $emit_ember
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	emit_ember.visible =false
	embers.visible = false
	recived_signal()
	pass # Replace with function body.

func recived_signal():
	self.visible = true
	play_emit_ember()

func play_emit_ember():
	anim.queue("emit")
	play_ember()

func play_ember():
	#print("ember")
	anim.queue("ember")
	#embers.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
