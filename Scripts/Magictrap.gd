extends AnimatedSprite

const bullet = preload("res://Scenes/MagicFireAndIceBall.tscn")

onready var spawnPoint = $Position2D
var magicTrapName = ["FireHole", "FireHole1", "IceHole", "IceHole1", "FireFace"]

export(int) var magicType
export(int) var magicTrapType
export(float) var lifetime


func _ready():
	play(magicTrapName[magicTrapType])
	Shoot()


func Shoot():
	var projectile = bullet.instance()
	call_deferred("add_child", projectile)
	projectile.global_position = spawnPoint.position


func _on_AnimatedSprite_animation_finished():
	play(magicTrapName[magicTrapType])
	Shoot()
