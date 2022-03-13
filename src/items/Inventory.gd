extends Reference

class_name Inventory

export (int) var MAX_COINS = 99999
var coins: int = 100000
var content = {}

signal item_count_changed(item, amount)
signal coins_count_changed(amount)

func get_coins():
	return coins

func get_number(item:Item):
	if item in content:
		return content[item]
	else:
		return 0

func add(item: Item, amount: int = 1) -> void:
	if item in content:
		content[item] += amount
	else:
		content[item] = 1 if item.unique else amount


func remove(item: Item, amount: int = 1):
	if(check_removeable(item,amount)):
		content[item] -= amount
		if content[item] == 0:
			content.erase(item)
		return true
	else:
		return false

func check_removeable(item:Item, amount: int = 1):
	if item in content:
		if amount<=content[item]:
			return true
		else:
			return false
	else:
		return false

func add_coins(amount: int) -> void:
	coins = min(coins + amount, MAX_COINS)


func remove_coins(amount: int) -> void:
	coins = max(0, coins - amount)
	
func get_content(network) -> Dictionary:
#	if network == null:
	return content
#	var rnt = {}
#	for item in content.keys():
#		if not item is PokemonBall:
#			rnt[item] = content[item]
#	return rnt
	

