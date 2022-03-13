extends Resource
class_name Item

enum Category { CONSUMABLE, MATERIAL, KEY, EQUIPMENT }

export var icon: Texture = load("res://icon.png")
export var name: String
export var description: String
export var unique: bool = false
export (int) var sell_price
export (int) var buy_price
