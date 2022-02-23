extends Control

var isPause = false setget SetIsPause


func _ready():
	visible = false


func _unhandled_input(event):
	if event.is_action_pressed("Pause"):
		self.isPause = !isPause


func SetIsPause(value):
	isPause = value
	get_tree().paused = isPause
	visible = isPause


func _on_Button_pressed():
	self.isPause = false


func _on_Button2_pressed():
	get_tree().quit()


func _on_Button3_pressed():
	AutoloadScript.playerData.playerIsFirstLoad = true
	if get_tree().change_scene("res://Scenes/main.tscn") != OK:
		print("unable to change scene")
	self.isPause = false
