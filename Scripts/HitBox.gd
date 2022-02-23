extends Area2D
enum playerDamage { ATTACK1 = 60, ATTACK2 = 90, ATTACK3 = 120 }
enum enemyDamage { ATTACK = 20 }
onready var coliArea = $CollisionPolygon2D


func _ready():
	coliArea.disabled = true
