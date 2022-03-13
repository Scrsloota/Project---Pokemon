extends "res://src/combat/CombatAction.gd"

class_name RunAction

signal run_away


func _init():
	pass

func execute(actor, target: Battler):
	var act_spd = float(actor.stats.get_speed())
	var tar_spd = float(target.stats.get_speed())
	if act_spd/tar_spd >  RandomGenerater.randf():
		emit_signal("run_away")
		return ["You Got Away Safely!"]
	else:
		return ["You couldn't get away!"]
