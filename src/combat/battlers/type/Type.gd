extends Node

class_name PmType

# Pokemon Type

enum PmType {
	NORMAL,
	FIGHT,
	FLYING,
	POISON,
	GROUND,
	ROCK,
	BUG,
	GHOST,
	STEEL,
	FIRE,
	WATER,
	GRASS,
	ELECTR,
	PSYCHO,
	ICE,
	DRAGON,
	DARK,
	FAIRY,
	NULL
}

const string_list = [
	"NORMAL",
	"FIGHT",
	"FLYING",
	"POISON",
	"GROUND",
	"ROCK",
	"BUG",
	"GHOST",
	"STEEL",
	"FIRE",
	"WATER",
	"GRASS",
	"ELECTR",
	"PSYCHO",
	"ICE",
	"DRAGON",
	"DARK",
	"FAIRY",
	"_"
]

const physical_move = [
	PmType.NORMAL,
	PmType.FIGHT,
	PmType.FLYING,
	PmType.GROUND,
	PmType.ROCK,
	PmType.BUG,
	PmType.GHOST,
	PmType.POISON,
	PmType.STEEL
]

const type_chart = [
	[1.0, 1.0, 1.0, 1.0, 1.0, 0.5, 1.0, 0.0, 0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0],  #NORMAL
	[2.0, 1.0, 0.5, 0.5, 1.0, 2.0, 0.5, 0.0, 2.0, 1.0, 1.0, 1.0, 1.0, 0.5, 2.0, 1.0, 2.0, 0.5, 1.0],  #FIGHT
	[1.0, 2.0, 1.0, 1.0, 1.0, 0.5, 2.0, 1.0, 0.5, 1.0, 1.0, 2.0, 0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0],  #FLYING
	[1.0, 1.0, 1.0, 0.5, 0.5, 0.5, 1.0, 0.5, 0.0, 1.0, 1.0, 2.0, 1.0, 1.0, 1.0, 1.0, 1.0, 2.0, 1.0],  #POSION
	[1.0, 1.0, 0.0, 2.0, 1.0, 2.0, 0.5, 1.0, 2.0, 2.0, 1.0, 0.5, 2.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0],  #GROUND
	[1.0, 0.5, 2.0, 1.0, 0.5, 1.0, 2.0, 1.0, 0.5, 2.0, 1.0, 1.0, 1.0, 1.0, 2.0, 1.0, 1.0, 1.0, 1.0],  #ROCK
	[1.0, 0.5, 0.5, 0.5, 1.0, 1.0, 1.0, 0.5, 0.5, 0.5, 1.0, 2.0, 1.0, 2.0, 1.0, 1.0, 2.0, 0.5, 1.0],  #BUG
	[0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 2.0, 1.0, 1.0, 1.0, 1.0, 1.0, 2.0, 1.0, 1.0, 0.5, 1.0, 1.0],  #GHOST
	[1.0, 1.0, 1.0, 1.0, 1.0, 2.0, 1.0, 1.0, 0.5, 0.5, 0.5, 1.0, 0.5, 1.0, 2.0, 1.0, 1.0, 2.0, 1.0],  #STEEL
	[1.0, 1.0, 1.0, 1.0, 1.0, 0.5, 2.0, 1.0, 2.0, 0.5, 0.5, 2.0, 1.0, 1.0, 2.0, 0.5, 1.0, 1.0, 1.0],  #FIRE
	[1.0, 1.0, 1.0, 1.0, 2.0, 2.0, 1.0, 1.0, 1.0, 2.0, 0.5, 0.5, 1.0, 1.0, 1.0, 0.5, 1.0, 1.0, 1.0],  #WATER
	[1.0, 1.0, 0.5, 0.5, 2.0, 2.0, 0.5, 1.0, 0.5, 0.5, 2.0, 0.5, 1.0, 1.0, 1.0, 0.5, 1.0, 1.0, 1.0],  #GRASS
	[1.0, 1.0, 2.0, 1.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 2.0, 0.5, 0.5, 1.0, 1.0, 0.5, 1.0, 1.0, 1.0],  #ELECTR
	[1.0, 2.0, 1.0, 2.0, 1.0, 1.0, 1.0, 1.0, 0.5, 1.0, 1.0, 1.0, 1.0, 0.5, 1.0, 1.0, 0.0, 1.0, 1.0],  #PSYCHO
	[1.0, 1.0, 2.0, 1.0, 2.0, 1.0, 1.0, 1.0, 0.5, 0.5, 0.5, 2.0, 1.0, 1.0, 0.5, 2.0, 1.0, 1.0, 1.0],  #ICE
	[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 2.0, 1.0, 0.0, 1.0],  #DRAGON
	[1.0, 0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 2.0, 1.0, 1.0, 1.0, 1.0, 1.0, 2.0, 1.0, 1.0, 0.5, 0.5, 1.0],  #DARK
	[1.0, 2.0, 1.0, 0.5, 1.0, 1.0, 1.0, 1.0, 0.5, 0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 2.0, 2.0, 1.0, 1.0],  #FAIRY
	[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0],  #NULL
]


static func type_to_string(type: int) -> String:
	return string_list[type]


static func is_physical_type(type) -> bool:
	return type in physical_move


# Stats Modifier

enum stats_modifier_type { Attack, Defense, SpAttack, SpDefense, Speed, Accuracy, Evasion }

const stats_modifier_str = [
	"Attack", "Defense", "Special Attack", "Special Defense", "Speed", "Accuracy", "Evasion"
]

const normal_stage_multipliers = [
	2.0 / 8,
	2.0 / 7,
	2.0 / 6,
	2.0 / 5,
	2.0 / 4,
	2.0 / 3,
	2.0 / 2,
	3.0 / 2,
	4.0 / 2,
	5.0 / 2,
	6.0 / 2,
	7.0 / 2,
	8.0 / 2
]

const acc_eva_stage_multipliers = [
	3.0 / 9,
	3.0 / 8,
	3.0 / 7,
	3.0 / 6,
	3.0 / 5,
	3.0 / 4,
	3.0 / 3,
	4.0 / 3,
	5.0 / 3,
	6.0 / 3,
	7.0 / 3,
	8.0 / 3,
	9.0 / 3
]


static func get_stage_multiplier(modifier_type: int, level: int):
	if modifier_type <= stats_modifier_type.Speed:
		return normal_stage_multipliers[level + 6]
	else:
		return acc_eva_stage_multipliers[level + 6]


# Status Condition

enum non_volatile_status { Null, Burn, Freeze, Paralysis, Poison, Sleep }
