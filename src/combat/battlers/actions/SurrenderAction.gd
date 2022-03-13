extends CombatAction
class_name SurrenderAction

signal surrender

func _init():
	pass

func _ready() -> void:
	pass

func execute(actor, target) -> Array:
	emit_signal("surrender")
	return ["surrender"]
