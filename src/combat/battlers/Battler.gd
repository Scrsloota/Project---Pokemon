# Base entity that represents a character or a monster in combat
# Every battler has an AI node so all characters can work as a monster
# or as a computer-controlled player ally
extends Position2D

class_name Battler

signal died(battler)

export var TARGET_OFFSET_DISTANCE: float = 120.0

export(Resource) var stats

onready var skin = $Skin

var selected: bool = false setget set_selected
var selectable: bool = false setget set_selectable

#var primary_type setget , _get_primary_type
#var secondary_type setget , _get_secondary_type
#var learned_skills setget , _get_learned_skills

#var max_hp setget , _get_max_hp
#var cur_hp setget , _get_cur_hp

export var battler_name: String
export var party_member = false


func _ready() -> void:
	selectable = true

	stats.initialize()


func initialize():
	skin.initialize()
	stats.connect("health_depleted", self, "_on_health_depleted")
	if not stats.text_name:
		stats.set_text_name(get_battler_name())


func is_able_to_play() -> bool:
	# Returns true if the battler can perform an action
	return stats.health > 0


func set_selected(value):
	selected = value
	skin.blink = value


func set_selectable(value):
	selectable = value
	if not selectable:
		set_selected(false)


func take_damage(hit):
	stats.take_damage(hit)
	# prevent playing both stagger and death animation if health <= 0
	if stats.health > 0:
		skin.play_stagger()


func _on_health_depleted():
	selectable = false
	yield(skin.play_death(), "completed")
	emit_signal("died", self)


func appear():
	var offset_direction = 1.0  #if party_member else -1.0
	skin.position.x += TARGET_OFFSET_DISTANCE * offset_direction
	skin.appear()


func has_point(point: Vector2):
	return skin.battler_anim.extents.has_point(point)


func get_primary_type() -> int:
	return self.stats.primary_type


func get_secondary_type() -> int:
	return self.stats.secondary_type


func get_learned_skills() -> Array:
	return self.stats.learned_skills


func get_max_hp() -> int:
	return self.stats.max_health


func get_cur_hp() -> int:
	return self.stats.health


func get_portable_skills() -> Array:
	return self.stats.get_learned_skills()


func get_nv_status() -> int:
	return stats.nv_status


func equal(battler: Battler) -> bool:
	return stats == battler.stats


func get_level() -> int:
	return stats._get_level()


func get_icon():
	return stats.growth_stats.icon

func get_battler_name():
	return battler_name


func change_skin(skin_type: int):
	var pokemon_name = stats.pokemon_name
	if skin.get_node_or_null("Anim") != null:
		skin.remove_child(skin.get_node("Anim"))
	if skin_type == 0:
		var insert_anim = load("res://src/combat/animation/Self%sAnim.tscn" % pokemon_name).instance()
		insert_anim.name = "Anim"
		skin.add_child(insert_anim)
	if skin_type == 1:
		var insert_anim = load("res://src/combat/animation/Oppo%sAnim.tscn" % pokemon_name).instance()
		insert_anim.name = "Anim"
		skin.add_child(insert_anim)


#func change_ai(ai_type: int):
#	if ai_type == 0:
#		ai.set_script(load("res://src/combat/battlers/ai/PlayerInput.gd"))
#	if ai_type == 1:
#		ai.set_script(load("res://src/combat/battlers/ai/RandomAI.gd"))
#	if ai_type == 2:
#		ai.set_script(load("res://src/combat/battlers/ai/NetworkSelfAI.gd"))
#	if ai_type == 3:
#		ai.set_script(load("res://src/combat/battlers/ai/NetworkOppoAI.gd"))
#
#func state_dict():
#	return {
#		'skill': skill.state_dict(),
#		'actor': actor.state_dict()
#	}

#static func from_state_dict(dict):
#	var loaded_skill = PortableSkill.from_state_dict(dict['skill'])
#	var loaded_action = dict['actor']
#	var new_skill_action = SkillAction.new()
#	return new_skill_action
