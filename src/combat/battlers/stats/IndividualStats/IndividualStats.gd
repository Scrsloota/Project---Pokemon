extends Resource
class_name IndividualStats

# HP, Attack, Defence, SpecAttack, SpecDefence, Speed
export(Array, int) var individual_values = []

func _init():
	randomize()
	for i in range(6):
		individual_values.append(randi()%32)

