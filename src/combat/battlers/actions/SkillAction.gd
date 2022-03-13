extends CombatAction

class_name SkillAction

signal anim_start_signal
signal anim_stop_signal

# PortableSkill
var skill = null

func _init(skill = null):
	self.skill = skill

func _ready() -> void:
	name = skill.name

func execute(actor, target) -> Array:
	if actor.party_member and not target:
		return false

	skill.pp_cost()

	var hit = Hit.new(actor.stats, skill.skill, target.stats)
	if not hit.miss:
		target.take_damage(hit)

	var anim
	if actor.party_member:
		anim = skill.skill.self_skill_anim
	else:
		anim = skill.skill.oppo_skill_anim
	if anim != null:
		anim = anim.instance()
		emit_signal("anim_start_signal",anim)
		yield(anim.get_node("AnimationPlayer"),"animation_finished")
		emit_signal("anim_stop_signal",anim)


	yield(return_to_start_position(actor), "completed")
	return hit.message
