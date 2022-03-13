extends Resource

class_name Skill

signal missed(text)

export var name: String = "Skill"
export var description: String = ""

export var max_pp: int
export var base_damage: int
export (PmType.PmType) var type = PmType.PmType.NULL
export (float, 0.0, 1.0) var success_chance: float
export (Array, int) var stat_modify_oppo = [0,0,0,0,0,0,0]
export (Array, int) var stat_modify_self = [0,0,0,0,0,0,0]
export (PmType.non_volatile_status) var nv_status_oppo = PmType.non_volatile_status.Null
export (float, 0.0, 1.0) var nv_status_chance: float
export (PackedScene) var self_skill_anim = null
export (PackedScene) var oppo_skill_anim = null

func get_typename():
	return PmType.type_to_string(type)
