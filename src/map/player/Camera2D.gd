extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func auto_set_limits():
	limit_left = 0
	limit_right = 0
	limit_top = 0
	limit_bottom = 0
	var tilemaps = get_node("/root/Game/s")
	if tilemap is TileMap:
		var used = tilemap.get_used_rect()
		limit_left = min(used.position.x * tilemap.cell_size.x, limit_left)
		limit_right = max(used.end.x * tilemap.cell_size.x, limit_right)
		limit_top = min(used.position.y * tilemap.cell_size.y, limit_top)
		limit_bottom = max(used.end.y * tilemap.cell_size.y, limit_bottom)

# Called when the node enters the scene tree for the first time.
func _ready():
	auto_set_limits()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
