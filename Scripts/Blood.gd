extends Node2D

onready var animPlayer = $AnimationPlayer


func ShowBlood(attackType: int = 4):
	print("spawn blood")
	if attackType == 4:
		animPlayer.play("Blood1")
	elif attackType == 5:
		animPlayer.play("Blood2")
	else:
		animPlayer.play("Blood3")
