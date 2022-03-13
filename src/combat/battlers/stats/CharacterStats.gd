# Represents a Battler's actual stats: health, strength, etc.
# See the child class GrowthStats.gd for stats growth curves
# and lookup tables
extends Resource

class_name CharacterStats

signal health_changed(new_health, old_health)
signal health_depleted
signal mana_changed(new_mana, old_mana)
signal mana_depleted

const default_grow = preload("res://src/combat/battlers/stats/growthStats/DefaultGrowthStats.tres")

export(Resource) var growth_stats = default_grow
export(Resource) var individual_stats = null
export(Array, Resource) var learned_skills = []

var modifiers = {}
var level: int = 0
export var tot_experience: int = 0 setget _set_tot_experience
export var text_name: String = ""
var pokemon_name: String = ""

var health: int = 1
var max_health: int = 1
var strength: int = 1
var defense: int = 1
var spec_strength: int = 1
var spec_defense: int = 1
var speed: int = 1

var primary_type = PmType.PmType.NORMAL setget , _get_primary_type
var secondary_type = PmType.PmType.NULL setget , _get_secondary_type

var is_alive: bool = true setget , _is_alive

var stat_modifier = [0, 0, 0, 0, 0, 0, 0]
var nv_status = PmType.non_volatile_status.Null
var nv_counts = 0

#const indi_stats = preload("res://src/combat/battlers/stats/IndividualStats/IndividualStats.gd")


func initialize(growth_stats = null, experience = null):
	if growth_stats != null:
		self.growth_stats = growth_stats
	if self.individual_stats == null:
		self.individual_stats = IndividualStats.new()
	if experience != null:
		self.tot_experience = experience

	update_stats()
#	reset()


func update_stats():
	if not individual_stats:
		self.individual_stats = IndividualStats.new()

	self.level = self.growth_stats.get_level(self.tot_experience)

	self.max_health = calculate_stats(0)
	self.strength = calculate_stats(1)
	self.defense = calculate_stats(2)
	self.spec_strength = calculate_stats(3)
	self.spec_defense = calculate_stats(4)
	self.speed = calculate_stats(5)


func calculate_stats(index: int) -> int:
	var species = self.growth_stats.species_strength[index]
	var individual = self.individual_stats.individual_values[index]
	var level = self.level
	if index == 0:
		return int(round((species + individual) * level / 50 + 10 + level))
	else:
		return int(round((species + individual) * level / 50 + 5))


func reset():
	health = self.max_health
	for port_skill in learned_skills:
		port_skill.reset()


func copy() -> CharacterStats:
	# Perform a more accurate duplication, as normally Resource duplication
	# does not retain any changes, instead duplicating from what's registered
	# in the ResourceLoader
	var copy = duplicate()
	copy.health = health
	for i in range(len(copy.learned_skills)):
		copy.learned_skills[i] = copy.learned_skills[i].duplicate()
	return copy


func take_damage(hit: Hit):
	health_diminish(hit.damage)


func health_diminish(value: int):
	var old_health = health
	health -= value
	health = max(0, health)
	emit_signal("health_changed", health, old_health)
	if health == 0:
		emit_signal("health_depleted")


func heal(amount: int):
	var old_health = health
	health = min(health + amount, max_health)
	emit_signal("health_changed", health, old_health)

func recover_pp():
	for skill in learned_skills:
		skill.reset()

func add_modifier(id: int, modifier):
	modifiers[id] = modifier


func set_nv_status(skill_cause_nv_status: int, rounds: int):
	nv_status = skill_cause_nv_status
	nv_counts = rounds

func remove_nv_status():
	nv_status = PmType.non_volatile_status.Null
	nv_counts = 0

func ending_stage_nv_status():
	var rnt = []

	if nv_status != PmType.non_volatile_status.Null:
		# Burn and Posion status diminish health each turn
		if nv_status == PmType.non_volatile_status.Burn:
			health_diminish(int(round(max_health / 8)))
			rnt.append(text_name + "'s hurt by its burn!")
		if nv_status == PmType.non_volatile_status.Poison:
			health_diminish(int(round(max_health / 8)))
			rnt.append(text_name + "'s hurt by its poison!")
		if nv_counts != -1:
			nv_counts -= 1
		if nv_counts == 0:
			nv_status = PmType.non_volatile_status.Null
	return rnt


func remove_modifier(id: int):
	modifiers.erase(id)


func _is_alive() -> bool:
	return health >= 0


func _get_max_health() -> int:
	return max_health


func get_strength() -> int:
	var t = Type.stats_modifier_type.Attack
	var rnt = strength * Type.get_stage_multiplier(t, stat_modifier[t])
	return int(round(rnt))


func get_defense() -> int:
	var t = Type.stats_modifier_type.Defense
	return int(round(defense * Type.get_stage_multiplier(t, stat_modifier[t])))


func get_spec_strength() -> int:
	var t = Type.stats_modifier_type.SpAttack
	return int(round(spec_strength * Type.get_stage_multiplier(t, stat_modifier[t])))


func get_spec_defense() -> int:
	var t = Type.stats_modifier_type.SpDefense
	return int(round(spec_defense * Type.get_stage_multiplier(t, stat_modifier[t])))


func get_speed() -> int:
	var t = Type.stats_modifier_type.Speed
	var rnt = speed * Type.get_stage_multiplier(t, stat_modifier[t])

	if nv_status == PmType.non_volatile_status.Paralysis:
		rnt = rnt / 2
	return int(round(rnt))


func get_accuracy() -> float:
	var t = Type.stats_modifier_type.Accuracy
	return Type.get_stage_multiplier(t, stat_modifier[t])


func get_evasion() -> float:
	var t = Type.stats_modifier_type.Evasion
	return Type.get_stage_multiplier(t, stat_modifier[t])


func _get_level() -> int:
	return level


func _get_primary_type() -> int:
	return growth_stats.primary_type


func _get_secondary_type() -> int:
	return growth_stats.secondary_type


func _set_tot_experience(value: int):
	if value == null:
		assert(true)
		return
	tot_experience = max(0, value)

	update_stats()


func get_learned_skills():
	return learned_skills

func get_can_learn_skills():
	return growth_stats.can_learn_skills

func add_experience(value: int):
	var old_level = self.level
	self.tot_experience = self.tot_experience + value
	return self.level if self.level > old_level else 0
	
func set_text_name(text_name: String):
	if self.text_name.empty():
		self.text_name = text_name
