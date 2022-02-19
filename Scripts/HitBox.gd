extends Area2D
enum playerDamage { ATTACK1 = 20, ATTACK2 = 30, ATTACK3 = 40 }
enum enemyDamage { ATTACK = 20 }
onready var coliArea = $CollisionPolygon2D


func _ready():
	coliArea.disabled = true
