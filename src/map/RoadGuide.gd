extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	
	self.visible = false 
	set_physics_process(false)
	# Replace with function body.

func show_message():
	self.visible = true

func close_message():
	self.visible = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
