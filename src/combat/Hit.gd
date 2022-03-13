# Base object that represents an attack or a hit

class_name Hit

enum enum_damage_effct { INEFFECTIVE, NOTVERY, NORMAL, SUPER }

var damage: int = 0
# var effect : StatusEffect = StatusEffect.new()

var critical_hit: bool = false

var damage_effect: int = enum_damage_effct.NORMAL

var miss: bool = false

var message = []


func _init(actor_stats, skill: Skill, target_stats) -> void:
	message.append("%s used %s!" % [actor_stats.text_name, skill.name])

	# Sleep status makes actor cannot move
	if actor_stats.nv_status == PmType.non_volatile_status.Sleep:
		message.append("%s is fast asleep!" % actor_stats.text_name)
		return

	# Freeze status makes actor cannot move
	if actor_stats.nv_status == PmType.non_volatile_status.Freeze:
		message.append("%s is frozen solid!" % actor_stats.text_name)
		return

	# Paralysis status makes actor runs a 25% risk of losing their turn
	if actor_stats.nv_status == PmType.non_volatile_status.Paralysis:
		if RandomGenerater.randf() < 0.25:
			message.append("%s is paralyzed! It can't move!" % actor_stats.text_name)
			return

	# missing judgement
	var skill_accuracy = (
		skill.success_chance
		* actor_stats.get_accuracy()
		/ target_stats.get_evasion()
	)
	if RandomGenerater.randf() > skill_accuracy:
		message.append("%s's attack missed!" % actor_stats.text_name)
		miss = true
		return

	# Take damage
	if skill.base_damage != 0:
		var skill_type = skill.type
		var actor_primary_type = target_stats.primary_type
		var actor_secondary_type = target_stats.secondary_type
		var target_primary_type = target_stats.primary_type
		var target_secondary_type = target_stats.secondary_type
		var actor_level = actor_stats.level
		var skill_power = skill.base_damage
		var attack_defense = (
			actor_stats.get_strength() / target_stats.get_defense()
			if PmType.is_physical_type(skill_type)
			else actor_stats.get_spec_strength() / target_stats.get_spec_defense()
		)

		var type_effect = calculate_type_effect(
			skill_type, target_primary_type, target_secondary_type
		)

		var stab = calculate_stab(skill_type, actor_primary_type, actor_secondary_type)

		var rand_factor = RandomGenerater.randf_range(0.85, 1.0)

		var critical_hit_factor = calculate_critical_hit(1 / 16)

		damage = int(
			round(
				(
					((2 * actor_level / 5 + 2) * skill_power * attack_defense / 50 + 2)
					* type_effect
					* stab
					* rand_factor
					* critical_hit_factor
				)
			)
		)

		# Burn status let physical_type damage halved
		if (
			actor_stats.nv_status == PmType.non_volatile_status.Burn
			and PmType.is_physical_type(skill_type)
		):
			damage = int(round(damage / 2))

		# The damaged target will weak up
		if target_stats.nv_status == PmType.non_volatile_status.Sleep:
			target_stats.nv_status = PmType.non_volatile_status.Null
			target_stats.nv_counts = 0

		match damage_effect:
			enum_damage_effct.INEFFECTIVE:
				message.append("Not effective!")
			enum_damage_effct.NOTVERY:
				message.append("Not very effective!")
			enum_damage_effct.NORMAL:
				pass
			enum_damage_effct.SUPER:
				message.append("Super effective!")

		if critical_hit:
			message.append("A critical hit!")

	make_stat_modify(skill.stat_modify_oppo, target_stats, target_stats.text_name)
	make_stat_modify(skill.stat_modify_self, actor_stats, actor_stats.text_name)

	if skill.nv_status_oppo != PmType.non_volatile_status.Null:
		if RandomGenerater.randf()<skill.nv_status_chance:
			make_nv_status(skill.nv_status_oppo, target_stats)


func is_physical_type(skill_type: int) -> bool:
	return skill_type in Type.physical_move


func calculate_type_effect(skill_type: int, target_primary_type: int, target_secondary_type: int) -> float:
	var rnt: float = (
		Type.type_chart[skill_type][target_primary_type]
		* Type.type_chart[skill_type][target_secondary_type]
	)
	if rnt <= 0.0:
		damage_effect = enum_damage_effct.INEFFECTIVE
	elif rnt <= 0.5:
		damage_effect = enum_damage_effct.NOTVERY
	elif rnt <= 1.0:
		damage_effect = enum_damage_effct.NORMAL
	elif rnt <= 4.0:
		damage_effect = enum_damage_effct.SUPER
	return rnt


func calculate_stab(skill_type, actor_primary_type, actor_secondary_type) -> float:
	return (
		1.5
		if (skill_type == actor_primary_type) or (skill_type == actor_secondary_type)
		else 1.0
	)


func calculate_critical_hit(possiblity) -> float:
	if RandomGenerater.randf() < possiblity:
		critical_hit = true
		return 2.0
	else:
		return 1.0


func make_stat_modify(skill_stat_modify, target_stats, target_name):
	var change = []
	var flag_improve = 0
	for i in range(7):
		if skill_stat_modify[i] != 0:
			target_stats.stat_modifier[i] += skill_stat_modify[i]
			target_stats.stat_modifier[i] = max(target_stats.stat_modifier[i],-6)
			target_stats.stat_modifier[i] = min(target_stats.stat_modifier[i],6)
			change.append(Type.stats_modifier_str[i])
			flag_improve = 1 if skill_stat_modify[i] > 0 else -1
	if flag_improve != 0:
		var msg = target_name + "'s "
		for i in range(len(change) - 1):
			msg += change[i] + ", "
		msg += change[-1]
		msg += " fell!" if flag_improve < 0 else " rose!"
		message.append(msg)


func calculate_nv_status_rounds(skill_nv_status: int) -> int:
	match skill_nv_status:
		PmType.non_volatile_status.Burn, PmType.non_volatile_status.Poison, PmType.non_volatile_status.Paralysis:
			return -1
		PmType.non_volatile_status.Freeze, PmType.non_volatile_status.Sleep:
			return RandomGenerater.randi() % 3 + 1
		_:
			return 0


func make_nv_status(skill_nv_status, target_stats):
	if (target_stats.nv_status == PmType.non_volatile_status.Null):
		target_stats.set_nv_status(skill_nv_status, calculate_nv_status_rounds(skill_nv_status))
		
		match skill_nv_status:
			PmType.non_volatile_status.Burn:
				message.append("%s's was burn heavily!" % target_stats.text_name)
			PmType.non_volatile_status.Poison:
				message.append("%s's was poisoned!" % target_stats.text_name)
			PmType.non_volatile_status.Paralysis:
				message.append("%s's paralized! Maybe it can't attack!" % target_stats.text_name)
			PmType.non_volatile_status.Freeze:
				message.append("%s's was frozen!" % target_stats.text_name)
			PmType.non_volatile_status.Sleep:
				message.append("%s's fell a sleep!" % target_stats.text_name)
