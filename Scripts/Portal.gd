extends Area2D

export(String, FILE) var nextScenePath = ""


func _ready():
	pass  # Replace with function body.


func _on_Portal_body_entered(body):
	if body.name == "Player":
		print("player entered")

	yield(get_tree().create_timer(1.6), "timeout")
	if get_tree().change_scene(nextScenePath) != OK:
		print("unable to change scene")
