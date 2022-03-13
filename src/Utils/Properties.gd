extends Node

const properties = {
	'server_url': 'wss://lab.polarisxyz.me/pinp_ws'
}

func _ready():
	pass

func get(key):
	return properties[key]
