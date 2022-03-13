# Pawn the player can interact with. Could be an NPC, a chest,
# anything that should react when the player walks next to it
# or presses a key while sitting next to this pawn.
# Can work either with raycasts for interactions based on
# look direction or using an Area2D
extends PawnActor
class_name Nurse
signal interaction_finished(pawn)
# Pawn that can move on the GameBoard and play animations

onready var raycasts: Node2D = $Raycasts
onready var dialogue_balloon: Sprite = $DialogueBalloon
onready var collision_range: CollisionShape2D = $CollisionRange
onready var actions: Node = $Actions
onready var heal_action: Node = $Actions/HealAction
onready var action_on: bool = false

export var vanish_on_interaction := false
export var AUTO_START_INTERACTION := false
export var sight_distance = 50
export var facing = {"up": true, "left": true, "right": true, "down": true}
var active_raycasts := []


func _ready():
	# Initializes raycast nodes, deactivates the area if using raycasts
	# for player detection
	dialogue_balloon.hide()
	heal_action.set_menu_selectable(false)
	var use_area = true
	for raycast in raycasts.get_children():
		if not facing[raycast.name.to_lower()]:
			continue
		raycast.enabled = true
		raycast.cast_to = raycast.cast_to.normalized() * sight_distance
		active_raycasts.append(raycast)
		use_area = false

	if use_area:
		connect('body_entered', self, '_on_body_entered')
		connect('body_exited', self, '_on_body_exited')
		set_physics_process(false)



func _unhandled_input(event: InputEvent) -> void:
	# Use the area to detect if the user is clicking on the NPCs' interaction zone
	if event is InputEventMouseButton:
		var extents = collision_range.shape.extents
		var as_rect := Rect2(-extents, extents * 2)
		if not as_rect.has_point(get_local_mouse_position()):
			return
	if event.is_action_pressed("interaction_with_pawn") and dialogue_balloon.visible and not action_on:
		action_on = true
		start_interaction()
		get_tree().set_input_as_handled()


func _physics_process(delta: float) -> void:
	# Only runs if using raycasts/specific directions for player detection
	if not dialogue_balloon.visible:
		for raycast in active_raycasts:
			if not raycast.is_colliding():
				continue
			if AUTO_START_INTERACTION:
				start_interaction()	
			dialogue_balloon.show()
	else:
		var inactive_count: int = 0
		for raycast in active_raycasts:
			if not raycast.is_colliding():
				inactive_count += 1
		if inactive_count == active_raycasts.size():
			dialogue_balloon.visible = false
			heal_action.set_menu_selectable(false)


func _on_body_entered(body: PhysicsBody2D) -> void:
	if AUTO_START_INTERACTION:
		start_interaction()
	else:
		dialogue_balloon.show()


func _on_body_exited(body: PhysicsBody2D) -> void:
	dialogue_balloon.hide()
	heal_action.set_menu_selectable(false)


func start_interaction() -> void:
	print("start_interaction")
	dialogue_balloon.hide()
	get_tree().paused = true
	var actions = $Actions.get_children()
	# An interactive pawn should have some interaction
	assert(actions != [])
	for action in actions:
		print("action start")
		action.interact()
		yield(action, "finished")
		print("action_finished")
	emit_signal("interaction_finished", self)
	if vanish_on_interaction:
		queue_free()
	get_tree().paused = false
	action_on = false

func initialize(board):
	game_board = board

func change_skin(pawn_anim: PawnAnim):
	# Replaces the pawn's animated character with another
	if anim:
		anim.queue_free()
	anim = pawn_anim
	pivot.add_child(pawn_anim)
