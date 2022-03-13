extends CombatAction

class_name ChangeAction


signal change_pokemon

var change_battler: Battler = null

func _init(battler = null):
	self.change_battler = battler

func _ready() -> void:
	name = change_battler.name

func execute(actor, target) -> Array:
	if actor.party_member and not target:
		return false

	yield(actor.get_tree().create_timer(0.0), "timeout")
	if actor.party_member:
		emit_signal("change_pokemon", change_battler, true)
	else:
		emit_signal("change_pokemon", change_battler, false)

	return ["Come back! %s!" % actor.stats.text_name, "Go! %s!" % change_battler.stats.text_name]
