extends Node2D

signal network_player_encountered()

func _ready():
	pass # Replace with function body.

func get_player():
	return $YSort/Player

func _unhandled_input(event):
	if event.is_action_pressed('ui_accept'):
		if len($PvPArea.get_overlapping_bodies()) > 0:
			emit_signal("network_player_encountered")
