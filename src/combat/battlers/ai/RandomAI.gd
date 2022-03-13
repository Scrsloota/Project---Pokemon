extends BattlerAI
class_name RandomAI
const DEFAULT_CHANCE = 0.75


func choose_action(actor: Battler, normal_mode = true):
	# For now, we just choose the first action on a battler
	# we use yield even though determining an action is instantaneous
	# because the combat arena expects this to be an async function
	if normal_mode:
		var skill_num = len(actor.stats.learned_skills)
		var rand_skill = actor.stats.learned_skills[randi() % skill_num]
		return SkillAction.new(rand_skill)
	else:
		return SurrenderAction.new()
