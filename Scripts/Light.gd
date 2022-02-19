extends Node
onready var animPlayer = $AnimationPlayer


func _ready():
	animPlayer.play("Light")
