extends Control

onready var audioPlayer = $BGM


func _ready():
	visible = false


func _on_Player_playerDead():
	yield(get_tree().create_timer(1.2), "timeout")
	print("=====>>>> player dead")
	audioPlayer.play()
	visible = true


func _on_Button3_pressed():
	AutoloadScript.playerData.playerIsFirstLoad = false
	# var players = get_tree().get_nodes_in_group("Player")
	if AutoloadScript.currentScene == 1:
		AutoloadScript.playerData.playerIsFirstLoad = true
		if get_tree().change_scene("res://Scenes/main.tscn") != OK:
			print("unable to change scene")
		self.isPause = false
	elif AutoloadScript.currentScene == 2:
		AutoloadScript.currentScene -= 1
		# players[0].SavePlayerData()
		if get_tree().change_scene("res://Scenes/mainScene2.tscn") != OK:
			print("unable to change scene")
		self.isPause = false
	elif AutoloadScript.currentScene == 3:
		AutoloadScript.currentScene -= 1
		# players[0].SavePlayerData()
		if get_tree().change_scene("res://Scenes/mainScene3.tscn") != OK:
			print("unable to change scene")
		self.isPause = false


func _on_Button2_pressed():
	get_tree().quit()
