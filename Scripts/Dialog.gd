extends Node2D
var dialog


func _on_InteractWithNPC_area_entered(area: Area2D):
	dialog = Dialogic.start("FirstDialog")
	add_child(dialog)


func _on_InteractWithNPC_area_exited(area: Area2D):
	dialog.queue_free()
