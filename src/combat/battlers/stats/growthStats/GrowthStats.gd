extends Resource
class_name GrowthStats

export(Resource) var level_array

# HP, Attack, Defence, SpecAttack, SpecDefence, Speed
export(Array, int) var species_strength = []
export(PmType.PmType) var primary_type = PmType.PmType.NORMAL
export(PmType.PmType) var secondary_type = PmType.PmType.NULL
export var icon: Resource = preload("res://girl_icon.png")
export(Array, Resource) var can_learn_skills = []


func get_level(value: int) -> int:
	return level_array.get_level(value)
