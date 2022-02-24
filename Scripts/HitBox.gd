extends Area2D
enum playerDamage { ATTACK1 = 60, ATTACK2 = 90, ATTACK3 = 120 }
enum enemyDamage { ATTACK = 20 }


func _ready():
	if self.name == "Bullet":
		$CollisionShape2D.disabled = false
	else:
		$CollisionPolygon2D.disabled = true

