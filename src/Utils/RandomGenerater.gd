extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var count = 0
var limit = 0.0
var RNG = RandomNumberGenerator.new()
var is_main_node: bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	RNG.randomize()

func generate_random():
	var random_number = randf()
	count += 1
	if count <= 5:
		limit = 0
		if random_number < limit:
			limit = 0.0
			count = 0
			return true
	elif count <= 10 and count > 5:
		limit += 0.001
		if random_number < limit:
			limit = 0.0
			count = 0
			return true
	elif count <= 20 and count > 10:
		limit += 0.01
		if random_number < limit:
			limit = 0.0
			count = 0
			return true
	elif count > 20:
		limit += 0.2
		if random_number < limit:
			limit = 0.0
			count = 0
			return true
	return false
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
	
func set_seed(s):
	RNG.seed = s
	
func randf():
	return RNG.randf()
	
func randi():
	return RNG.randi()
	
func randf_range(from, to):
	return RNG.randf_range(from, to)
	
func randi_range(from, to):
	return RNG.randi_range(from, to)
	
func is_main_node():
	return is_main_node
