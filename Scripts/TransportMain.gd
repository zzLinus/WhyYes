extends Position2D
var player


func _ready():
	player = get_node("../Player")


func _process(delta):
	global_position = player.global_position
