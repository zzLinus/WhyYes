extends Area2D
export(int) var diraction

signal diraction(dirac)
signal deactive


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


func _on_DiractionSign_area_entered(area):
	print("give sign")
	emit_signal("diraction", diraction)


func _on_DiractionSign_area_exited(area):
	print("give sign2")
	emit_signal("deactive")
