extends AnimatedSprite


func _ready():
	play("SpawnSmoke")


func _on_AnimatedSprite_animation_finished():
	queue_free()
