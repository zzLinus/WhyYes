extends Node


var currentScene: int

var playerData = {
	"playerMaxHealth": 100,
	"playerHealth": 100,
	"playerSpeed": 250,
	"playerState": 1,
	"playerDoingTrans": false,
	"playerDoingAction": false,
	"playerComboAction": 0,
	"playerIsFirstLoad": true,
	"playerSpawnPoint": 0,
	"playerPos": Vector2(0, 0),
}

var enemyData = {
	"enemyMaxHealth": 300,
}

var playerSpawnPos


func _ready():
	pass  # Replace with function body.


func GetSpawnPoint() -> Vector2:
	var targetNodeName: String
	var pos: Vector2
	if playerData.playerSpawnPoint == 1:
		targetNodeName = "SpawnPoint1"
	if playerData.playerSpawnPoint == 2:
		targetNodeName = "SpawnPoint2"
	if playerData.playerSpawnPoint == 3:
		targetNodeName = "SpawnPoint3"
	if playerData.playerSpawnPoint == 4:
		targetNodeName = "SpawnPoint4"
	if playerData.playerSpawnPoint == 5:
		targetNodeName = "SpawnPoint5"
	if playerData.playerSpawnPoint == 6:
		targetNodeName = "SpawnPoint6"
	if playerData.playerSpawnPoint == 7:
		targetNodeName = "SpawnPoint7"

	print("go to spawn points" + targetNodeName)

	var nodes = get_tree().get_nodes_in_group("Portals")
	for node in nodes:
		if node.name == targetNodeName:
			pos = node.global_position

	return pos
