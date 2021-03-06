extends Area2D

export(String, FILE) var nextScenePath = ""
onready var colli = $colli


func _ready():
	colli.disabled = false


func _on_Portal_area_entered(area: Area2D):
	if area.name == "InteractWithPortal":
		print("player entered portal")

	yield(get_tree().create_timer(1.6), "timeout")
	if get_tree().change_scene(nextScenePath) != OK:
		print("unable to change scene")


func _on_Enemy_enemyDeath():
	colli.disabled = false
