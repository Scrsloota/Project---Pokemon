extends Resource

class_name LevelArray

export(Array, int) var poly_factor   # [100]

# level 

func get_level(experience: int) -> int:
	for i in range(99):
		if experience > poly_factor[i] and experience < poly_factor[i+1]:
			return i+1
	return 100
