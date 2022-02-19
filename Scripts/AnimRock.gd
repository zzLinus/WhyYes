extends Sprite

onready var animPlayer = $AnimationPlayer
onready var timer = $Timer


func _ready():
	var randNum = randf()
	timer.wait_time = randNum
	animPlayer.play("RockSmoke2")


func _on_Timer_timeout():
	animPlayer.play("RockSmoke2")


func _on_AnimationPlayer_animation_finished(anim_name: String):
	timer.start()
