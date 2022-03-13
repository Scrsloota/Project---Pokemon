extends Resource
class_name PortableSkill

export var skill: Resource
export var cur_pp: int

func _init():
	skill = load('res://src/combat/battlers/skills/EmptySkill.tres')
	cur_pp = 0
	
func get_skill_name():
	return skill.name
	
func get_success_chance():
	return skill.success_chance

func get_cur_pp():
	return cur_pp
	
func get_max_pp():
	return skill.max_pp

func get_description():
	return skill.description

func get_typename():
	return skill.get_typename()

func reset():
	cur_pp = skill.max_pp

func pp_cost():
	cur_pp -=  1
