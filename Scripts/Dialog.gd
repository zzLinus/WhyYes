extends Node2D
var dialog


func _on_InteractWithNPC_area_entered(area: Area2D):
	var playerNode = get_tree().get_nodes_in_group("Player")
	var parentName = playerNode[0].get_parent().name
	if parentName == "mainScene3":
		print("dundun")
		dialog = Dialogic.start("DunDunDialog")
	elif parentName == "DungeonLayer1":
		dialog = Dialogic.start("FirstDialog")

	add_child(dialog)


func _on_InteractWithNPC_area_exited(area):
	print("player exit")
	dialog.queue_free()
