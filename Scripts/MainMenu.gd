extends Control


func _ready():
	pass  # Replace with function body.


func _on_Start_pressed():
	if get_tree().change_scene("res://Scenes/mainScene2.tscn") != OK:
		print("unable to change scene")


func _on_Settings_pressed():
	pass  # Replace with function body.


func _on_Button2_pressed():
	get_tree().quit()
