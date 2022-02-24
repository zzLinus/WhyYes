extends RigidBody2D


func _ready():
	yield(get_tree().create_timer(1), "timeout")
	print("queue free")
	queue_free()


func _on_EnemyAttack_area_entered(area: Area2D):
	print("hit ")
	queue_free()
