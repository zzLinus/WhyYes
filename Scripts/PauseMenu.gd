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
	AutoloadScript.playerData.playerIsFirstLoad = false
	# var players = get_tree().get_nodes_in_group("Player")
	if AutoloadScript.currentScene == 2:
		AutoloadScript.playerData.playerIsFirstLoad = true
		AutoloadScript.currentScene -= 1
		if get_tree().change_scene("res://Scenes/mainScene2.tscn") != OK:
			print("unable to change scene")
		self.isPause = false

	elif AutoloadScript.currentScene == 3:
		AutoloadScript.currentScene -= 1
		if get_tree().change_scene("res://Scenes/mainScene3.tscn") != OK:
			print("unable to change scene")
		self.isPause = false

	elif AutoloadScript.currentScene == 4:
		AutoloadScript.currentScene -= 1
		if get_tree().change_scene("res://Scenes/mainScene4.tscn") != OK:
			print("unable to change scene")
		self.isPause = false

	elif AutoloadScript.currentScene == 5:
		AutoloadScript.currentScene -= 1
		if get_tree().change_scene("res://Scenes/Catfe.tscn") != OK:
			print("unable to change scene")
		self.isPause = false
