extends CombatAction

class_name ItemAction

var item: Item = null

var inventory

func _init(item = null):
	self.item = item

func _ready() -> void:
	pass
	#name = skill.name

func execute(actor, target) -> Array:
	var message = []
	if actor.party_member and not target:
		return false
		
	inventory.remove(item)
	message.append("You used %s!" % item.name)
	message.append(item.implement_function(actor, target))

	yield(return_to_start_position(actor), "completed")
	
	return message
