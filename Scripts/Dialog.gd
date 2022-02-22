extends Node2D


func _ready():
	var dialog = Dialogic.start("firstConversation")
	add_child(dialog)

